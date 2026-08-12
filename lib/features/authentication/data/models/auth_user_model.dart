import '../../domain/entities/app_user.dart';

class AuthUserModel extends AppUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phoneNumber,
    super.profileImage,
  });

  factory AuthUserModel.fromMap({
    required Map<String, dynamic> profile,
    required String email,
  }) {
    return AuthUserModel(
      id: profile['id'] as String,
      email: email,
      fullName: profile['full_name'] as String?,
      phoneNumber: profile['phone_number'] as String?,
      profileImage: profile['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
    };
  }
}
