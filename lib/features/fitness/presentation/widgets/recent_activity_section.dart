import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/completed_fitness_journey.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.activities,
    required this.onViewAll,
  });

  final List<CompletedFitnessJourney> activities;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View all')),
          ],
        ),
        if (activities.isEmpty)
          Text(
            'Complete an Eco Route to see recent activity.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          )
        else
          for (var index = 0; index < activities.length; index++) ...[
            _ActivityRow(activity: activities[index]),
            if (index != activities.length - 1)
              const Divider(height: 20, color: Color(0xFFE8EEE9)),
          ],
      ],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final CompletedFitnessJourney activity;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.directions_walk_rounded,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.routeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  _dateLabel(activity.completedAt),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusLabel(activity: activity),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _Metric(
                  icon: Icons.route_rounded,
                  text:
                      '${(activity.walkingDistanceMeters / 1000).toStringAsFixed(2)} km',
                ),
                _Metric(
                  icon: Icons.local_fire_department_rounded,
                  text: '${activity.estimatedCalories} kcal',
                ),
                _Metric(
                  icon: Icons.eco_rounded,
                  text:
                      '${activity.estimatedCarbonSavedKg.toStringAsFixed(2)} kg',
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.activity});

  final CompletedFitnessJourney activity;

  @override
  Widget build(BuildContext context) {
    final completed = activity.countsAsCompletedRoute;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (completed ? AppColors.primary : AppColors.warning).withValues(
          alpha: .1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        completed ? activity.overallSource.label : 'Ended early',
        style: GoogleFonts.poppins(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: completed ? AppColors.primary : AppColors.warning,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.secondary),
      const SizedBox(width: 3),
      Text(
        text,
        style: GoogleFonts.poppins(fontSize: 8, color: AppColors.textSecondary),
      ),
    ],
  );
}

String _dateLabel(DateTime value) {
  final date = value.toLocal();
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month}/${date.year} • ${date.hour}:$minute';
}
