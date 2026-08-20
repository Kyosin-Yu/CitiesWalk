class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;
  final String? bio;
  final bool publicProfile;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
    this.bio,
    this.publicProfile = true,
  });
}
