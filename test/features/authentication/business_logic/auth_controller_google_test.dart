import 'dart:async';

import 'package:citieswalk/features/authentication/business_logic/entities/app_user.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/account_deletion.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/authentication_state.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/auth_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/auth_repository.dart';
import 'package:citieswalk/core/errors/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signInWithGoogle delegates to the repository', () async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository);

    await controller.signInWithGoogle();

    expect(repository.googleSignInCalls, 1);
    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNull);

    controller.dispose();
    await repository.dispose();
  });

  test('auth state updates the current Google user', () async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository);
    const googleUser = AppUser(
      id: 'google-user',
      email: 'walker@example.com',
      fullName: 'Google Walker',
    );

    repository.emitState(const AuthenticationState(user: googleUser));
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentUser, same(googleUser));
    expect(controller.isAuthenticated, isTrue);

    controller.dispose();
    await repository.dispose();
  });

  test('password recovery event opens the recovery flow', () async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository);
    const user = AppUser(id: 'user', email: 'walker@example.com');

    repository.emitState(
      const AuthenticationState(
        user: user,
        event: AuthenticationEvent.passwordRecovery,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.isPasswordRecovery, isTrue);
    expect(controller.currentUser, same(user));

    controller.dispose();
    await repository.dispose();
  });

  test('updating a recovered password signs out and closes recovery', () async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository);
    const user = AppUser(id: 'user', email: 'walker@example.com');

    repository.emitState(
      const AuthenticationState(
        user: user,
        event: AuthenticationEvent.passwordRecovery,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final updated = await controller.updatePassword(password: 'new-password');

    expect(updated, isTrue);
    expect(repository.updatedPassword, 'new-password');
    expect(repository.signOutCalls, 1);
    expect(controller.isPasswordRecovery, isFalse);
    expect(controller.currentUser, isNull);

    controller.dispose();
    await repository.dispose();
  });

  test('password reset rate limit returns an actionable message', () async {
    final repository = _FakeAuthRepository()
      ..resetError = 'email rate limit exceeded';
    final controller = AuthController(repository);

    final message = await controller.sendPasswordResetEmail(
      email: 'walker@example.com',
    );

    expect(message, contains('Please wait'));
    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNull);

    controller.dispose();
    await repository.dispose();
  });

  test('account deletion is scheduled before a global sign out', () async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository);

    final success = await controller.requestAccountDeletion();

    expect(success, isTrue);
    expect(repository.deletionRequests, 1);
    expect(repository.signOutCalls, 1);
    controller.dispose();
    await repository.dispose();
  });

  test('recovers an account during the recovery period', () async {
    final repository = _FakeAuthRepository()
      ..currentUser = const AppUser(id: 'user-1', email: 'walker@example.com');
    final controller = AuthController(repository);

    final success = await controller.recoverAccount();

    expect(success, isTrue);
    expect(repository.cancellationCalls, 1);
    expect(controller.currentUser?.id, 'user-1');
    controller.dispose();
    await repository.dispose();
  });
}

class _FakeAuthRepository implements AuthRepository {
  final _authStates = StreamController<AuthenticationState>.broadcast();
  int googleSignInCalls = 0;
  int signOutCalls = 0;
  String? updatedPassword;
  String? resetError;
  AppUser? currentUser;
  int deletionRequests = 0;
  int cancellationCalls = 0;

  void emitState(AuthenticationState state) => _authStates.add(state);

  Future<void> dispose() => _authStates.close();

  @override
  Stream<AuthenticationState> authStateChanges() => _authStates.stream;

  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalls++;
  }

  @override
  Future<AccountDeletion> requestAccountDeletion() {
    deletionRequests++;
    return Future.value(
      AccountDeletion(
        requestedAt: DateTime(2026, 8, 30),
        permanentlyDeleteAt: DateTime(2026, 9, 29),
      ),
    );
  }

  @override
  Future<void> cancelAccountDeletion() {
    cancellationCalls++;
    return Future.value();
  }

  @override
  Future<void> finalizeAccountDeletion() {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> getCurrentUser() async => currentUser;

  @override
  Future<void> resendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (resetError case final message?) {
      throw AppException(message);
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    updatedPassword = password;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String bio,
    required bool publicProfile,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateProfileImage({required String localImagePath}) {
    throw UnimplementedError();
  }
}
