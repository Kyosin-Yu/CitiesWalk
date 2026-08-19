import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_journey.dart';
import '../../business_logic/entities/eco_journey_history_item.dart';
import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/entities/eco_place_category.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/providers/eco_route_controller.dart';
import '../widgets/destination_card.dart';
import '../widgets/eco_metric_card.dart';
import '../widgets/eco_route_map.dart';
import '../widgets/nearby_places_map.dart';
import '../widgets/route_step_tile.dart';

class EcoRoutePage extends StatefulWidget {
  const EcoRoutePage({super.key, this.onJourneyCompleted, this.tripToReplan});

  final VoidCallback? onJourneyCompleted;
  final ValueListenable<EcoJourneyHistoryItem?>? tripToReplan;

  @override
  State<EcoRoutePage> createState() => _EcoRoutePageState();
}

class _EcoRoutePageState extends State<EcoRoutePage> {
  @override
  void initState() {
    super.initState();
    widget.tripToReplan?.addListener(_replanSavedJourney);
    WidgetsBinding.instance.addPostFrameCallback((_) => _replanSavedJourney());
  }

  @override
  void didUpdateWidget(covariant EcoRoutePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripToReplan == widget.tripToReplan) return;
    oldWidget.tripToReplan?.removeListener(_replanSavedJourney);
    widget.tripToReplan?.addListener(_replanSavedJourney);
  }

  @override
  void dispose() {
    widget.tripToReplan?.removeListener(_replanSavedJourney);
    super.dispose();
  }

  void _replanSavedJourney() {
    final journey = widget.tripToReplan?.value;
    if (journey == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EcoRouteController>().replanJourney(journey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Consumer<EcoRouteController>(
              builder: (context, controller, _) => _EcoRouteHeader(
                showBack: controller.route != null,
                onBack: controller.clearRoute,
              ),
            ),
            Expanded(
              child: Consumer<EcoRouteController>(
                builder: (context, controller, _) {
                  if (!controller.hasInitialised) {
                    return _LocationSetup(
                      message: controller.message,
                      onUseCurrentLocation: () => controller.initialise(),
                      onChooseStartingPoint: () =>
                          controller.initialise(useDeviceLocation: false),
                    );
                  }

                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OriginCard(
                            label: controller.origin.label,
                            title: controller.originTitle,
                            isLiveLocation: controller.hasDeviceLocation,
                            onRefreshGps: controller.refreshDeviceLocation,
                          ),
                          if (controller.message != null) ...[
                            const SizedBox(height: 12),
                            _NoticeCard(message: controller.message!),
                          ],
                          const SizedBox(height: 24),
                          if (controller.isLoadingRoute) ...[
                            const _RouteLoadingBanner(),
                            const SizedBox(height: 16),
                          ],
                          if (controller.route != null) ...[
                            _InlineRouteDetails(
                              route: controller.route!,
                              journey: controller.journey,
                              onStart: () async {
                                await controller.startJourney();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Journey started. Your calories and CO₂ savings are being tracked.',
                                    ),
                                  ),
                                );
                              },
                              onEnd: () async {
                                await controller.endJourney();
                                if (controller.journey?.status ==
                                    EcoJourneyStatus.completed) {
                                  widget.onJourneyCompleted?.call();
                                }
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Journey ended. Your eco-trip summary is ready.',
                                    ),
                                  ),
                                );
                              },
                              onPause: controller.pauseJourney,
                              onResume: controller.resumeJourney,
                              currentLocation:
                                  controller.currentJourneyLocation,
                              trackedDistanceKm: controller.trackedDistanceKm,
                              remainingDistanceKm:
                                  controller.remainingDistanceKm,
                              liveCaloriesBurned: controller.liveCaloriesBurned,
                              liveCarbonSavedKg: controller.liveCarbonSavedKg,
                              nextInstruction: controller.nextInstruction,
                              onPlanAnotherRoute: controller.clearRoute,
                            ),
                          ] else ...[
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
                            _DestinationCategoryBar(
                              selected: controller.selectedCategory,
                              onSelected: controller.selectCategory,
                            ),
                            if (controller.isLoadingDestinations) ...[
                              const SizedBox(height: 10),
                              const LinearProgressIndicator(),
                            ],
                            const SizedBox(height: 12),
                            NearbyPlacesMap(
                              origin: controller.origin,
                              destinations: controller.destinations,
                              showMyLocation: controller.hasDeviceLocation,
                              originIsDeviceLocation:
                                  controller.hasDeviceLocation,
                              showOriginMarker: controller.hasUsableOrigin,
                              onDestinationSelected: (destination) async {
                                await controller.selectDestination(destination);
                              },
                              onStartingPointSelected:
                                  controller.setStartingPoint,
                            ),
                            const SizedBox(height: 24),
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
                                IconButton(
                                  onPressed: () =>
                                      _showCategoryFilter(context, controller),
                                  tooltip: 'Filter recommended places',
                                  icon: const Icon(
                                    Icons.tune_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
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
                                  onTap: () async {
                                    await controller.selectDestination(
                                      destination,
                                    );

                                    if (!context.mounted) return;

                                    final route = controller.route;
                                    if (route == null ||
                                        route.destination.id !=
                                            destination.id) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to create this route. Please try another place.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ],
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
  Future<void> _showCategoryFilter(
    BuildContext context,
    EcoRouteController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _DestinationFilterSheet(
        selected: controller.selectedCategory,
        onSelected: (category) async {
          Navigator.of(sheetContext).pop();
          await controller.selectCategory(category);
        },
      ),
    );
  }
}

class _EcoRouteHeader extends StatelessWidget {
  const _EcoRouteHeader({required this.showBack, required this.onBack});

  final bool showBack;
  final VoidCallback onBack;

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
              if (showBack)
                IconButton(
                  onPressed: onBack,
                  tooltip: 'Back to places',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              else
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
              if (!showBack)
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
  const _LocationSetup({
    required this.message,
    required this.onUseCurrentLocation,
    required this.onChooseStartingPoint,
  });

  final String? message;
  final Future<void> Function() onUseCurrentLocation;
  final Future<void> Function() onChooseStartingPoint;

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
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onUseCurrentLocation,
                icon: const Icon(Icons.location_searching_rounded),
                label: const Text('Use my current location'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onChooseStartingPoint,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Choose a starting point instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OriginCard extends StatelessWidget {
  const _OriginCard({
    required this.label,
    required this.title,
    required this.isLiveLocation,
    required this.onRefreshGps,
  });

  final String label;
  final String title;
  final bool isLiveLocation;
  final Future<void> Function() onRefreshGps;

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
                  title,
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
          IconButton(
            tooltip: 'Refresh GPS location',
            onPressed: onRefreshGps,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent.withValues(alpha: 0.22),
              foregroundColor: AppColors.primary,
            ),
            icon: Icon(
              isLiveLocation
                  ? Icons.gps_fixed_rounded
                  : Icons.my_location_rounded,
              size: 19,
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

// Kept temporarily while the single-page route flow is introduced.
// ignore: unused_element
class _EcoRouteDetailsPage extends StatelessWidget {
  const _EcoRouteDetailsPage({required this.route});

  final EcoRoute route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Your eco route')),
      body: Consumer<EcoRouteController>(
        builder: (context, controller, _) {
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
                  route: route,
                  journey: controller.journey,
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
                  onEnd: () {
                    controller.endJourney();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Journey ended. Your eco-trip summary is ready.',
                        ),
                      ),
                    );
                  },
                  onChangeRoute: controller.clearRoute,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InlineRouteDetails extends StatelessWidget {
  const _InlineRouteDetails({
    required this.route,
    required this.journey,
    required this.onStart,
    required this.onEnd,
    required this.onPause,
    required this.onResume,
    required this.currentLocation,
    required this.trackedDistanceKm,
    required this.remainingDistanceKm,
    required this.liveCaloriesBurned,
    required this.liveCarbonSavedKg,
    required this.nextInstruction,
    required this.onPlanAnotherRoute,
  });

  final EcoRoute route;
  final EcoJourney? journey;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final EcoLocation? currentLocation;
  final double trackedDistanceKm;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;
  final VoidCallback onPlanAnotherRoute;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text('Your eco route', style: _sectionTitle(context)),
          const Spacer(),
          TextButton.icon(
            onPressed: onPlanAnotherRoute,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: const Text('Change'),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _RoutePreview(
        route: route,
        journey: journey,
        onStart: onStart,
        onEnd: onEnd,
        onPause: onPause,
        onResume: onResume,
        currentLocation: currentLocation,
        trackedDistanceKm: trackedDistanceKm,
        remainingDistanceKm: remainingDistanceKm,
        liveCaloriesBurned: liveCaloriesBurned,
        liveCarbonSavedKg: liveCarbonSavedKg,
        nextInstruction: nextInstruction,
        onChangeRoute: onPlanAnotherRoute,
      ),
    ],
  );

  TextStyle _sectionTitle(BuildContext context) => GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.titleLarge,
    fontWeight: FontWeight.w700,
  );
}

class _DestinationCategoryBar extends StatelessWidget {
  const _DestinationCategoryBar({
    required this.selected,
    required this.onSelected,
  });

  final EcoPlaceCategory selected;
  final ValueChanged<EcoPlaceCategory> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: EcoPlaceCategory.values.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = EcoPlaceCategory.values[index];
        final isSelected = category == selected;
        return ChoiceChip(
          label: Text(category.label),
          selected: isSelected,
          onSelected: (_) => onSelected(category),
          avatar: Icon(
            _iconFor(category),
            size: 16,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: isSelected ? AppColors.primary : const Color(0x14000000),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );
      },
    ),
  );

  IconData _iconFor(EcoPlaceCategory category) => switch (category) {
    EcoPlaceCategory.all => Icons.explore_rounded,
    EcoPlaceCategory.food => Icons.restaurant_rounded,
    EcoPlaceCategory.attractions => Icons.camera_alt_rounded,
    EcoPlaceCategory.history => Icons.account_balance_rounded,
    EcoPlaceCategory.parks => Icons.park_rounded,
    EcoPlaceCategory.museums => Icons.museum_rounded,
    EcoPlaceCategory.markets => Icons.storefront_rounded,
  };
}

class _DestinationFilterSheet extends StatelessWidget {
  const _DestinationFilterSheet({
    required this.selected,
    required this.onSelected,
  });

  final EcoPlaceCategory selected;
  final ValueChanged<EcoPlaceCategory> onSelected;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter nearby places',
            style: GoogleFonts.poppins(
              textStyle: Theme.of(context).textTheme.titleLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose what you would like to explore.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: EcoPlaceCategory.values.map((category) {
              final isSelected = category == selected;
              return ChoiceChip(
                label: Text(category.label),
                selected: isSelected,
                onSelected: (_) => onSelected(category),
                avatar: Icon(
                  _categoryIcon(category),
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0x14000000),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );

  IconData _categoryIcon(EcoPlaceCategory category) => switch (category) {
    EcoPlaceCategory.all => Icons.explore_rounded,
    EcoPlaceCategory.food => Icons.restaurant_rounded,
    EcoPlaceCategory.attractions => Icons.camera_alt_rounded,
    EcoPlaceCategory.history => Icons.account_balance_rounded,
    EcoPlaceCategory.parks => Icons.park_rounded,
    EcoPlaceCategory.museums => Icons.museum_rounded,
    EcoPlaceCategory.markets => Icons.storefront_rounded,
  };
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
    required this.journey,
    required this.onStart,
    required this.onEnd,
    this.onPause,
    this.onResume,
    this.currentLocation,
    this.trackedDistanceKm = 0,
    this.remainingDistanceKm = 0,
    this.liveCaloriesBurned = 0,
    this.liveCarbonSavedKg = 0,
    this.nextInstruction,
    required this.onChangeRoute,
  });

  final EcoRoute route;
  final EcoJourney? journey;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final EcoLocation? currentLocation;
  final double trackedDistanceKm;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;
  final VoidCallback onChangeRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteOverview(route: route),
        const SizedBox(height: 12),
        _RouteEndpointsCard(route: route, onChangeRoute: onChangeRoute),
        const SizedBox(height: 12),
        EcoRouteMap(route: route, currentLocation: currentLocation),
        if (journey?.status == EcoJourneyStatus.inProgress ||
            journey?.status == EcoJourneyStatus.paused) ...[
          const SizedBox(height: 12),
          _LiveJourneyCard(
            isPaused: journey?.status == EcoJourneyStatus.paused,
            trackedDistanceKm: trackedDistanceKm,
            remainingDistanceKm: remainingDistanceKm,
            liveCaloriesBurned: liveCaloriesBurned,
            liveCarbonSavedKg: liveCarbonSavedKg,
            nextInstruction: nextInstruction,
          ),
        ],
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
        if (journey == null)
          ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.navigation_rounded),
            label: const Text('Start journey'),
          )
        else ...[
          ElevatedButton.icon(
            onPressed: journey?.status == EcoJourneyStatus.completed
                ? null
                : onEnd,
            icon: Icon(
              journey?.status == EcoJourneyStatus.completed
                  ? Icons.check_circle_outline_rounded
                  : Icons.stop_circle_outlined,
            ),
            label: Text(
              journey?.status == EcoJourneyStatus.completed
                  ? 'Journey completed'
                  : 'End journey',
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (journey?.status == EcoJourneyStatus.inProgress)
          OutlinedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause_circle_outline_rounded),
            label: const Text('Pause tracking'),
          )
        else if (journey?.status == EcoJourneyStatus.paused)
          ElevatedButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Resume tracking'),
          ),
      ],
    );
  }

  TextStyle _sectionTitle(BuildContext context) => GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.titleLarge,
    fontWeight: FontWeight.w700,
  );
}

class _LiveJourneyCard extends StatelessWidget {
  const _LiveJourneyCard({
    required this.isPaused,
    required this.trackedDistanceKm,
    required this.remainingDistanceKm,
    required this.liveCaloriesBurned,
    required this.liveCarbonSavedKg,
    required this.nextInstruction,
  });

  final bool isPaused;
  final double trackedDistanceKm;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE5F4E7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isPaused ? Icons.pause_circle_rounded : Icons.gps_fixed_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isPaused ? 'Tracking paused' : 'Live journey tracking',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${trackedDistanceKm.toStringAsFixed(2)} km covered · ${remainingDistanceKm.toStringAsFixed(1)} km route remaining',
        ),
        const SizedBox(height: 4),
        Text(
          '${liveCaloriesBurned.round()} kcal walking · ${liveCarbonSavedKg.toStringAsFixed(2)} kg CO₂ saved',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        if (nextInstruction != null) ...[
          const SizedBox(height: 6),
          Text(
            'Next: $nextInstruction',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ],
    ),
  );
}

class _RouteEndpointsCard extends StatelessWidget {
  const _RouteEndpointsCard({required this.route, required this.onChangeRoute});

  final EcoRoute route;
  final VoidCallback onChangeRoute;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
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
    child: Row(
      children: [
        Column(
          children: [
            const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            Container(width: 2, height: 22, color: const Color(0xFFB8DDBB)),
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EndpointLabel(label: 'FROM', value: route.origin.label),
              const Divider(height: 16),
              _EndpointLabel(label: 'TO', value: route.destination.name),
            ],
          ),
        ),
        IconButton(
          onPressed: onChangeRoute,
          tooltip: 'Change start or destination',
          icon: const Icon(Icons.edit_location_alt_outlined),
        ),
      ],
    ),
  );
}

class _EndpointLabel extends StatelessWidget {
  const _EndpointLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 1),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ],
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
                  route.hasTransit
                      ? 'Train and walking only'
                      : 'Walking route — no rail required',
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
