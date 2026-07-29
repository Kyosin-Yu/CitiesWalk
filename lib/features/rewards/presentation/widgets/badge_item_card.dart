import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/badge_model.dart';

class BadgeItemCard extends StatelessWidget {
  const BadgeItemCard({super.key, required this.badge, required this.onTap});

  final BadgeModel badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !badge.isUnlocked;
    final cardColor = locked ? const Color(0xFFFAFAFA) : AppColors.surface;
    final color = locked ? Colors.grey.shade500 : AppColors.primary;

    return Semantics(
      button: true,
      label: '${badge.title}, ${locked ? 'locked' : 'unlocked'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: locked
                        ? Colors.grey.shade100
                        : AppColors.accent.withValues(alpha: 0.25),
                    child: Icon(
                      iconForBadge(badge.icon),
                      color: color,
                      size: 33,
                    ),
                  ),
                  if (locked)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.lock_rounded,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                badge.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: locked ? Colors.grey.shade500 : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 7),
              if (locked)
                Column(
                  children: <Widget>[
                    Text(
                      '${badge.progress}/${badge.goal} Trips     ${(badge.progressFraction * 100).round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: badge.progressFraction,
                        minHeight: 4,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F7EA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Earned ${_dateLabel(badge.earnedOn)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
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

IconData iconForBadge(BadgeIcon icon) => switch (icon) {
  BadgeIcon.city => Icons.location_city_rounded,
  BadgeIcon.recycle => Icons.recycling_rounded,
  BadgeIcon.sunrise => Icons.wb_sunny_rounded,
  BadgeIcon.globe => Icons.public_rounded,
  BadgeIcon.accountBalance => Icons.account_balance_rounded,
  BadgeIcon.owl => Icons.nightlight_round,
  BadgeIcon.leaf => Icons.eco_rounded,
  BadgeIcon.directionsWalk => Icons.directions_walk_rounded,
};

String _dateLabel(DateTime? date) {
  if (date == null) return '';
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
