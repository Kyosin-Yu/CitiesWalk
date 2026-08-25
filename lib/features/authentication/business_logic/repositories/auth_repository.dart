import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  Future<AppUser> signIn({required String email, required String password});

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> resendEmailVerification();

  Future<AppUser?> getCurrentUser();

  Future<AppUser> updateProfile({
    required String fullName,
    required String bio,
    required bool publicProfile,
  });

  Future<AppUser> updateProfileImage({required String localImagePath});

  Stream<AppUser?> authStateChanges();
}
