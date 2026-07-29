class AuthUser {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;

  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
  });
}