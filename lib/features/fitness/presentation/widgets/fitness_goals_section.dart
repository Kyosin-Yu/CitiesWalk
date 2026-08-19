import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/entities/fitness_dashboard.dart';

class FitnessGoalsSection extends StatelessWidget {
  const FitnessGoalsSection({super.key, required this.dashboard});
  final FitnessDashboard dashboard;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
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
        Text(
          'Completed Route Summary',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Personal goals are not configured yet; these are actual route totals.',
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: const Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Summary(
                icon: Icons.today_rounded,
                title: 'Today',
                value:
                    '${dashboard.walkingDistanceTodayKm.toStringAsFixed(2)} km',
                color: const Color(0xFF2E7D32),
              ),
            ),
            Expanded(
              child: _Summary(
                icon: Icons.date_range_rounded,
                title: 'Last 7 days',
                value:
                    '${dashboard.weeklyWalkingDistanceKm.toStringAsFixed(2)} km',
                color: const Color(0xFF1565C0),
              ),
            ),
            Expanded(
              child: _Summary(
                icon: Icons.calendar_month_rounded,
                title: 'This month',
                value:
                    '${dashboard.monthlyWalkingDistanceKm.toStringAsFixed(2)} km',
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(
        backgroundColor: color.withValues(alpha: .12),
        foregroundColor: color,
        child: Icon(icon, size: 20),
      ),
      const SizedBox(height: 8),
      Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600),
      ),
      Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 9, color: color),
      ),
    ],
  );
}
