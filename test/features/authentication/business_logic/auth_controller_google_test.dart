import 'dart:async';

import 'package:citieswalk/features/authentication/business_logic/entities/app_user.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/auth_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/auth_repository.dart';
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

    repository.emitUser(googleUser);
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentUser, same(googleUser));
    expect(controller.isAuthenticated, isTrue);

    controller.dispose();
    await repository.dispose();
  });
}

class _FakeAuthRepository implements AuthRepository {
  final _authStates = StreamController<AppUser?>.broadcast();
  int googleSignInCalls = 0;

  void emitUser(AppUser? user) => _authStates.add(user);

  Future<void> dispose() => _authStates.close();

  @override
  Stream<AppUser?> authStateChanges() => _authStates.stream;

  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalls++;
  }

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<void> resendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

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
