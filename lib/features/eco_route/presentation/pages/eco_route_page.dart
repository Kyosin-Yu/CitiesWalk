import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/destination_review_summary.dart';
import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_journey.dart';
import '../../business_logic/entities/eco_journey_history_item.dart';
import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/entities/eco_nearby_distance.dart';
import '../../business_logic/entities/eco_place_category.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/providers/eco_route_controller.dart';
import '../widgets/destination_card.dart';
import '../widgets/eco_metric_card.dart';
import '../widgets/eco_route_map.dart';
import '../widgets/nearby_places_map.dart';
import '../widgets/route_step_tile.dart';
import 'journey_summary_page.dart';

class EcoRoutePage extends StatefulWidget {
  const EcoRoutePage({
    super.key,
    this.onJourneyCompleted,
    this.tripToReplan,
    this.destinationToPlan,
    this.reviewSummaryRefreshSignal,
    this.onOpenReviews,
    this.onViewFitness,
  });

  final VoidCallback? onJourneyCompleted;
  final ValueListenable<EcoJourneyHistoryItem?>? tripToReplan;
  final ValueNotifier<EcoDestination?>? destinationToPlan;
  final ValueListenable<int>? reviewSummaryRefreshSignal;
  final ValueChanged<EcoDestination>? onOpenReviews;
  final VoidCallback? onViewFitness;

  @override
  State<EcoRoutePage> createState() => _EcoRoutePageState();
}

class _EcoRoutePageState extends State<EcoRoutePage>
    with WidgetsBindingObserver {
  String? _shownJourneySummaryId;
  bool _showActiveTracking = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.tripToReplan?.addListener(_replanSavedJourney);
    widget.destinationToPlan?.addListener(_planHomeDestination);
    widget.reviewSummaryRefreshSignal?.addListener(_refreshReviewSummaries);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _replanSavedJourney();
      _planHomeDestination();
    });
  }

  @override
  void didUpdateWidget(covariant EcoRoutePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripToReplan != widget.tripToReplan) {
      oldWidget.tripToReplan?.removeListener(_replanSavedJourney);
      widget.tripToReplan?.addListener(_replanSavedJourney);
    }
    if (oldWidget.destinationToPlan != widget.destinationToPlan) {
      oldWidget.destinationToPlan?.removeListener(_planHomeDestination);
      widget.destinationToPlan?.addListener(_planHomeDestination);
    }
    if (oldWidget.reviewSummaryRefreshSignal !=
        widget.reviewSummaryRefreshSignal) {
      oldWidget.reviewSummaryRefreshSignal?.removeListener(
        _refreshReviewSummaries,
      );
      widget.reviewSummaryRefreshSignal?.addListener(_refreshReviewSummaries);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.tripToReplan?.removeListener(_replanSavedJourney);
    widget.destinationToPlan?.removeListener(_planHomeDestination);
    widget.reviewSummaryRefreshSignal?.removeListener(_refreshReviewSummaries);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      unawaited(context.read<EcoRouteController>().retryLocationAfterSettings());
    }
  }

  void _replanSavedJourney() {
    final journey = widget.tripToReplan?.value;
    if (journey == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EcoRouteController>().replanJourney(journey);
    });
  }

  void _refreshReviewSummaries() {
    if (!mounted) return;
    context.read<EcoRouteController>().refreshDestinationReviewSummaries();
  }

  void _planHomeDestination() {
    final destination = widget.destinationToPlan?.value;
    if (destination == null) return;
    widget.destinationToPlan!.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EcoRouteController>().requestRouteToDestination(destination);
    });
  }

  Future<void> _startTracking(EcoRouteController controller) async {
    await controller.startJourney();
    if (!mounted || controller.journey?.status != EcoJourneyStatus.inProgress) {
      return;
    }
    setState(() => _showActiveTracking = true);
  }

  void _showJourneySummaryWhenReady(EcoJourney journey) {
    final journeyId = journey.id;
    if (journeyId == null || _shownJourneySummaryId == journeyId) return;
    _shownJourneySummaryId = journeyId;
    _showActiveTracking = false;
    widget.onJourneyCompleted?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => JourneySummaryPage(
            journey: journey,
            onPlanAnotherJourney: () =>
                context.read<EcoRouteController>().clearRoute(),
            onViewFitness: widget.onViewFitness,
          ),
        ),
      );
    });
  }

  Future<void> _confirmCancellation(EcoRouteController controller) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this journey?'),
        content: const Text(
          'Your unfinished journey, route steps, and GPS tracking points will be removed. It will not appear in history or analytics.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep tracking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel journey'),
          ),
        ],
      ),
    );
    if (shouldCancel == true) await controller.cancelJourney();
  }

  Future<void> _confirmEndEarly(EcoRouteController controller) async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End journey early?'),
        content: const Text(
          'Tracking will stop now. Your walking distance, estimated steps, calories, carbon savings, and journey summary will be saved as an incomplete trip. It will not count toward Fitness totals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep tracking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('End journey'),
          ),
        ],
      ),
    );
    if (shouldEnd != true) return;

    final didEndEarly = await controller.endJourneyEarly();
    if (!mounted || didEndEarly) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.message ??
              'Unable to save this early-ended journey. Please try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showActiveTracking,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showActiveTracking) {
          setState(() => _showActiveTracking = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Consumer<EcoRouteController>(
                builder: (context, controller, _) {
                  final tracking =
                      controller.journey?.status == EcoJourneyStatus.inProgress;
                  return _EcoRouteHeader(
                    showBack: controller.route != null,
                    onBack: tracking
                        ? () => setState(() => _showActiveTracking = false)
                        : controller.clearRoute,
                  );
                },
              ),
              Expanded(
                child: Consumer<EcoRouteController>(
                  builder: (context, controller, _) {
                    final completedJourney = controller.journey;
                    if (completedJourney?.status ==
                            EcoJourneyStatus.completed ||
                        completedJourney?.status ==
                            EcoJourneyStatus.endedEarly) {
                      _showJourneySummaryWhenReady(completedJourney!);
                    }
                    if (!controller.hasInitialised) {
                      return _LocationSetup(
                        message: controller.message,
                        onUseCurrentLocation: () => controller.initialise(),
                        onOpenLocationSettings:
                            controller.canOpenLocationSettings
                            ? controller.openLocationAccessSettings
                            : null,
                        onChooseStartingPoint: () =>
                            controller.initialise(useDeviceLocation: false),
                      );
                    }

                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final activeJourney = controller.journey;
                    if (_showActiveTracking &&
                        controller.route != null &&
                        activeJourney?.status == EcoJourneyStatus.inProgress) {
                      return _ActiveJourneyTrackingView(
                        route: controller.route!,
                        currentLocation: controller.currentJourneyLocation,
                        trackedWalkingDistanceKm:
                            controller.trackedWalkingDistanceKm,
                        trackedTransitDistanceKm:
                            controller.trackedTransitDistanceKm,
                        estimatedStepCount: controller.estimatedStepCount,
                        remainingDistanceKm: controller.remainingDistanceKm,
                        liveCaloriesBurned: controller.liveCaloriesBurned,
                        liveCarbonSavedKg: controller.liveCarbonSavedKg,
                        nextInstruction: controller.nextInstruction,
                        journeyProgress: controller.journeyProgress,
                        isRerouting: controller.isRerouting,
                        isWalkingSpeedSuspicious:
                            controller.isWalkingSpeedSuspicious,
                        onMinimize: () =>
                            setState(() => _showActiveTracking = false),
                        onEndEarly: () => _confirmEndEarly(controller),
                        onCancel: () => _confirmCancellation(controller),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.applyNearbyFilters,
                      child: SingleChildScrollView(
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
                                onStart: () => _startTracking(controller),
                                onOpenTracking: () =>
                                    setState(() => _showActiveTracking = true),
                                currentLocation:
                                    controller.currentJourneyLocation,
                                trackedWalkingDistanceKm:
                                    controller.trackedWalkingDistanceKm,
                                trackedTransitDistanceKm:
                                    controller.trackedTransitDistanceKm,
                                estimatedStepCount:
                                    controller.estimatedStepCount,
                                remainingDistanceKm:
                                    controller.remainingDistanceKm,
                                liveCaloriesBurned:
                                    controller.liveCaloriesBurned,
                                liveCarbonSavedKg: controller.liveCarbonSavedKg,
                                nextInstruction: controller.nextInstruction,
                                journeyProgress: controller.journeyProgress,
                                isRerouting: controller.isRerouting,
                                isWalkingSpeedSuspicious:
                                    controller.isWalkingSpeedSuspicious,
                                onPlanAnotherRoute: controller.clearRoute,
                                reviewSummary:
                                    controller.selectedDestinationReviewSummary,
                                onOpenReviews: widget.onOpenReviews == null
                                    ? null
                                    : () => widget.onOpenReviews!(
                                        controller.route!.destination,
                                      ),
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
                                  await controller.selectDestination(
                                    destination,
                                  );
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Recommended for you',
                                          style: _sectionTitle(context),
                                        ),
                                        Text(
                                          'Places ${controller.selectedNearbyDistance.nearbyDescription} of your ${controller.hasDeviceLocation ? 'current location' : 'selected starting point'}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _showCategoryFilter(
                                      context,
                                      controller,
                                    ),
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
                                    nearbyDistanceKm: controller
                                        .nearbyDistanceKm(destination),
                                    reviewSummary: controller.reviewSummaryFor(
                                      destination,
                                    ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _DestinationFilterSheet(
        selectedCategory: controller.selectedCategory,
        selectedDistance: controller.selectedNearbyDistance,
        onApply: (category, distance) async {
          Navigator.of(sheetContext).pop();
          await controller.applyNearbyFilters(
            category: category,
            nearbyDistance: distance,
          );
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
    this.onOpenLocationSettings,
  });

  final String? message;
  final Future<void> Function() onUseCurrentLocation;
  final Future<void> Function() onChooseStartingPoint;
  final Future<void> Function()? onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight > 48
                ? constraints.maxHeight - 48
                : 0,
          ),
          child: Center(
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onUseCurrentLocation,
                    icon: const Icon(Icons.location_searching_rounded),
                    label: const Text('Use my current location'),
                  ),
                  if (onOpenLocationSettings != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onOpenLocationSettings,
                      icon: const Icon(Icons.location_on_rounded),
                      label: const Text('Turn on location'),
                    ),
                  ],
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

class _DestinationSearch extends StatefulWidget {
  const _DestinationSearch({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_DestinationSearch> createState() => _DestinationSearchState();
}

class _DestinationSearchState extends State<_DestinationSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch([String? value]) {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) {
      widget.onChanged('');
      return;
    }
    widget.onChanged(query);
  }

  void _handleChanged(String value) {
    if (value.trim().isEmpty) _submitSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      onSubmitted: _submitSearch,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search an address, park, food, landmark…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Search',
          onPressed: _submitSearch,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
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

class _InlineRouteDetails extends StatelessWidget {
  const _InlineRouteDetails({
    required this.route,
    required this.journey,
    required this.onStart,
    this.onOpenTracking,
    required this.currentLocation,
    required this.trackedWalkingDistanceKm,
    required this.trackedTransitDistanceKm,
    required this.estimatedStepCount,
    required this.remainingDistanceKm,
    required this.liveCaloriesBurned,
    required this.liveCarbonSavedKg,
    required this.nextInstruction,
    required this.journeyProgress,
    required this.isRerouting,
    required this.isWalkingSpeedSuspicious,
    required this.onPlanAnotherRoute,
    required this.reviewSummary,
    this.onOpenReviews,
  });

  final EcoRoute route;
  final EcoJourney? journey;
  final VoidCallback onStart;
  final VoidCallback? onOpenTracking;
  final EcoLocation? currentLocation;
  final double trackedWalkingDistanceKm;
  final double trackedTransitDistanceKm;
  final int estimatedStepCount;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;
  final double journeyProgress;
  final bool isRerouting;
  final bool isWalkingSpeedSuspicious;
  final VoidCallback onPlanAnotherRoute;
  final DestinationReviewSummary reviewSummary;
  final VoidCallback? onOpenReviews;

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
        onOpenTracking: onOpenTracking,
        currentLocation: currentLocation,
        trackedWalkingDistanceKm: trackedWalkingDistanceKm,
        trackedTransitDistanceKm: trackedTransitDistanceKm,
        estimatedStepCount: estimatedStepCount,
        remainingDistanceKm: remainingDistanceKm,
        liveCaloriesBurned: liveCaloriesBurned,
        liveCarbonSavedKg: liveCarbonSavedKg,
        nextInstruction: nextInstruction,
        journeyProgress: journeyProgress,
        isRerouting: isRerouting,
        isWalkingSpeedSuspicious: isWalkingSpeedSuspicious,
        onChangeRoute: onPlanAnotherRoute,
      ),
      const SizedBox(height: 12),
      _DestinationReviewBrief(summary: reviewSummary, onViewAll: onOpenReviews),
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
    EcoPlaceCategory.campus => Icons.school_rounded,
    EcoPlaceCategory.malls => Icons.local_mall_rounded,
    EcoPlaceCategory.transit => Icons.train_rounded,
  };
}

class _DestinationFilterSheet extends StatefulWidget {
  const _DestinationFilterSheet({
    required this.selectedCategory,
    required this.selectedDistance,
    required this.onApply,
  });

  final EcoPlaceCategory selectedCategory;
  final EcoNearbyDistance selectedDistance;
  final Future<void> Function(EcoPlaceCategory, EcoNearbyDistance) onApply;

  @override
  State<_DestinationFilterSheet> createState() =>
      _DestinationFilterSheetState();
}

class _DestinationFilterSheetState extends State<_DestinationFilterSheet> {
  late EcoPlaceCategory _category = widget.selectedCategory;
  late EcoNearbyDistance _distance = widget.selectedDistance;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        28 + MediaQuery.viewInsetsOf(context).bottom,
      ),
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
            'Choose what to explore and how far from your starting point.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Place type',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: EcoPlaceCategory.values.map((category) {
              final isSelected = category == _category;
              return ChoiceChip(
                label: Text(category.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _category = category);
                  }
                },
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
          const SizedBox(height: 20),
          Text(
            'Distance range',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Each range shows new places only, based on straight-line GPS distance.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: EcoNearbyDistance.values.map((distance) {
              final isSelected = distance == _distance;
              return ChoiceChip(
                label: Text(distance.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _distance = distance);
                  }
                },
                avatar: Icon(
                  Icons.near_me_outlined,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onApply(_category, _distance),
              icon: const Icon(Icons.tune_rounded),
              label: Text('Show places ${_distance.nearbyDescription}'),
            ),
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
    EcoPlaceCategory.campus => Icons.school_rounded,
    EcoPlaceCategory.malls => Icons.local_mall_rounded,
    EcoPlaceCategory.transit => Icons.train_rounded,
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
    this.onOpenTracking,
    this.currentLocation,
    this.trackedWalkingDistanceKm = 0,
    this.trackedTransitDistanceKm = 0,
    this.estimatedStepCount = 0,
    this.remainingDistanceKm = 0,
    this.liveCaloriesBurned = 0,
    this.liveCarbonSavedKg = 0,
    this.nextInstruction,
    this.journeyProgress = 0,
    this.isRerouting = false,
    this.isWalkingSpeedSuspicious = false,
    required this.onChangeRoute,
  });

  final EcoRoute route;
  final EcoJourney? journey;
  final VoidCallback onStart;
  final VoidCallback? onOpenTracking;
  final EcoLocation? currentLocation;
  final double trackedWalkingDistanceKm;
  final double trackedTransitDistanceKm;
  final int estimatedStepCount;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;
  final double journeyProgress;
  final bool isRerouting;
  final bool isWalkingSpeedSuspicious;
  final VoidCallback onChangeRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (journey == null) ...[
          _DestinationPreviewCard(destination: route.destination),
          const SizedBox(height: 12),
        ],
        _RouteOverview(route: route),
        const SizedBox(height: 12),
        _RouteEndpointsCard(route: route, onChangeRoute: onChangeRoute),
        const SizedBox(height: 12),
        EcoRouteMap(route: route, currentLocation: currentLocation),
        if (journey?.status == EcoJourneyStatus.inProgress) ...[
          const SizedBox(height: 12),
          _LiveJourneyCard(
            trackedWalkingDistanceKm: trackedWalkingDistanceKm,
            trackedTransitDistanceKm: trackedTransitDistanceKm,
            estimatedStepCount: estimatedStepCount,
            remainingDistanceKm: remainingDistanceKm,
            liveCaloriesBurned: liveCaloriesBurned,
            liveCarbonSavedKg: liveCarbonSavedKg,
            nextInstruction: nextInstruction,
            journeyProgress: journeyProgress,
            isRerouting: isRerouting,
            isWalkingSpeedSuspicious: isWalkingSpeedSuspicious,
            destinationName: route.destination.name,
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
        else if (journey?.status == EcoJourneyStatus.completed) ...[
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Journey completed'),
          ),
          const SizedBox(height: 10),
        ] else if (journey?.status == EcoJourneyStatus.endedEarly) ...[
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Journey ended early'),
          ),
          const SizedBox(height: 10),
        ] else if (journey?.status == EcoJourneyStatus.inProgress) ...[
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onOpenTracking,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('Open live tracking'),
          ),
        ],
      ],
    );
  }

  TextStyle _sectionTitle(BuildContext context) => GoogleFonts.poppins(
    textStyle: Theme.of(context).textTheme.titleLarge,
    fontWeight: FontWeight.w700,
  );
}

class _DestinationPreviewCard extends StatelessWidget {
  const _DestinationPreviewCard({required this.destination});

  final EcoDestination destination;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F4E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _categoryIcon(destination),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: .7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destination.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                destination.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  IconData _categoryIcon(EcoDestination value) {
    final category = value.category.toLowerCase();
    if (category.contains('food') || category.contains('market')) {
      return Icons.restaurant_rounded;
    }
    if (category.contains('park')) return Icons.park_rounded;
    if (category.contains('heritage') || category.contains('history')) {
      return Icons.account_balance_rounded;
    }
    return Icons.place_rounded;
  }
}

class _DestinationReviewBrief extends StatelessWidget {
  const _DestinationReviewBrief({required this.summary, this.onViewAll});

  final DestinationReviewSummary summary;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE4EAE5)),
    ),
    child: Row(
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF59A00), size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.hasReviews
                    ? '${summary.averageRating.toStringAsFixed(1)} community rating'
                    : 'Community reviews',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              Text(
                summary.hasReviews
                    ? 'Based on ${summary.reviewCount} traveller reviews'
                    : 'Be the first traveller to share feedback.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onViewAll, child: const Text('View all')),
      ],
    ),
  );
}

class _LiveJourneyCard extends StatelessWidget {
  const _LiveJourneyCard({
    required this.trackedWalkingDistanceKm,
    required this.trackedTransitDistanceKm,
    required this.estimatedStepCount,
    required this.remainingDistanceKm,
    required this.liveCaloriesBurned,
    required this.liveCarbonSavedKg,
    required this.nextInstruction,
    required this.journeyProgress,
    required this.isRerouting,
    required this.isWalkingSpeedSuspicious,
    required this.destinationName,
  });

  final double trackedWalkingDistanceKm;
  final double trackedTransitDistanceKm;
  final int estimatedStepCount;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;
  final double journeyProgress;
  final bool isRerouting;
  final bool isWalkingSpeedSuspicious;
  final String destinationName;

  @override
  Widget build(BuildContext context) {
    final percentage = (journeyProgress * 100).round();
    final encouragement = journeyProgress < .25
        ? 'Great start — every step makes this trip cleaner.'
        : journeyProgress < .75
        ? 'You are building a healthier, lower-carbon city journey.'
        : 'You are close — keep following the route to complete your quest.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isWalkingSpeedSuspicious
                      ? Icons.speed_rounded
                      : isRerouting
                      ? Icons.route_rounded
                      : Icons.directions_walk_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWalkingSpeedSuspicious
                          ? 'Walking pace check'
                          : isRerouting
                          ? 'Refreshing your route'
                          : 'Active city quest',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Reach $destinationName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: journeyProgress,
              minHeight: 9,
              color: AppColors.primary,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${remainingDistanceKm.toStringAsFixed(1)} km remaining · $encouragement',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _LiveQuestMetric(
                icon: Icons.directions_walk_rounded,
                value: '${trackedWalkingDistanceKm.toStringAsFixed(2)} km',
                label: 'Walked',
              ),
              _LiveQuestMetric(
                icon: Icons.directions_run_rounded,
                value: '$estimatedStepCount',
                label: 'Est. steps',
              ),
              _LiveQuestMetric(
                icon: Icons.local_fire_department_outlined,
                value: '${liveCaloriesBurned.round()} kcal',
                label: 'Burned',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .74),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isWalkingSpeedSuspicious
                  ? 'Movement is faster than walking. Walking distance, steps and calories are paused until a normal walking pace is detected.'
                  : nextInstruction == null
                  ? 'GPS is tracking your progress and route position.'
                  : 'Next step: $nextInstruction',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${trackedTransitDistanceKm.toStringAsFixed(2)} km by transit · ${liveCarbonSavedKg.toStringAsFixed(2)} kg CO₂ saved so far',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveQuestMetric extends StatelessWidget {
  const _LiveQuestMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _ActiveJourneyTrackingView extends StatelessWidget {
  const _ActiveJourneyTrackingView({
    required this.route,
    required this.currentLocation,
    required this.trackedWalkingDistanceKm,
    required this.trackedTransitDistanceKm,
    required this.estimatedStepCount,
    required this.remainingDistanceKm,
    required this.liveCaloriesBurned,
    required this.liveCarbonSavedKg,
    required this.nextInstruction,
    required this.journeyProgress,
    required this.isRerouting,
    required this.isWalkingSpeedSuspicious,
    required this.onMinimize,
    required this.onEndEarly,
    required this.onCancel,
  });

  final EcoRoute route;
  final EcoLocation? currentLocation;
  final double trackedWalkingDistanceKm;
  final double trackedTransitDistanceKm;
  final int estimatedStepCount;
  final double remainingDistanceKm;
  final double liveCaloriesBurned;
  final double liveCarbonSavedKg;
  final String? nextInstruction;
  final double journeyProgress;
  final bool isRerouting;
  final bool isWalkingSpeedSuspicious;
  final VoidCallback onMinimize;
  final VoidCallback onEndEarly;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live journey tracking',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Stay on the route; arrival is detected automatically.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Minimize tracking',
            onPressed: onMinimize,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
      const SizedBox(height: 14),
      EcoRouteMap(route: route, currentLocation: currentLocation),
      const SizedBox(height: 14),
      _LiveJourneyCard(
        trackedWalkingDistanceKm: trackedWalkingDistanceKm,
        trackedTransitDistanceKm: trackedTransitDistanceKm,
        estimatedStepCount: estimatedStepCount,
        remainingDistanceKm: remainingDistanceKm,
        liveCaloriesBurned: liveCaloriesBurned,
        liveCarbonSavedKg: liveCarbonSavedKg,
        nextInstruction: nextInstruction,
        journeyProgress: journeyProgress,
        isRerouting: isRerouting,
        isWalkingSpeedSuspicious: isWalkingSpeedSuspicious,
        destinationName: route.destination.name,
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You can switch CitiesWalk tabs or minimize this screen without cancelling. Keep the app open while you want live GPS updates.',
                style: GoogleFonts.poppins(fontSize: 11, height: 1.35),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: onEndEarly,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warning,
          side: const BorderSide(color: AppColors.warning),
        ),
        icon: const Icon(Icons.stop_circle_outlined),
        label: const Text('End journey early'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancel journey'),
      ),
    ],
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
