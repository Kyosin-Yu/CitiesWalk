import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business/models/eco_route.dart';
import '../controllers/eco_route_controller.dart';
import '../widgets/destination_card.dart';
import '../widgets/eco_metric_card.dart';
import '../widgets/route_step_tile.dart';

class EcoRoutePage extends StatelessWidget {
  const EcoRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eco Route')),
      body: Consumer<EcoRouteController>(
        builder: (context, controller, _) {
          if (!controller.hasInitialised) {
            return _LocationSetup(onContinue: controller.initialise);
          }

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.initialise,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _OriginCard(label: controller.origin.label),
                if (controller.message != null) ...[
                  const SizedBox(height: 12),
                  _NoticeCard(message: controller.message!),
                ],
                const SizedBox(height: 20),
                Text(
                  'Where would you like to explore?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a destination to see a train-and-walk route.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: controller.searchDestinations,
                  decoration: const InputDecoration(
                    hintText: 'Search parks, food, landmarks…',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Suggested destinations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (controller.destinations.isEmpty)
                  const _EmptyDestinations()
                else
                  ...controller.destinations.map(
                    (destination) => DestinationCard(
                      destination: destination,
                      onTap: () => controller.selectDestination(destination),
                    ),
                  ),
                if (controller.isLoadingRoute) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (controller.route != null) ...[
                  const SizedBox(height: 20),
                  _RoutePreview(
                    route: controller.route!,
                    journeyStarted: controller.journey != null,
                    onStart: () {
                      controller.startJourney();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Journey started. Live tracking will be added after the shared journey database is confirmed.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LocationSetup extends StatelessWidget {
  const _LocationSetup({required this.onContinue});

  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start from where you are',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'CitiesWalk uses your location only to create walking and public-transport routes from your current position.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Use my current location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OriginCard extends StatelessWidget {
  const _OriginCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), AppColors.primary],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Starting from',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _EmptyDestinations extends StatelessWidget {
  const _EmptyDestinations();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text('No destinations match your search yet.')),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  const _RoutePreview({
    required this.route,
    required this.journeyStarted,
    required this.onStart,
  });

  final EcoRoute route;
  final bool journeyStarted;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route to ${route.destination.name}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Sample route preview — train and walking only.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 360 ? 1 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 1 ? 3.2 : 1.25,
              children: [
                EcoMetricCard(
                  icon: Icons.schedule_rounded,
                  value: '${route.durationMinutes} min',
                  label: 'Estimated travel time',
                ),
                EcoMetricCard(
                  icon: Icons.train_rounded,
                  value: route.recommendedPlatform ?? '—',
                  label: 'Recommended platform',
                ),
                EcoMetricCard(
                  icon: Icons.directions_walk_rounded,
                  value: '${route.walkingDistanceKm.toStringAsFixed(1)} km',
                  label: 'Walking distance',
                ),
                EcoMetricCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '${route.estimatedCalories} kcal',
                  label: 'Expected calories burned',
                ),
                EcoMetricCard(
                  icon: Icons.eco_outlined,
                  value:
                      '${route.estimatedCarbonSavedKg.toStringAsFixed(1)} kg',
                  label: 'Estimated CO₂ savings',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Step-by-step guide',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...route.segments.indexed.map(
          (entry) => RouteStepTile(segment: entry.$2, index: entry.$1),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: journeyStarted ? null : onStart,
          icon: Icon(
            journeyStarted
                ? Icons.check_circle_outline
                : Icons.play_arrow_rounded,
          ),
          label: Text(journeyStarted ? 'Journey started' : 'Start journey'),
        ),
      ],
    );
  }
}
