import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../business_logic/providers/auth_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController _authController = sl<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  late bool _publicProfile;

  static const int _bioMaxLength = 120;

  @override
  void initState() {
    super.initState();

    final user = _authController.currentUser;

    _publicProfile = user?.publicProfile ?? true;

    _displayNameController = TextEditingController(text: user?.fullName ?? '');

    _emailController = TextEditingController(text: user?.email ?? '');

    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _changeProfilePhoto() async {
    final selectedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (selectedImage == null) {
      return;
    }

    final success = await _authController.updateProfileImage(
      localImagePath: selectedImage.path,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authController.errorMessage ?? 'Unable to update profile photo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        titleSpacing: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFE8F5E9),
                          backgroundImage:
                              user?.profileImage != null &&
                                  user!.profileImage!.isNotEmpty
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child:
                              user?.profileImage == null ||
                                  user!.profileImage!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _changeProfilePhoto,
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Display Name'),
              const SizedBox(height: 6),
              TextField(
                controller: _displayNameController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Email'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                enabled: false,
                decoration: _inputDecoration(
                  fillColor: const Color(0xFFF1F4F2),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Email is linked to your account and cannot be changed here.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Bio'),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLength: _bioMaxLength,
                maxLines: 4,
                minLines: 4,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: _inputDecoration().copyWith(
                  counterText: '',
                  alignLabelWithHint: true,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_bioController.text.length} / $_bioMaxLength',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Public Profile',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Turn this off to appear as Anonymous on the leaderboard.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _publicProfile,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _publicProfile = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _authController.isLoading
                      ? null
                      : () async {
                          final fullName = _displayNameController.text.trim();

                          final bio = _bioController.text.trim();

                          if (fullName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Display name cannot be empty.'),
                              ),
                            );

                            return;
                          }

                          final success = await _authController.updateProfile(
                            fullName: fullName,
                            bio: bio,
                            publicProfile: _publicProfile,
                          );

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully.'),
                              ),
                            );

                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _authController.errorMessage ??
                                      'Unable to update profile.',
                                ),
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _authController.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({Color fillColor = Colors.white}) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7DDD8)),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
