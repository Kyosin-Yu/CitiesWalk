import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/fitness_history.dart';

class FitnessHistoryOverview extends StatelessWidget {
  const FitnessHistoryOverview({super.key, required this.summary});

  final FitnessHistorySummary summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SummaryCard(summary: summary),
      const SizedBox(height: 16),
      Text(
        _activityTitle(summary.period),
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      if (!summary.hasActivity)
        const _NoActivityInRange()
      else
        for (var index = 0; index < summary.buckets.length; index++) ...[
          _ActivityCard(bucket: summary.buckets[index], period: summary.period),
          if (index != summary.buckets.length - 1) const SizedBox(height: 8),
        ],
    ],
  );

  static String _activityTitle(FitnessHistoryPeriod period) => switch (period) {
    FitnessHistoryPeriod.daily => 'Journeys on this day',
    FitnessHistoryPeriod.weekly => 'Active days this week',
    FitnessHistoryPeriod.monthly => 'Active days this month',
    FitnessHistoryPeriod.yearly => 'Active months this year',
  };
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final FitnessHistorySummary summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1B5E20), AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _rangeLabel(summary),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${summary.journeyCount} fitness record${summary.journeyCount == 1 ? '' : 's'}'
          ' • ${summary.activeDays} active day${summary.activeDays == 1 ? '' : 's'}',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricTile(
                  width: width,
                  icon: Icons.directions_walk_rounded,
                  value: '${_compact(summary.walkingDistanceKm)} km',
                  label: 'Walking distance',
                ),
                _MetricTile(
                  width: width,
                  icon: Icons.local_fire_department_rounded,
                  value: '${summary.caloriesKcal} kcal',
                  label: 'Calories',
                ),
                _MetricTile(
                  width: width,
                  icon: Icons.eco_rounded,
                  value: '${_compact(summary.carbonSavedKg)} kg',
                  label: 'CO₂ saved',
                ),
                _MetricTile(
                  width: width,
                  icon: Icons.directions_run_rounded,
                  value: '${summary.steps}',
                  label: 'Recorded steps',
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFFBDE5BF)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.bucket, required this.period});

  final FitnessHistoryBucket bucket;
  final FitnessHistoryPeriod period;

  @override
  Widget build(BuildContext context) {
    final completed = bucket.completedRouteCount == bucket.journeyCount;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEE9)),
      ),
      child: Row(
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
                  _bucketLabel(bucket.startedAt, period),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  period == FitnessHistoryPeriod.daily
                      ? (completed ? 'Completed route' : 'Journey ended early')
                      : '${bucket.journeyCount} record${bucket.journeyCount == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _SmallMetric(
                      icon: Icons.route_rounded,
                      text: '${_compact(bucket.walkingDistanceKm)} km',
                    ),
                    _SmallMetric(
                      icon: Icons.local_fire_department_rounded,
                      text: '${bucket.caloriesKcal} kcal',
                    ),
                    _SmallMetric(
                      icon: Icons.eco_rounded,
                      text: '${_compact(bucket.carbonSavedKg)} kg CO₂',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.secondary),
      const SizedBox(width: 3),
      Text(
        text,
        style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textSecondary),
      ),
    ],
  );
}

class _NoActivityInRange extends StatelessWidget {
  const _NoActivityInRange();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(Icons.event_busy_rounded, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Text(
          'No activity in this range.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

String _rangeLabel(FitnessHistorySummary summary) => switch (summary.period) {
  FitnessHistoryPeriod.daily => _fullDate(summary.anchorDate),
  FitnessHistoryPeriod.weekly =>
    '${summary.rangeStart.day} ${_month(summary.rangeStart.month)} – '
        '${summary.rangeEnd.day} ${_month(summary.rangeEnd.month)} '
        '${summary.rangeEnd.year}',
  FitnessHistoryPeriod.monthly =>
    '${_month(summary.anchorDate.month)} ${summary.anchorDate.year}',
  FitnessHistoryPeriod.yearly => '${summary.anchorDate.year}',
};

String _bucketLabel(DateTime date, FitnessHistoryPeriod period) {
  if (period == FitnessHistoryPeriod.daily) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
  if (period == FitnessHistoryPeriod.yearly) {
    return '${_month(date.month)} ${date.year}';
  }
  return '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)}';
}

String _fullDate(DateTime date) =>
    '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';

String _month(int month) => const [
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
][month - 1];

String _weekday(int weekday) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

String _compact(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);
