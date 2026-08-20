import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_journey.dart';

/// Shown after GPS confirms arrival or the traveller intentionally ends early.
class JourneySummaryPage extends StatelessWidget {
  const JourneySummaryPage({
    super.key,
    required this.journey,
    required this.onPlanAnotherJourney,
    this.onViewFitness,
  });

  final EcoJourney journey;
  final VoidCallback onPlanAnotherJourney;
  final VoidCallback? onViewFitness;

  @override
  Widget build(BuildContext context) {
    final route = journey.route;
    final reachedDestination = journey.status == EcoJourneyStatus.completed;
    final duration = journey.startedAt == null || journey.endedAt == null
        ? route.durationMinutes
        : journey.endedAt!.difference(journey.startedAt!).inMinutes;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to route',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Journey summary'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        reachedDestination
                            ? Icons.flag_rounded
                            : Icons.stop_circle_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      reachedDestination
                          ? 'You arrived at ${route.destination.name}'
                          : 'Journey ended early',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reachedDestination
                          ? 'Your completed journey is now in your history and Fitness totals.'
                          : 'Your tracked progress is saved in history but is not counted in Fitness totals.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: .88),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your tracked results',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Walking and transit are kept separate. Steps are estimated from GPS walking distance.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.34,
                children: [
                  _SummaryMetric(
                    icon: Icons.directions_walk_rounded,
                    value:
                        '${journey.actualWalkingDistanceKm.toStringAsFixed(2)} km',
                    label: 'Walked',
                  ),
                  _SummaryMetric(
                    icon: Icons.train_rounded,
                    value:
                        '${journey.actualTransitDistanceKm.toStringAsFixed(2)} km',
                    label: 'By transit',
                  ),
                  _SummaryMetric(
                    icon: Icons.directions_run_rounded,
                    value: '${journey.actualStepCount}',
                    label: 'Estimated steps',
                  ),
                  _SummaryMetric(
                    icon: Icons.schedule_rounded,
                    value: '$duration min',
                    label: 'Journey duration',
                  ),
                  _SummaryMetric(
                    icon: Icons.local_fire_department_outlined,
                    value: '${journey.actualCaloriesBurned} kcal',
                    label: 'Calories burned',
                  ),
                  _SummaryMetric(
                    icon: Icons.eco_outlined,
                    value:
                        '${journey.actualCarbonSavedKg.toStringAsFixed(2)} kg',
                    label: 'CO₂ saved',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (reachedDestination && onViewFitness != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onViewFitness!();
                    },
                    icon: const Icon(Icons.directions_walk_rounded),
                    label: const Text('View today’s Fitness'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  onPlanAnotherJourney();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.explore_rounded),
                label: const Text('Plan another journey'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
