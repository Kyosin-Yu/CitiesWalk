import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/badge_model.dart';
import 'badge_item_card.dart' show iconForBadge;

class BadgeDetailModal extends StatelessWidget {
  const BadgeDetailModal({super.key, required this.badge, this.onStartJourney});

  final BadgeModel badge;
  final VoidCallback? onStartJourney;

  static Future<void> show(
    BuildContext context,
    BadgeModel badge, {
    VoidCallback? onStartJourney,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          BadgeDetailModal(badge: badge, onStartJourney: onStartJourney),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Close badge details',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            CircleAvatar(
              radius: 43,
              backgroundColor: AppColors.accent.withValues(alpha: 0.25),
              child: Icon(
                iconForBadge(badge.icon),
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isUnlocked ? 'ACHIEVEMENT UNLOCKED' : 'ECO BADGE',
              style: const TextStyle(
                letterSpacing: 1.5,
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              badge.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (isUnlocked)
              _CompletionDetails(badge: badge)
            else
              _ProgressDetails(badge: badge),
            const SizedBox(height: 16),
            if (isUnlocked)
              const _CelebrationMessage()
            else
              _UnlockHint(badge: badge),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (!isUnlocked) onStartJourney?.call();
                },
                icon: Icon(
                  isUnlocked ? Icons.check_circle_rounded : Icons.eco_rounded,
                ),
                label: Text(
                  isUnlocked ? 'Achievement Completed' : 'Start Eco-Journey',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionDetails extends StatelessWidget {
  const _CompletionDetails({required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Completion details',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.task_alt_rounded,
            label: 'Completed condition',
            value: badge.description,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Completed on',
            value: _formatCompletionTime(badge.earnedOn),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Location',
            value: badge.completionLocation ?? 'Location not recorded',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressDetails extends StatelessWidget {
  const _ProgressDetails({required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'Progress',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${badge.progress}/${badge.goal} Trips',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: badge.progressFraction,
              minHeight: 10,
              color: AppColors.secondary,
              backgroundColor: const Color(0xFFDDE0E2),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              const Text(
                '0',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${(badge.progressFraction * 100).round()}% Completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${badge.goal}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CelebrationMessage extends StatelessWidget {
  const _CelebrationMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.celebration_rounded, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Great work! This achievement has been added to your locker.',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockHint extends StatelessWidget {
  const _UnlockHint({required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${badge.remaining} more trips to unlock this badge. Keep exploring!',
        style: const TextStyle(color: AppColors.primary, fontSize: 13),
      ),
    );
  }
}

String _formatCompletionTime(DateTime? date) {
  if (date == null) return 'Completion time not recorded';

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
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $period';
}
