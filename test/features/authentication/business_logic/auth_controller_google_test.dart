import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citieswalk/core/di/service_locator.dart';
import 'package:citieswalk/features/authentication/presentation/pages/auth_gate.dart';
import 'package:citieswalk/features/authentication/presentation/pages/login_page.dart';
import 'package:citieswalk/features/authentication/presentation/pages/account_recovery_page.dart';
import 'package:citieswalk/features/authentication/presentation/pages/setting_page.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/settings_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/settings_repository.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/user_settings.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/app_user.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/account_deletion.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/authentication_state.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/auth_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/auth_repository.dart';
import 'package:citieswalk/core/errors/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final error in <String?>[null, 'Email delivery failed']) {
    testWidgets('reset request keeps login mounted and shows result: $error', (
      tester,
    ) async {
      final repository = _FakeAuthRepository()..resetError = error;
      final completion = Completer<void>();
      repository.resetCompletion = completion;
      final controller = AuthController(repository);
      sl.registerSingleton<AuthController>(controller);
      addTearDown(() async {
        await sl.reset();
        controller.dispose();
        await repository.dispose();
      });
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const MaterialApp(home: AuthGate()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'walker@yahoo.com',
      );
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Sending reset email…'), findsOneWidget);
      expect(controller.isLoading, isFalse);
      expect(repository.resetEmail, 'walker@yahoo.com');
      completion.complete();
      await tester.pumpAndSettle();
      expect(
        find.text(
          error ??
              'Reset requested. If this email is registered, check your inbox and spam folder for the reset link.',
        ),
        findsOneWidget,
      );
      expect(controller.isSendingPasswordReset, isFalse);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('Google login requires recovery and declining returns to login', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository);
    sl.registerSingleton<AuthController>(controller);
    addTearDown(() async {
      await sl.reset();
      controller.dispose();
      await repository.dispose();
    });
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    await tester.pumpAndSettle();
    await controller.signInWithGoogle();
    repository.emitState(AuthenticationState(user: _pendingUser()));
    await tester.pumpAndSettle();

    expect(find.byType(AuthGate), findsOneWidget);
    expect(find.byType(AccountRecoveryPage), findsOneWidget);
    expect(repository.cancellationCalls, 0);
    await tester.tap(find.text('Keep deletion scheduled'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(repository.cancellationCalls, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('successful deletion closes Settings and returns to login', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()..currentUser = _pendingUser();
    final controller = AuthController(repository);
    final settings = SettingsController(_FakeSettingsRepository());
    sl.registerSingleton<AuthController>(controller);
    sl.registerSingleton<SettingsController>(settings);
    addTearDown(() async {
      await sl.reset();
      controller.dispose();
      settings.dispose();
      await repository.dispose();
    });
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(navigatorKey: navigator, home: const AuthGate()),
      ),
    );
    await tester.pumpAndSettle();
    navigator.currentState!.push<void>(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule deletion'));
    await tester.pumpAndSettle();

    expect(repository.deletionRequests, 1);
    expect(repository.signOutCalls, 1);
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(navigator.currentState!.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

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

AppUser _pendingUser() => AppUser(
  id: 'google-user',
  email: 'walker@example.com',
  deletionRequestedAt: DateTime.now(),
  permanentlyDeleteAt: DateTime.now().add(const Duration(days: 30)),
);

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<UserSettings> load() async => const UserSettings();

  @override
  Future<UserSettings> save(UserSettings settings) async => settings;
}

class _FakeAuthRepository implements AuthRepository {
  final _authStates = StreamController<AuthenticationState>.broadcast();
  int googleSignInCalls = 0;
  int signOutCalls = 0;
  String? updatedPassword;
  String? resetError;
  String? resetEmail;
  Completer<void>? resetCompletion;
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
    resetEmail = email;
    await resetCompletion?.future;
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
