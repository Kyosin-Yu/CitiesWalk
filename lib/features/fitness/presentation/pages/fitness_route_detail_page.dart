import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/completed_fitness_journey.dart';
import '../../business_logic/providers/fitness_controller.dart';
import '../widgets/fitness_history_route_map.dart';

class FitnessRouteDetailPage extends StatefulWidget {
  const FitnessRouteDetailPage({super.key, required this.journey});

  final CompletedFitnessJourney journey;

  @override
  State<FitnessRouteDetailPage> createState() => _FitnessRouteDetailPageState();
}

class _FitnessRouteDetailPageState extends State<FitnessRouteDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FitnessController>().loadJourneyRoute(widget.journey.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FitnessController>();
    final journey = widget.journey;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Route details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _JourneyHeader(journey: journey),
          const SizedBox(height: 16),
          FitnessHistoryRouteMap(
            journey: journey,
            routePoints: controller.routePointsFor(journey.id),
            isLoading: controller.isRouteLoading(journey.id),
            hasLoaded: controller.hasLoadedRoute(journey.id),
            errorMessage: controller.routeErrorFor(journey.id),
            onRetry: () =>
                controller.loadJourneyRoute(journey.id, forceRefresh: true),
          ),
          const SizedBox(height: 16),
          _RouteMetrics(journey: journey),
        ],
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.journey});

  final CompletedFitnessJourney journey;

  @override
  Widget build(BuildContext context) {
    final completed = journey.countsAsCompletedRoute;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.check_circle_rounded : Icons.flag_rounded,
                color: completed ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                completed ? 'Completed journey' : 'Journey ended early',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: completed ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LocationRow(
            markerColor: AppColors.primary,
            label: 'From',
            value: journey.originName ?? 'Saved starting point',
          ),
          Container(
            width: 2,
            height: 24,
            margin: const EdgeInsets.only(left: 7),
            color: AppColors.accent,
          ),
          _LocationRow(
            markerColor: completed ? AppColors.error : AppColors.warning,
            label: completed ? 'To' : 'Planned destination',
            value: journey.destinationName ?? 'Saved destination',
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.markerColor,
    required this.label,
    required this.value,
  });

  final Color markerColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 16, color: markerColor),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _RouteMetrics extends StatelessWidget {
  const _RouteMetrics({required this.journey});

  final CompletedFitnessJourney journey;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Expanded(
          child: _Metric(
            icon: Icons.route_rounded,
            value:
                '${(journey.walkingDistanceMeters / 1000).toStringAsFixed(2)} km',
            label: 'Distance',
          ),
        ),
        Expanded(
          child: _Metric(
            icon: Icons.local_fire_department_rounded,
            value: '${journey.estimatedCalories} kcal',
            label: 'Calories',
          ),
        ),
        Expanded(
          child: _Metric(
            icon: Icons.eco_rounded,
            value: '${journey.estimatedCarbonSavedKg.toStringAsFixed(2)} kg',
            label: 'CO₂ saved',
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 8, color: AppColors.textSecondary),
      ),
    ],
  );
}
