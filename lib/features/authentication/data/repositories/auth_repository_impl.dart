import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/profile_datasource.dart';
import '../datasources/supabase_auth_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _authDatasource;
  final ProfileDataSource _profileDatasource;

  const AuthRepositoryImpl(this._authDatasource, this._profileDatasource);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _authDatasource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      final user = response.user;
      if (user == null) {
        throw const AppException('Unable to create account.');
      }
      return AppUser(
        id: user.id,
        email: user.email ?? email,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (e, stackTrace) {
      debugPrint('========== SIGN UP ERROR ==========');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      throw AppException(e.toString());
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authDatasource.signIn(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw const AppException('Login failed.');
      }

      final profile = await _profileDatasource.getProfile(user.id);

      if (profile != null) {
        return AuthUserModel.fromMap(
          profile: profile,
          email: user.email ?? email,
        );
      }

      return AppUser(id: user.id, email: user.email ?? email);
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDatasource.signOut();
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authDatasource.sendPasswordResetEmail(email: email);
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    try {
      final user = _authDatasource.currentUser;

      if (user == null || user.email == null) {
        throw const AppException('No signed-in user found.');
      }

      await _authDatasource.resendEmailVerification(email: user.email!);
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _authDatasource.currentUser;

      if (user == null) return null;

      final profile = await _profileDatasource.getProfile(user.id);

      if (profile != null) {
        return AuthUserModel.fromMap(profile: profile, email: user.email ?? '');
      }

      return AppUser(id: user.id, email: user.email ?? '');
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _authDatasource.authStateChanges().asyncMap((authState) async {
      final user = authState.session?.user;

      if (user == null) return null;

      final profile = await _profileDatasource.getProfile(user.id);

      if (profile != null) {
        return AuthUserModel.fromMap(profile: profile, email: user.email ?? '');
      }

      return AppUser(id: user.id, email: user.email ?? '');
    });
  }
}
