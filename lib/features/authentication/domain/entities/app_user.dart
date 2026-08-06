class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
  });
}