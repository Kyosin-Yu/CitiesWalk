import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/fitness_recent_badge.dart';

class RecentBadgesSection extends StatelessWidget {
  const RecentBadgesSection({super.key, required this.badges, this.onSeeAll});

  final List<FitnessRecentBadge> badges;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Recent Badges',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
      if (badges.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Your newest unlocked badges will appear here.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        )
      else
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _BadgeCard(badge: badges[index]),
          ),
        ),
    ],
  );
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final FitnessRecentBadge badge;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: badge.description,
    child: Container(
      width: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .18),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(badge.iconKey), color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  static IconData _iconFor(String key) => switch (key) {
    'city' => Icons.location_city_rounded,
    'recycle' => Icons.recycling_rounded,
    'sunrise' => Icons.wb_sunny_rounded,
    'globe' => Icons.public_rounded,
    'accountBalance' => Icons.account_balance_rounded,
    'owl' => Icons.nightlight_round,
    'directionsWalk' => Icons.directions_walk_rounded,
    _ => Icons.eco_rounded,
  };
}
