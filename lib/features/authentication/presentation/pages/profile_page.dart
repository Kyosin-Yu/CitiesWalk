import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../business_logic/providers/auth_controller.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../eco_route/data/data_sources/supabase_journey_data_source.dart';
import '../../../eco_route/data/repositories/supabase_journey_repository.dart';
import '../../../eco_route/presentation/pages/my_journeys_page.dart';
import 'setting_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.onOpenMyReviews,
    required this.onOpenMyBadges,
  });

  final VoidCallback onOpenMyReviews;
  final VoidCallback onOpenMyBadges;

  @override
  Widget build(BuildContext context) {
    final authController = sl<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: authController,
          builder: (context, _) {
            final user = authController.currentUser;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _ProfileHeader(
                    fullName: user?.fullName ?? 'CitiesWalk User',
                    email: user?.email ?? '',
                    profileImage: user?.profileImage,
                  ),
                  const SizedBox(height: 18),
                  const _ProfileStats(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _EditProfileButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _ProfileMenuCard(
                      items: [
                        _ProfileMenuItemData(
                          icon: Icons.near_me_outlined,
                          title: 'My Journeys',
                          subtitle: 'View your completed journeys',
                          onTap: () {
                            final user = authController.currentUser;

                            if (user == null) {
                              return;
                            }

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyJourneysPage(
                                  userId: user.id,
                                  repository: SupabaseJourneyRepository(
                                    SupabaseJourneyDataSource(
                                      sl<SupabaseClient>(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItemData(
                          icon: Icons.star_border_rounded,
                          title: 'My Reviews',
                          subtitle: 'View your community reviews',
                          onTap: onOpenMyReviews,
                        ),
                        _ProfileMenuItemData(
                          icon: Icons.workspace_premium_outlined,
                          title: 'My Badges',
                          subtitle: 'View your earned badges',
                          onTap: onOpenMyBadges,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _ProfileMenuCard(
                      items: [
                        _ProfileMenuItemData(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          subtitle: 'Notifications, language, privacy',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItemData(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          subtitle: 'Sign out of your account',
                          isDestructive: true,
                          onTap: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Log Out'),
                                  content: const Text(
                                    'Are you sure you want to log out of your account?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(true);
                                      },
                                      child: const Text('Log Out'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldLogout != true) {
                              return;
                            }

                            await authController.signOut();

                            if (!context.mounted) {
                              return;
                            }

                            if (authController.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authController.errorMessage!),
                                ),
                              );

                              return;
                            }

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CitiesWalk v2.1.0 · KL Edition 🌿',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.email,
    required this.profileImage,
  });

  final String fullName;
  final String email;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: const Color(0xFFE8F5E9),
                backgroundImage:
                    profileImage != null && profileImage!.isNotEmpty
                    ? NetworkImage(profileImage!)
                    : null,
                child: profileImage == null || profileImage!.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 34,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              Positioned(
                right: -2,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Eco Starter',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StatItem(value: '24', label: 'Journeys'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(value: '1', label: 'Reviews'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(value: '7', label: 'Badges'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(value: '3.2k', label: 'Points'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 58, color: const Color(0xFFE5E5E5));
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({required this.items});

  final List<_ProfileMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            children: [
              _ProfileMenuItem(item: item),
              if (index != items.length - 1)
                const Divider(height: 1, indent: 56, color: Color(0xFFEAEAEA)),
            ],
          );
        }),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({required this.item});

  final _ProfileMenuItemData item;

  @override
  Widget build(BuildContext context) {
    final iconColor = item.isDestructive
        ? const Color(0xFFE53935)
        : AppColors.primary;

    final iconBackground = item.isDestructive
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F5E9);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: item.isDestructive
                          ? const Color(0xFFE53935)
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItemData {
  const _ProfileMenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
}
