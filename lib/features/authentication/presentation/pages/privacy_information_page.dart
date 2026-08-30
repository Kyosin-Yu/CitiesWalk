import 'package:citieswalk/core/localization/localized_material.dart';

import '../../../../app/theme/app_colors.dart';

class PrivacyInformationPage extends StatelessWidget {
  const PrivacyInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy & Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NoticeCard(),
          SizedBox(height: 16),
          _PrivacySection(
            icon: Icons.person_outline_rounded,
            title: 'Account and profile',
            body:
                'CitiesWalk stores your account identity, profile details, and language and region preferences so your account works across devices.',
          ),
          _PrivacySection(
            icon: Icons.directions_walk_rounded,
            title: 'Journeys and location',
            body:
                'Location is requested for route planning and active journey tracking. Journey origins, destinations, progress points, and journey results may be saved to your account.',
          ),
          _PrivacySection(
            icon: Icons.star_outline_rounded,
            title: 'Reviews and rewards',
            body:
                'Reviews, uploaded review photos, points, badges, and leaderboard information are stored when you use those features.',
          ),
          _PrivacySection(
            icon: Icons.security_rounded,
            title: 'Your controls',
            body:
                'You can change device permissions in system settings and permanently delete your CitiesWalk account from Settings.',
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'This page describes the current app behaviour. Your team should review and publish the final legal privacy policy before public release.',
        style: TextStyle(height: 1.45, color: AppColors.textPrimary),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
