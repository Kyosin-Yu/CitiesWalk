import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/providers/eco_route_controller.dart';
import '../widgets/destination_card.dart';
import '../widgets/eco_metric_card.dart';
import '../widgets/eco_route_map.dart';
import '../widgets/nearby_places_map.dart';
import '../widgets/route_step_tile.dart';

class EcoRoutePage extends StatelessWidget {
  const EcoRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _EcoRouteHeader(),
            Expanded(
              child: Consumer<EcoRouteController>(
                builder: (context, controller, _) {
                  if (!controller.hasInitialised) {
                    return _LocationSetup(onContinue: controller.initialise);
                  }

                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: controller.initialise,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OriginCard(label: controller.origin.label),
                            if (controller.message != null) ...[
                              const SizedBox(height: 12),
                              _NoticeCard(message: controller.message!),
                            ],
                            const SizedBox(height: 24),
                            if (controller.route == null) ...[
                              Text(
                                'Explore near you',
                                style: _sectionTitle(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your current location and places to discover.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              NearbyPlacesMap(
                                origin: controller.origin,
                                destinations: controller.destinations,
                              ),
                              const SizedBox(height: 24),
                            ],
                            Text(
                              'Choose your next stop',
                              style: _sectionTitle(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Explore Kuala Lumpur by rail and on foot.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 14),
                            _DestinationSearch(
                              onChanged: controller.searchDestinations,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Recommended for you',
                                  style: _sectionTitle(context),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.tune_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (controller.destinations.isEmpty)
                              const _EmptyDestinations()
                            else
                              ...controller.destinations.map(
                                (destination) => DestinationCard(
                                  destination: destination,
                                  onTap: () {
                                    final navigator = Navigator.of(context);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (!context.mounted) return;
                                          navigator.push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ChangeNotifierProvider.value(
                                                    value: controller,
                                                    child: _EcoRouteDetailsPage(
                                                      destination: destination,
                                                    ),
                                                  ),
                                            ),
                                          );
                                        });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitle(BuildContext context) => GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.titleLarge,
    fontWeight: FontWeight.w700,
  );
}

class _EcoRouteHeader extends StatelessWidget {
  const _EcoRouteHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(right: -34, top: -66, child: _ring(156)),
          Positioned(right: 22, top: -34, child: _ring(100)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.explore_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eco Route',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your greener way to explore',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Rail + walk',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Text(
              'Plan a low-carbon city journey',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
  );
}

class _LocationSetup extends StatelessWidget {
  const _LocationSetup({required this.onContinue});

  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
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
                  Icons.my_location_rounded,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start from where you are',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.headlineMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use your current location to plan a train-and-walk journey with less carbon.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.location_searching_rounded),
                label: const Text('Use my current location'),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.my_location_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT LOCATION',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 17,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationSearch extends StatelessWidget {
  const _DestinationSearch({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search parks, food, landmarks…',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
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
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(16),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.travel_explore_rounded, color: AppColors.primary),
          SizedBox(height: 8),
          Text('No destinations match your search yet.'),
        ],
      ),
    );
  }
}

class _EcoRouteDetailsPage extends StatefulWidget {
  const _EcoRouteDetailsPage({required this.destination});

  final EcoDestination destination;

  @override
  State<_EcoRouteDetailsPage> createState() => _EcoRouteDetailsPageState();
}

class _EcoRouteDetailsPageState extends State<_EcoRouteDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EcoRouteController>().selectDestination(
          widget.destination,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Your eco route')),
      body: Consumer<EcoRouteController>(
        builder: (context, controller, _) {
          final route = controller.route;
          final hasRequestedRoute =
              route?.destination.id == widget.destination.id;

          if (!hasRequestedRoute) {
            return const _RouteLoadingView();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isLoadingRoute) ...[
                  const _RouteLoadingBanner(),
                  const SizedBox(height: 16),
                ],
                _RoutePreview(
                  route: route!,
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
            ),
          );
        },
      ),
    );
  }
}

class _RouteLoadingView extends StatelessWidget {
  const _RouteLoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Creating your train-and-walk route…'),
      ],
    ),
  );
}

class _RouteLoadingBanner extends StatelessWidget {
  const _RouteLoadingBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        SizedBox(width: 12),
        Expanded(child: Text('Mapping the walking paths…')),
      ],
    ),
  );
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
        _RouteOverview(route: route),
        const SizedBox(height: 12),
        EcoRouteMap(route: route),
        const SizedBox(height: 24),
        Text('Journey estimate', style: _sectionTitle(context)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 360 ? 1 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.4 : 1.32,
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
        const SizedBox(height: 24),
        Text('Your route', style: _sectionTitle(context)),
        const SizedBox(height: 10),
        ...route.segments.indexed.map(
          (entry) => RouteStepTile(segment: entry.$2, index: entry.$1),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: journeyStarted ? null : onStart,
          icon: Icon(
            journeyStarted
                ? Icons.check_circle_outline_rounded
                : Icons.navigation_rounded,
          ),
          label: Text(journeyStarted ? 'Journey started' : 'Start journey'),
        ),
      ],
    );
  }

  TextStyle _sectionTitle(BuildContext context) => GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.titleLarge,
    fontWeight: FontWeight.w700,
  );
}

class _RouteOverview extends StatelessWidget {
  const _RouteOverview({required this.route});

  final EcoRoute route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.route_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route to ${route.destination.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Train and walking only',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${route.durationMinutes} min',
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
