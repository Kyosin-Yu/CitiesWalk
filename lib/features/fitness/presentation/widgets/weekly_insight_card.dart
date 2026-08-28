import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/entities/fitness_dashboard.dart';

class WeeklyInsightCard extends StatelessWidget {
  const WeeklyInsightCard({super.key, required this.dashboard});
  final FitnessDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final previous = dashboard.previousWeekWalkingDistanceKm;
    final differencePercent = previous <= 0
        ? null
        : ((dashboard.weeklyWalkingDistanceKm - previous) / previous * 100);
    final message = !dashboard.hasRecordedActivity
        ? 'Complete an Eco Route to generate your first weekly insight.'
        : differencePercent == null
        ? 'Your Eco Route activity added ${dashboard.weeklyWalkingDistanceKm.toStringAsFixed(2)} km of walking this week.'
        : 'You walked ${differencePercent.abs().toStringAsFixed(0)}% ${differencePercent >= 0 ? 'more' : 'less'} than the previous 7 days.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF23762C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROUTE INSIGHT',
            style: GoogleFonts.poppins(
              fontSize: 9,
              letterSpacing: 1.1,
              color: const Color(0xFFA5D6A7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _Insight(
                  icon: Icons.route_rounded,
                  value:
                      '${dashboard.weeklyWalkingDistanceKm.toStringAsFixed(2)} km',
                  label: 'Walking',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Insight(
                  icon: Icons.local_fire_department_rounded,
                  value: '${dashboard.weeklyCaloriesKcal}',
                  label: 'Est. kcal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Insight(
                  icon: Icons.eco_rounded,
                  value:
                      '${dashboard.weeklyCarbonSavedKg.toStringAsFixed(2)} kg',
                  label: 'Est. CO₂',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFA5D6A7)),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 9,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 7),
        ),
      ],
    ),
  );
}
