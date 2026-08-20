import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../business_logic/entities/app_user.dart';
import '../../business_logic/repositories/auth_repository.dart';
import '../data_sources/profile_data_source.dart';
import '../data_sources/supabase_auth_data_source.dart';
import '../data_sources/profile_storage_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _authDatasource;
  final ProfileDataSource _profileDatasource;
  final ProfileStorageDataSource _profileStorageDataSource;

  const AuthRepositoryImpl(
    this._authDatasource,
    this._profileDatasource,
    this._profileStorageDataSource,
  );

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

      return _buildAppUser(
        user: user,
        profile: null,
        fallbackFullName: fullName,
        fallbackPhoneNumber: phoneNumber,
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

      return await _buildAppUserWithImage(user: user, profile: profile);
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (e, stackTrace) {
      debugPrint('========== SIGN IN ERROR ==========');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      throw const AppException('Something went wrong. Please try again.');
    }
  }

  Future<AppUser> _buildAppUserWithImage({
    required User user,
    Map<String, dynamic>? profile,
  }) async {
    final baseUser = _buildAppUser(user: user, profile: profile);

    final storagePath = profile?['profile_image']?.toString();

    final imageUrl = await _profileStorageDataSource.createSignedImageUrl(
      storagePath,
    );

    return AppUser(
      id: baseUser.id,
      email: baseUser.email,
      fullName: baseUser.fullName,
      phoneNumber: baseUser.phoneNumber,
      profileImage: imageUrl,
      bio: baseUser.bio,
      publicProfile: baseUser.publicProfile,
    );
  }

  @override
  Future<AppUser> updateProfileImage({required String localImagePath}) async {
    try {
      final user = _authDatasource.currentUser;

      if (user == null) {
        throw const AppException('No authenticated user found.');
      }

      final storagePath = await _profileStorageDataSource.uploadProfileImage(
        userId: user.id,
        localImagePath: localImagePath,
      );

      await _profileDatasource.updateProfile(
        id: user.id,
        profileImage: storagePath,
      );

      final updatedProfile = await _profileDatasource.getProfile(user.id);

      if (updatedProfile == null) {
        throw const AppException('Unable to load updated profile.');
      }

      return await _buildAppUserWithImage(user: user, profile: updatedProfile);
    } on AppException {
      rethrow;
    } on StorageException catch (e) {
      throw AppException(e.message);
    } catch (e, stackTrace) {
      debugPrint('========== PROFILE IMAGE ERROR ==========');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      throw const AppException('Unable to update profile photo.');
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
  Future<AppUser> updateProfile({
    required String fullName,
    required String bio,
    required bool publicProfile,
  }) async {
    try {
      final user = _authDatasource.currentUser;

      if (user == null) {
        throw const AppException('No authenticated user found.');
      }

      await _profileDatasource.updateProfile(
        id: user.id,
        fullName: fullName,
        bio: bio,
        publicProfile: publicProfile,
      );

      final updatedProfile = await _profileDatasource.getProfile(user.id);

      if (updatedProfile == null) {
        throw const AppException('Unable to load updated profile.');
      }

      return await _buildAppUserWithImage(user: user, profile: updatedProfile);
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(e.message);
    } catch (e, stackTrace) {
      debugPrint('========== UPDATE PROFILE ERROR ==========');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      throw const AppException('Unable to update profile. Please try again.');
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

      if (user == null) {
        return null;
      }

      final profile = await _profileDatasource.getProfile(user.id);

      return await _buildAppUserWithImage(user: user, profile: profile);
    } catch (e, stackTrace) {
      debugPrint('========== GET CURRENT USER ERROR ==========');
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      return null;
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _authDatasource.authStateChanges().asyncMap((authState) async {
      final user = authState.session?.user;

      if (user == null) {
        return null;
      }

      final profile = await _profileDatasource.getProfile(user.id);

      return await _buildAppUserWithImage(user: user, profile: profile);
    });
  }

  AppUser _buildAppUser({
    required User user,
    Map<String, dynamic>? profile,
    String? fallbackFullName,
    String? fallbackPhoneNumber,
  }) {
    final metadata = user.userMetadata ?? {};

    final profileFullName = profile?['full_name']?.toString().trim();

    final metadataFullName = metadata['full_name']?.toString().trim();

    final profilePhoneNumber = profile?['phone_number']?.toString().trim();

    final metadataPhoneNumber = metadata['phone_number']?.toString().trim();

    final profileImage = profile?['profile_image']?.toString().trim();

    final bio = profile?['bio']?.toString();

    final publicProfile = profile?['public_profile'] as bool? ?? true;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: _firstNonEmpty([
        profileFullName,
        metadataFullName,
        fallbackFullName,
      ]),
      phoneNumber: _firstNonEmpty([
        profilePhoneNumber,
        metadataPhoneNumber,
        fallbackPhoneNumber,
      ]),
      profileImage: _firstNonEmpty([profileImage]),
      bio: bio,
      publicProfile: publicProfile,
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}
