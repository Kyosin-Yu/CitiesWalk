import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/entities/fitness_dashboard.dart';
import '../../business_logic/entities/completed_fitness_journey.dart';

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key, required this.dashboard});
  final FitnessDashboard dashboard;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.42,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    children: [
      _MetricCard(
        label: 'Journey Steps',
        value: dashboard.journeyStepsSource == FitnessMetricSource.unavailable
            ? '—'
            : dashboard.journeyStepsToday.toString(),
        unit: dashboard.journeyStepsSource == FitnessMetricSource.unavailable
            ? 'not recorded'
            : 'steps in CitiesWalk',
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFF2E7D32),
        iconColor: const Color(0xFFE7F3E8),
        source: dashboard.journeyStepsSource,
      ),
      _MetricCard(
        label: 'Overall Steps Today',
        value: dashboard.overallStepsToday?.toString() ?? '—',
        unit: dashboard.overallStepsToday == null
            ? 'Health Connect not linked'
            : 'steps • Health Connect',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFF1565C0),
        iconColor: const Color(0xFFD9EFFF),
      ),
      _MetricCard(
        label: 'Walking Today',
        value: dashboard.walkingDistanceTodayKm.toStringAsFixed(2),
        unit: 'km',
        icon: Icons.route_rounded,
        color: const Color(0xFF2E7D32),
        iconColor: const Color(0xFFE7F3E8),
        source: dashboard.walkingSource,
      ),
      _MetricCard(
        label: 'Calories Today',
        value: '${dashboard.caloriesTodayKcal}',
        unit: 'kcal',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFF6D00),
        iconColor: const Color(0xFFFFDDCF),
        source: dashboard.caloriesSource,
      ),
      _MetricCard(
        label: 'CO₂ Saved Today',
        value: dashboard.carbonSavedTodayKg.toStringAsFixed(2),
        unit: 'kg',
        icon: Icons.eco_rounded,
        color: const Color(0xFF1565C0),
        iconColor: const Color(0xFFD9EFFF),
        source: dashboard.carbonSource,
      ),
      _MetricCard(
        label: 'Eco Points',
        value: dashboard.ecoPoints?.toString() ?? '—',
        unit: dashboard.ecoPoints == null
            ? 'rewards not linked'
            : 'pts this week',
        icon: Icons.star_rounded,
        color: const Color(0xFFF9A825),
        iconColor: const Color(0xFFFFF3C6),
      ),
      _MetricCard(
        label: 'Completed Routes',
        value: '${dashboard.completedJourneysThisWeek}',
        unit: 'last 7 days',
        icon: Icons.flag_rounded,
        color: const Color(0xFF6A1B9A),
        iconColor: const Color(0xFFF1E3F8),
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.source,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final FitnessMetricSource? source;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  if (source != null) ...[
                    const SizedBox(height: 3),
                    _SourceLabel(source: source!),
                  ],
                ],
              ),
            ),
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF9B9B9B),
            fontSize: 8,
          ),
        ),
      ],
    ),
  );
}

class _SourceLabel extends StatelessWidget {
  const _SourceLabel({required this.source});

  final FitnessMetricSource source;

  @override
  Widget build(BuildContext context) {
    final color = switch (source) {
      FitnessMetricSource.recorded => const Color(0xFF2E7D32),
      FitnessMetricSource.estimated => const Color(0xFFF57C00),
      FitnessMetricSource.mixed => const Color(0xFF1565C0),
      FitnessMetricSource.unavailable => const Color(0xFF757575),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            source.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
