import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../entities/app_user.dart';
import '../entities/authentication_state.dart';
import '../repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  late final StreamSubscription<AuthenticationState> _authStateSubscription;

  AuthController(this._repository) {
    _authStateSubscription = _repository.authStateChanges().listen(
      (state) {
        _currentUser = state.user;
        if (state.isPasswordRecovery) {
          _isPasswordRecovery = true;
        } else if (state.user == null) {
          _isPasswordRecovery = false;
        }
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = error is AppException
            ? error.message
            : 'Unable to restore your sign-in session.';
        notifyListeners();
      },
    );
  }

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isPasswordRecovery = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isPasswordRecovery => _isPasswordRecovery;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.signIn(email: email, password: password);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signInWithGoogle();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signOut();
      _currentUser = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendPasswordResetEmail(email: email);
      return null;
    } on AppException catch (e) {
      final message = e.message.toLowerCase().contains('rate limit')
          ? 'Too many reset emails were requested. Please wait before trying again.'
          : e.message;
      return message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updatePassword(password: password);
      await _repository.signOut();
      _currentUser = null;
      _isPasswordRecovery = false;
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelPasswordRecovery() async {
    await signOut();
    _isPasswordRecovery = false;
    notifyListeners();
  }

  Future<void> checkCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.getCurrentUser();
    } on AppException catch (e) {
      _currentUser = null;
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      _currentUser = await _repository.getCurrentUser();
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String bio,
    required bool publicProfile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.updateProfile(
        fullName: fullName,
        bio: bio,
        publicProfile: publicProfile,
      );

      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileImage({required String localImagePath}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.updateProfileImage(
        localImagePath: localImagePath,
      );

      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestAccountDeletion() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.requestAccountDeletion();
      await _repository.signOut();
      _currentUser = null;
      return true;
    } on AppException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recoverAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.cancelAccountDeletion();
      _currentUser = await _repository.getCurrentUser();
      return _currentUser != null;
    } on AppException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> finalizeAccountDeletion() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.finalizeAccountDeletion();
      _currentUser = null;
      return true;
    } on AppException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
