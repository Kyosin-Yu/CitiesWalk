import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _journeyAlerts = true;
  bool _reviewResponses = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text(
          'Settings',
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
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('NOTIFICATIONS'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _ToggleTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Journey tips, rewards & updates',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                  _ToggleTile(
                    icon: Icons.near_me_outlined,
                    title: 'Journey Alerts',
                    subtitle: 'Alerts during active journeys',
                    value: _journeyAlerts,
                    onChanged: (value) {
                      setState(() {
                        _journeyAlerts = value;
                      });
                    },
                  ),
                  _ToggleTile(
                    icon: Icons.star_border_rounded,
                    title: 'Review Responses',
                    subtitle: 'When someone replies to your review',
                    value: _reviewResponses,
                    onChanged: (value) {
                      setState(() {
                        _reviewResponses = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              const _SectionTitle('LANGUAGE & REGION'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _NavigationTile(
                    icon: Icons.language_rounded,
                    iconBackground: const Color(0xFFEAF2FF),
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {},
                  ),
                  _NavigationTile(
                    icon: Icons.location_on_outlined,
                    iconBackground: const Color(0xFFEAF2FF),
                    iconColor: const Color(0xFF3B82F6),
                    title: 'City / Region',
                    subtitle: 'Kuala Lumpur, Malaysia',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 22),

              const _SectionTitle('PRIVACY & DATA'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _NavigationTile(
                    icon: Icons.lock_outline_rounded,
                    iconBackground: const Color(0xFFF1EBFF),
                    iconColor: const Color(0xFF7C3AED),
                    title: 'Privacy Policy',
                    subtitle: 'How we use your data',
                    onTap: () {},
                  ),
                  _NavigationTile(
                    icon: Icons.directions_walk_rounded,
                    title: 'Location Data',
                    subtitle: 'Used only during active journeys',
                    onTap: () {},
                  ),
                  _NavigationTile(
                    icon: Icons.delete_outline_rounded,
                    iconBackground: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFE53935),
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your data',
                    titleColor: const Color(0xFFE53935),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              'This will permanently remove your account and profile data. '
                                  'This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Account deletion will be implemented in a later phase.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'CitiesWalk v2.1.0 · KL Edition 🌿',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(
          children.length,
          (index) => Column(
            children: [
              children[index],
              if (index != children.length - 1)
                const Divider(height: 1, indent: 58, color: Color(0xFFEAEAEA)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _SettingsIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: _SettingsText(title: title, subtitle: subtitle),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackground = const Color(0xFFE8F5E9),
    this.iconColor = AppColors.primary,
    this.titleColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _SettingsIcon(
              icon: icon,
              backgroundColor: iconBackground,
              iconColor: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SettingsText(
                title: title,
                subtitle: subtitle,
                titleColor: titleColor,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({
    required this.icon,
    this.backgroundColor = const Color(0xFFE8F5E9),
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 19, color: iconColor),
    );
  }
}

class _SettingsText extends StatelessWidget {
  const _SettingsText({
    required this.title,
    required this.subtitle,
    this.titleColor = AppColors.textPrimary,
  });

  final String title;
  final String subtitle;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
