import '../../business_logic/entities/app_user.dart';

class AuthUserModel extends AppUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phoneNumber,
    super.profileImage,
    super.bio,
    super.publicProfile,
  });

  factory AuthUserModel.fromMap(
    Map<String, dynamic> map, {
    required String email,
  }) {
    return AuthUserModel(
      id: map['id'] as String,
      email: email,
      fullName: map['full_name']?.toString(),
      phoneNumber: map['phone_number']?.toString(),
      profileImage: map['profile_image']?.toString(),
      bio: map['bio']?.toString(),
      publicProfile: map['public_profile'] as bool? ?? true,
    );
  }
}
