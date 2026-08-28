import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../../core/models/destination_review_summary.dart';
import '../../../../core/services/destination_review_summary_service.dart';
import '../entities/eco_destination.dart';
import '../entities/eco_journey.dart';
import '../entities/eco_journey_history_item.dart';
import '../entities/eco_location.dart';
import '../entities/eco_nearby_distance.dart';
import '../entities/eco_place_category.dart';
import '../entities/eco_route.dart';
import '../entities/eco_route_segment.dart';
import '../repositories/eco_route_repository.dart';
import '../repositories/journey_repository.dart';
import '../services/location_service.dart';

enum _LocationSettingsAction { deviceLocation, appSettings }

class EcoRouteController extends ChangeNotifier {
  EcoRouteController({
    required this.userId,
    required this.repository,
    required this.journeyRepository,
    required this.locationService,
    this.reviewSummaryService,
  });

  final String userId;
  final EcoRouteRepository repository;
  final JourneyRepository journeyRepository;
  final LocationService locationService;
  final DestinationReviewSummaryService? reviewSummaryService;

  static const _fallbackLocation = EcoLocation(
    latitude: 3.1340,
    longitude: 101.6869,
    label: 'KL Sentral',
  );

  bool _isLoading = true;
  bool _hasInitialised = false;
  bool _isLoadingRoute = false;
  String? _message;
  EcoLocation _origin = _fallbackLocation;
  List<EcoDestination> _destinations = const [];
  EcoPlaceCategory _selectedCategory = EcoPlaceCategory.all;
  EcoNearbyDistance _selectedNearbyDistance = EcoNearbyDistance.oneKm;
  bool _isLoadingDestinations = false;
  EcoRoute? _route;
  EcoJourney? _journey;
  StreamSubscription<EcoLocation>? _locationSubscription;
  bool _isUsingDeviceLocation = false;
  bool _hasUsableOrigin = false;
  EcoLocation? _currentJourneyLocation;
  EcoLocation? _lastTrackedLocation;
  DateTime? _lastTrackedAt;
  EcoLocation? _lastPersistedLocation;
  double _trackedDistanceKm = 0;
  double _trackedWalkingDistanceKm = 0;
  double _trackedTransitDistanceKm = 0;
  int _estimatedStepCount = 0;
  double _liveCaloriesBurned = 0;
  double _liveCarbonSavedKg = 0;
  bool _isRerouting = false;
  bool _isCompletingJourney = false;
  bool _arrivalConfirmed = false;
  bool _isWalkingSpeedSuspicious = false;
  int _consecutiveFastWalkingUpdates = 0;
  DateTime? _lastRerouteAt;
  EcoDestination? _pendingDestination;
  Map<String, DestinationReviewSummary> _reviewSummaries = const {};
  int _destinationSearchRequest = 0;
  _LocationSettingsAction? _locationSettingsAction;
  bool _retryLocationAfterSettings = false;

  static const _offRouteThresholdKm = 0.06;
  // GPS must be within 15 metres of the selected destination before the
  // journey can complete. This avoids finishing while the marker is still
  // visibly short of the destination.
  static const _arrivalThresholdKm = 0.015;
  static const _arrivalConfirmationDuration = Duration(milliseconds: 600);
  static const _walkingSpeedThresholdKmh = 12.0;
  static const _minimumSpeedSampleSeconds = 1.0;
  static const _fastWalkingUpdatesBeforePausing = 2;
  // Provisional MVP conversion for a GPS-derived walking estimate. This is
  // deliberately not presented as a hardware pedometer reading.
  static const _estimatedStepsPerWalkingKm = 1300;
  static const _rerouteCooldown = Duration(seconds: 90);

  bool get isLoading => _isLoading;
  bool get hasInitialised => _hasInitialised;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get message => _message;
  EcoLocation get origin => _origin;
  List<EcoDestination> get destinations => _destinations;
  EcoPlaceCategory get selectedCategory => _selectedCategory;
  EcoNearbyDistance get selectedNearbyDistance => _selectedNearbyDistance;
  bool get isLoadingDestinations => _isLoadingDestinations;
  EcoRoute? get route => _route;
  EcoJourney? get journey => _journey;
  bool get hasDeviceLocation => _isUsingDeviceLocation;
  bool get hasUsableOrigin => _hasUsableOrigin;
  EcoLocation? get currentJourneyLocation => _currentJourneyLocation;
  double get trackedDistanceKm => _trackedDistanceKm;
  double get trackedWalkingDistanceKm => _trackedWalkingDistanceKm;
  double get trackedTransitDistanceKm => _trackedTransitDistanceKm;
  int get estimatedStepCount => _estimatedStepCount;
  double get liveCaloriesBurned => _liveCaloriesBurned;
  double get liveCarbonSavedKg => _liveCarbonSavedKg;
  bool get isRerouting => _isRerouting;
  bool get isCompletingJourney => _isCompletingJourney;
  bool get isWalkingSpeedSuspicious => _isWalkingSpeedSuspicious;
  bool get canOpenLocationSettings => _locationSettingsAction != null;
  bool get isAtDestination {
    final route = _route;
    final location = _currentJourneyLocation;
    return route != null &&
        location != null &&
        _distanceBetween(location, route.destination.location) <=
            _arrivalThresholdKm;
  }

  DestinationReviewSummary reviewSummaryFor(EcoDestination destination) =>
      _reviewSummaries[destination.id] ?? DestinationReviewSummary.empty;

  /// Straight-line GPS distance used for the nearby recommendation bands.
  /// This is intentionally different from the walking or rail distance shown
  /// after a route has been planned.
  double nearbyDistanceKm(EcoDestination destination) =>
      _distanceBetween(_origin, destination.location);

  DestinationReviewSummary get selectedDestinationReviewSummary {
    final destination = _route?.destination;
    return destination == null
        ? DestinationReviewSummary.empty
        : reviewSummaryFor(destination);
  }

  double get remainingDistanceKm {
    final route = _route;
    if (route == null) return 0;
    return route.totalDistanceKm * (1 - journeyProgress);
  }

  double get journeyProgress {
    final route = _route;
    if (route == null || route.totalDistanceKm <= 0) return 0;
    if (_arrivalConfirmed ||
        (isAtDestination && !_isWalkingSpeedSuspicious)) {
      return 1;
    }
    final currentLocation = _currentJourneyLocation;
    if (currentLocation == null) return 0;
    final progress = _routeProgressAt(currentLocation);
    return _isWalkingSpeedSuspicious && isAtDestination
        ? math.min(progress, .99)
        : progress;
  }

  bool get isJourneyTracking => _journey?.status == EcoJourneyStatus.inProgress;
  String? get nextInstruction {
    final selectedRoute = _route;
    if (selectedRoute == null || !isJourneyTracking) return null;
    final progress = journeyProgress;
    final segmentIndex = (progress * selectedRoute.segments.length)
        .floor()
        .clamp(0, selectedRoute.segments.length - 1);
    final segment = selectedRoute.segments[segmentIndex];
    return segment.steps.isNotEmpty
        ? segment.steps.first.instruction
        : segment.detail;
  }

  String get originTitle => _isUsingDeviceLocation
      ? 'LIVE GPS LOCATION'
      : _hasUsableOrigin
      ? 'SELECTED STARTING POINT'
      : 'STARTING POINT NEEDED';

  Future<void> initialise({bool useDeviceLocation = true}) async {
    _isLoading = true;
    _hasInitialised = true;
    _message = null;
    _locationSettingsAction = null;
    _origin = _fallbackLocation;
    _isUsingDeviceLocation = false;
    _hasUsableOrigin = false;
    _resetLiveTracking();
    _lastRerouteAt = null;
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    notifyListeners();

    if (useDeviceLocation) {
      try {
        _origin = await locationService.getCurrentLocation();
        _isUsingDeviceLocation = true;
        _hasUsableOrigin = true;
        _startLocationTracking();
      } on LocationServiceException catch (error) {
        _locationSettingsAction = switch (error.failure) {
          LocationServiceFailure.servicesDisabled ||
          LocationServiceFailure.insufficientAccuracy =>
            _LocationSettingsAction.deviceLocation,
          LocationServiceFailure.permissionDeniedForever ||
          LocationServiceFailure.reducedAccuracy =>
            _LocationSettingsAction.appSettings,
          _ => null,
        };
        _isLoading = false;
        _hasInitialised = false;
        _message = '${error.message} Choose a starting point on the map.';
        notifyListeners();
        return;
      } catch (_) {
        _isLoading = false;
        _hasInitialised = false;
        _message =
            'Unable to read your GPS location. Choose a starting point on the map.';
        notifyListeners();
        return;
      }
    } else {
      _message =
          'The map is centred on Kuala Lumpur for selection only. Long-press your real starting point; it is not using KL Sentral as your location.';
    }

    try {
      await _loadNearbyDestinations();
    } catch (_) {
      _message = 'Destinations are unavailable right now. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDeviceLocation() => initialise();

  /// Opens the relevant settings screen after a location-access failure.
  /// The page retries GPS acquisition when the user returns to CitiesWalk.
  Future<void> openLocationAccessSettings() async {
    final action = _locationSettingsAction;
    if (action == null) return;
    _retryLocationAfterSettings = true;
    if (action == _LocationSettingsAction.deviceLocation) {
      await locationService.openLocationSettings();
    } else {
      await locationService.openAppSettings();
    }
  }

  Future<void> retryLocationAfterSettings() async {
    if (!_retryLocationAfterSettings) return;
    _retryLocationAfterSettings = false;
    await initialise();
  }

  Future<void> searchDestinations(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      await applyNearbyFilters();
      return;
    }

    final requestId = ++_destinationSearchRequest;
    _isLoadingDestinations = true;
    _message = null;
    notifyListeners();
    try {
      final destinations = await repository.searchDestinations(
        query: normalizedQuery,
        origin: _origin,
      );
      if (requestId != _destinationSearchRequest) return;

      _destinations = destinations;
      await _refreshDestinationReviewSummaries();
    } catch (_) {
      if (requestId == _destinationSearchRequest) {
        _message = 'Search is unavailable right now. Please try again.';
      }
    } finally {
      if (requestId == _destinationSearchRequest) {
        _isLoadingDestinations = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectCategory(EcoPlaceCategory category) async {
    await applyNearbyFilters(category: category);
  }

  Future<void> selectNearbyDistance(EcoNearbyDistance distance) async {
    await applyNearbyFilters(nearbyDistance: distance);
  }

  Future<void> applyNearbyFilters({
    EcoPlaceCategory? category,
    EcoNearbyDistance? nearbyDistance,
  }) async {
    ++_destinationSearchRequest;
    final selectedCategory = category ?? _selectedCategory;
    final selectedDistance = nearbyDistance ?? _selectedNearbyDistance;
    _selectedCategory = selectedCategory;
    _selectedNearbyDistance = selectedDistance;
    _isLoadingDestinations = true;
    _message = null;
    notifyListeners();
    try {
      await _loadNearbyDestinations();
    } catch (_) {
      _message =
          'Nearby ${selectedCategory.label.toLowerCase()} places ${selectedDistance.nearbyDescription} are unavailable right now.';
    } finally {
      _isLoadingDestinations = false;
      notifyListeners();
    }
  }

  Future<void> selectDestination(EcoDestination destination) async {
    final status = _journey?.status;
    if (status == EcoJourneyStatus.inProgress) {
      _message =
          'Finish or cancel the active journey before planning a different destination.';
      notifyListeners();
      return;
    }
    if (!_hasUsableOrigin) {
      _message = 'Long-press the map to choose your starting point first.';
      notifyListeners();
      return;
    }
    _isLoadingRoute = true;
    _message = null;
    notifyListeners();

    try {
      _route = await repository.buildRoute(
        origin: _origin,
        destination: destination,
      );
      await _refreshDestinationReviewSummaries();
    } catch (error) {
      _message = _routeErrorMessage(error);
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  /// Plans a destination received from Home or another app surface. A selected
  /// destination waits for a real GPS or user-chosen origin; it is never
  /// silently planned from the map's Kuala Lumpur fallback location.
  Future<void> requestRouteToDestination(EcoDestination destination) async {
    _pendingDestination = destination;
    if (!_hasInitialised) {
      await initialise();
    }
    if (!_hasUsableOrigin) return;

    final pending = _pendingDestination;
    _pendingDestination = null;
    if (pending != null) await selectDestination(pending);
  }

  Future<void> replanJourney(EcoJourneyHistoryItem journey) async {
    if (!_hasInitialised) {
      await initialise();
    }
    if (!_hasUsableOrigin) return;

    _route = null;
    _journey = null;
    _resetLiveTracking();
    _lastRerouteAt = null;
    notifyListeners();

    await selectDestination(
      EcoDestination(
        id: journey.id,
        name: journey.destinationName,
        category: journey.destinationCategory ?? 'Eco journey',
        description: 'Saved trip destination',
        location: EcoLocation(
          latitude: journey.destinationLatitude,
          longitude: journey.destinationLongitude,
          label: journey.destinationName,
        ),
      ),
    );
  }

  Future<void> setStartingPoint(EcoLocation location) async {
    _origin = location;
    _isUsingDeviceLocation = false;
    _hasUsableOrigin = true;
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _route = null;
    _journey = null;
    _resetLiveTracking();
    _lastRerouteAt = null;
    _message =
        'Starting point updated. Choose a destination to plan your route.';
    notifyListeners();

    try {
      await _loadNearbyDestinations();
    } catch (_) {
      _message = 'Starting point updated, but nearby places are unavailable.';
    }
    final pending = _pendingDestination;
    _pendingDestination = null;
    notifyListeners();
    if (pending != null) await selectDestination(pending);
  }

  void clearRoute() {
    final status = _journey?.status;
    if (status == EcoJourneyStatus.inProgress) {
      _message =
          'Journey tracking is still active. Return to tracking or cancel the journey to stop it.';
      notifyListeners();
      return;
    }
    _route = null;
    _journey = null;
    _resetLiveTracking();
    _lastRerouteAt = null;
    _message = null;
    notifyListeners();
  }

  /// Refreshes summary data after the Reviews feature changes a destination.
  Future<void> refreshDestinationReviewSummaries() async {
    await _refreshDestinationReviewSummaries();
    notifyListeners();
  }

  Future<void> _refreshDestinationReviewSummaries() async {
    final service = reviewSummaryService;
    if (service == null) {
      _reviewSummaries = const {};
      return;
    }

    final destinations = <EcoDestination>[
      ..._destinations,
      if (_route != null) _route!.destination,
    ];
    final summaries = await Future.wait(
      destinations.map(
        (destination) async => MapEntry(
          destination.id,
          await service.getDestinationReviewSummary(destination.id),
        ),
      ),
    );
    _reviewSummaries = Map.unmodifiable(Map.fromEntries(summaries));
  }

  Future<void> _loadNearbyDestinations() async {
    final fetchedDestinations = await repository.fetchNearbyDestinations(
      origin: _origin,
      category: _selectedCategory,
      nearbyDistance: _selectedNearbyDistance,
    );
    // Keep a client-side guard as well as the Edge Function filter. This
    // prevents an outdated deployed function or an API result outside the
    // requested ring from appearing under an incorrect distance label.
    _destinations = fetchedDestinations
        .where(
          (destination) => _selectedNearbyDistance.includes(
            nearbyDistanceKm(destination),
          ),
        )
        .toList(growable: false)
      ..sort(
        (first, second) => _distanceSquared(
          first.location,
        ).compareTo(_distanceSquared(second.location)),
      );
    await _refreshDestinationReviewSummaries();
  }

  void _startLocationTracking() {
    _locationSubscription = locationService.watchCurrentLocation().listen((
      location,
    ) {
      if (!_isUsingDeviceLocation) return;
      if (_journey?.status == EcoJourneyStatus.inProgress) {
        _recordLiveLocation(location);
        return;
      }
      if (_route == null) {
        _origin = location;
        notifyListeners();
      }
    });
  }

  void _recordLiveLocation(EcoLocation location) {
    final recordedAt = DateTime.now().toUtc();
    final previous = _lastTrackedLocation;
    final previousRecordedAt = _lastTrackedAt;
    if (previous != null) {
      final movementKm = _distanceBetween(previous, location);
      final nearestSegment = _nearestRouteSegment(location);
      final elapsedSeconds = previousRecordedAt == null
          ? 0.0
          : recordedAt.difference(previousRecordedAt).inMilliseconds / 1000;
      final walkingSpeedKmh = elapsedSeconds >= _minimumSpeedSampleSeconds
          ? movementKm / elapsedSeconds * 3600
          : 0.0;
      final isFastWalking =
          nearestSegment?.type == EcoRouteSegmentType.walk &&
          walkingSpeedKmh > _walkingSpeedThresholdKmh;

      if (isFastWalking) {
        _consecutiveFastWalkingUpdates++;
        if (_consecutiveFastWalkingUpdates >=
            _fastWalkingUpdatesBeforePausing) {
          _isWalkingSpeedSuspicious = true;
        }
      } else if (elapsedSeconds >= _minimumSpeedSampleSeconds) {
        _consecutiveFastWalkingUpdates = 0;
        _isWalkingSpeedSuspicious = false;
      }
      // A train can cover more ground between GPS fixes than a walker. Keep a
      // wider, but still bounded, allowance for a point near a rail segment.
      final maximumPlausibleMovementKm =
          nearestSegment?.type == EcoRouteSegmentType.transit ? 2.0 : 0.35;
      // Ignore impossible jumps caused by a temporary poor GPS measurement.
      if (movementKm <= maximumPlausibleMovementKm &&
          !_isWalkingSpeedSuspicious) {
        _trackedDistanceKm += movementKm;
        if (nearestSegment?.type == EcoRouteSegmentType.walk) {
          _trackedWalkingDistanceKm += movementKm;
          _estimatedStepCount =
              (_trackedWalkingDistanceKm * _estimatedStepsPerWalkingKm).round();
        } else if (nearestSegment?.type == EcoRouteSegmentType.transit) {
          _trackedTransitDistanceKm += movementKm;
        }
        _updateLiveEcoEstimates(location, movementKm);
      }
    }
    _currentJourneyLocation = location;
    _lastTrackedLocation = location;
    _lastTrackedAt = recordedAt;
    notifyListeners();

    final journeyId = _journey?.id;
    if (journeyId == null) return;
    final lastSaved = _lastPersistedLocation;
    if (lastSaved == null || _distanceBetween(lastSaved, location) >= 0.02) {
      _lastPersistedLocation = location;
      unawaited(
        journeyRepository
            .recordTrackPoint(
              journeyId: journeyId,
              location: location,
              recordedAt: recordedAt,
            )
            .catchError((_) {}),
      );
    }
    if (isAtDestination && !_isWalkingSpeedSuspicious) {
      unawaited(_completeJourneyAtArrival());
    } else {
      unawaited(_rerouteIfNeeded(location));
    }
  }

  void _updateLiveEcoEstimates(EcoLocation location, double movementKm) {
    final selectedRoute = _route;
    if (selectedRoute == null || movementKm == 0) return;

    final nearestSegment = _nearestRouteSegment(location);
    if (nearestSegment == null) return;

    if (nearestSegment.type == EcoRouteSegmentType.walk &&
        selectedRoute.walkingDistanceKm > 0) {
      _liveCaloriesBurned +=
          movementKm *
          selectedRoute.estimatedCalories /
          selectedRoute.walkingDistanceKm;
    }

    final transitDistanceKm =
        selectedRoute.totalDistanceKm - selectedRoute.walkingDistanceKm;
    if (nearestSegment.type == EcoRouteSegmentType.transit &&
        transitDistanceKm > 0) {
      _liveCarbonSavedKg +=
          movementKm * selectedRoute.estimatedCarbonSavedKg / transitDistanceKm;
    }
  }

  Future<void> _rerouteIfNeeded(EcoLocation location) async {
    final activeJourney = _journey;
    final selectedRoute = _route;
    if (activeJourney?.status != EcoJourneyStatus.inProgress ||
        selectedRoute == null ||
        _isRerouting ||
        _distanceFromRoute(location) <= _offRouteThresholdKm) {
      return;
    }
    final lastReroute = _lastRerouteAt;
    if (lastReroute != null &&
        DateTime.now().difference(lastReroute) < _rerouteCooldown) {
      return;
    }

    _isRerouting = true;
    notifyListeners();
    try {
      final updatedRoute = await repository.buildRoute(
        origin: location,
        destination: selectedRoute.destination,
      );
      _route = updatedRoute;
      _lastRerouteAt = DateTime.now();
      _journey = EcoJourney(
        id: activeJourney?.id,
        userId: activeJourney!.userId,
        route: updatedRoute,
        status: activeJourney.status,
        startedAt: activeJourney.startedAt,
        actualWalkingDistanceKm: _trackedWalkingDistanceKm,
        actualTransitDistanceKm: _trackedTransitDistanceKm,
        actualStepCount: _estimatedStepCount,
        actualCaloriesBurned: _liveCaloriesBurned.round(),
        actualCarbonSavedKg: _liveCarbonSavedKg,
      );
      final journeyId = activeJourney.id;
      if (journeyId != null) {
        await journeyRepository.updateRouteEstimates(
          journeyId: journeyId,
          route: updatedRoute,
        );
      }
      _message =
          'You moved away from the route. Your rail-and-walk plan was updated.';
    } catch (_) {
      _lastRerouteAt = DateTime.now();
      _message = 'You are away from the route. Unable to refresh it right now.';
    } finally {
      _isRerouting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> startJourney() async {
    final selectedRoute = _route;
    if (selectedRoute == null) return;
    final activeJourney = _journey;
    if (activeJourney?.status == EcoJourneyStatus.inProgress) {
      _message =
          'A journey is already active. End it early or cancel it before starting another one.';
      notifyListeners();
      return;
    }

    final startedAt = DateTime.now().toUtc();
    try {
      final journeyId = await journeyRepository.createStartedJourney(
        userId: userId,
        route: selectedRoute,
        startedAt: startedAt,
      );
      _journey = EcoJourney(
        id: journeyId,
        userId: userId,
        route: selectedRoute,
        status: EcoJourneyStatus.inProgress,
        startedAt: startedAt,
      );
      _resetLiveTracking();
      _currentJourneyLocation = _origin;
      _lastTrackedLocation = _origin;
      _lastTrackedAt = startedAt;
      _lastPersistedLocation = _origin;
      try {
        await journeyRepository.recordTrackPoint(
          journeyId: journeyId,
          location: _origin,
          recordedAt: startedAt,
        );
      } catch (_) {
        // Keep the journey usable if the optional tracking table has not yet
        // been migrated on a teammate's Supabase project.
        _message =
            'Journey started. GPS points will be saved after the tracking migration is applied.';
      }
      _message = null;
    } catch (_) {
      _message =
          'Unable to save this journey. Check your connection and try again.';
    }
    notifyListeners();
  }

  /// Completes a trip only when its latest GPS point is near the destination.
  Future<bool> finishJourneyIfArrived() async {
    final activeJourney = _journey;
    if (activeJourney == null ||
        activeJourney.status != EcoJourneyStatus.inProgress) {
      return false;
    }
    if (!isAtDestination) {
      _message =
          'You have not arrived yet. Keep following the route, end early to save your progress, or cancel to discard it.';
      notifyListeners();
      return false;
    }
    await _completeJourneyAtArrival();
    return _journey?.status == EcoJourneyStatus.completed;
  }

  Future<void> _completeJourneyAtArrival() async {
    final activeJourney = _journey;
    if (_isCompletingJourney ||
        activeJourney == null ||
        activeJourney.status != EcoJourneyStatus.inProgress) {
      return;
    }

    final journeyId = activeJourney.id;
    if (journeyId == null) return;

    _isCompletingJourney = true;
    _arrivalConfirmed = true;
    notifyListeners();
    // Keep the tracker visible at 100% before the completion summary opens.
    await Future<void>.delayed(_arrivalConfirmationDuration);
    final endedAt = DateTime.now().toUtc();
    try {
      await journeyRepository.completeJourney(
        journeyId: journeyId,
        endedAt: endedAt,
        finalRoute: activeJourney.route,
        actualDurationMinutes: endedAt
            .difference(activeJourney.startedAt ?? endedAt)
            .inMinutes,
        actualWalkingDistanceKm: _trackedWalkingDistanceKm,
        actualTransitDistanceKm: _trackedTransitDistanceKm,
        actualStepCount: _estimatedStepCount,
        actualCaloriesBurned: _liveCaloriesBurned.round(),
        actualCarbonSavedKg: _liveCarbonSavedKg,
      );
      _journey = EcoJourney(
        id: journeyId,
        userId: activeJourney.userId,
        route: activeJourney.route,
        status: EcoJourneyStatus.completed,
        startedAt: activeJourney.startedAt,
        endedAt: endedAt,
        actualWalkingDistanceKm: _trackedWalkingDistanceKm,
        actualTransitDistanceKm: _trackedTransitDistanceKm,
        actualStepCount: _estimatedStepCount,
        actualCaloriesBurned: _liveCaloriesBurned.round(),
        actualCarbonSavedKg: _liveCarbonSavedKg,
      );
      _message = 'You arrived at ${activeJourney.route.destination.name}.';
    } catch (_) {
      _message = 'Unable to complete this journey. Please try again.';
    } finally {
      _isCompletingJourney = false;
    }
    notifyListeners();
  }

  /// Stops tracking before the destination but retains the GPS-derived
  /// progress in history. Fitness intentionally excludes this outcome.
  Future<bool> endJourneyEarly() async {
    final activeJourney = _journey;
    final journeyId = activeJourney?.id;
    if (journeyId == null ||
        activeJourney?.status != EcoJourneyStatus.inProgress) {
      return false;
    }

    _isCompletingJourney = true;
    notifyListeners();
    final endedAt = DateTime.now().toUtc();
    try {
      await journeyRepository.endJourneyEarly(
        journeyId: journeyId,
        endedAt: endedAt,
        finalRoute: activeJourney!.route,
        actualDurationMinutes: endedAt
            .difference(activeJourney.startedAt ?? endedAt)
            .inMinutes,
        actualWalkingDistanceKm: _trackedWalkingDistanceKm,
        actualTransitDistanceKm: _trackedTransitDistanceKm,
        actualStepCount: _estimatedStepCount,
        actualCaloriesBurned: _liveCaloriesBurned.round(),
        actualCarbonSavedKg: _liveCarbonSavedKg,
      );
      _journey = EcoJourney(
        id: journeyId,
        userId: activeJourney.userId,
        route: activeJourney.route,
        status: EcoJourneyStatus.endedEarly,
        startedAt: activeJourney.startedAt,
        endedAt: endedAt,
        actualWalkingDistanceKm: _trackedWalkingDistanceKm,
        actualTransitDistanceKm: _trackedTransitDistanceKm,
        actualStepCount: _estimatedStepCount,
        actualCaloriesBurned: _liveCaloriesBurned.round(),
        actualCarbonSavedKg: _liveCarbonSavedKg,
      );
      _message =
          'Journey ended early. Your recorded walking, steps and eco progress were saved.';
      return true;
    } catch (_) {
      _message = 'Unable to save this early-ended journey. Please try again.';
      return false;
    } finally {
      _isCompletingJourney = false;
      notifyListeners();
    }
  }

  Future<bool> cancelJourney() async {
    final activeJourney = _journey;
    final journeyId = activeJourney?.id;
    if (journeyId == null ||
        activeJourney?.status != EcoJourneyStatus.inProgress) {
      return false;
    }
    try {
      await journeyRepository.cancelJourney(journeyId: journeyId);
      _journey = null;
      _resetLiveTracking();
      _message = 'Journey cancelled. No trip was saved to your history.';
      notifyListeners();
      return true;
    } catch (_) {
      _message = 'Unable to cancel this journey. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void _resetLiveTracking() {
    _currentJourneyLocation = null;
    _lastTrackedLocation = null;
    _lastTrackedAt = null;
    _lastPersistedLocation = null;
    _trackedDistanceKm = 0;
    _trackedWalkingDistanceKm = 0;
    _trackedTransitDistanceKm = 0;
    _estimatedStepCount = 0;
    _liveCaloriesBurned = 0;
    _liveCarbonSavedKg = 0;
    _isCompletingJourney = false;
    _arrivalConfirmed = false;
    _isWalkingSpeedSuspicious = false;
    _consecutiveFastWalkingUpdates = 0;
  }

  double _distanceSquared(EcoLocation location) {
    final latitudeDifference = location.latitude - _origin.latitude;
    final longitudeDifference = location.longitude - _origin.longitude;
    return latitudeDifference * latitudeDifference +
        longitudeDifference * longitudeDifference;
  }

  double _distanceBetween(EcoLocation first, EcoLocation second) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _degreesToRadians(second.latitude - first.latitude);
    final longitudeDelta = _degreesToRadians(
      second.longitude - first.longitude,
    );
    final a =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(_degreesToRadians(first.latitude)) *
            math.cos(_degreesToRadians(second.latitude)) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Estimates position along the drawn route instead of treating every metre
  /// travelled as progress. This prevents a detour, a car ride, or a GPS jump
  /// from filling the progress bar before the route is actually followed.
  double _routeProgressAt(EcoLocation location) {
    final selectedRoute = _route;
    if (selectedRoute == null) return 0;
    final routePoints = <EcoLocation>[
      selectedRoute.origin,
      for (final segment in selectedRoute.segments) ...segment.mapPath,
      selectedRoute.destination.location,
    ];
    if (routePoints.length < 2) return 0;

    var totalRouteLengthKm = 0.0;
    var bestDistanceFromRouteKm = double.infinity;
    var bestDistanceAlongRouteKm = 0.0;
    for (var index = 0; index < routePoints.length - 1; index++) {
      final start = routePoints[index];
      final end = routePoints[index + 1];
      final segmentLengthKm = _distanceBetween(start, end);
      if (segmentLengthKm == 0) continue;
      final projection = _projectOntoLineSegment(location, start, end);
      if (projection.$1 < bestDistanceFromRouteKm) {
        bestDistanceFromRouteKm = projection.$1;
        bestDistanceAlongRouteKm =
            totalRouteLengthKm + segmentLengthKm * projection.$2;
      }
      totalRouteLengthKm += segmentLengthKm;
    }
    if (totalRouteLengthKm == 0 || !bestDistanceFromRouteKm.isFinite) return 0;
    return (bestDistanceAlongRouteKm / totalRouteLengthKm)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  EcoRouteSegment? _nearestRouteSegment(EcoLocation location) {
    final selectedRoute = _route;
    if (selectedRoute == null) return null;
    EcoRouteSegment? nearest;
    var nearestDistanceKm = double.infinity;
    for (final segment in selectedRoute.segments) {
      final path = segment.mapPath;
      for (final point in path) {
        final distanceKm = _distanceBetween(location, point);
        if (distanceKm < nearestDistanceKm) {
          nearestDistanceKm = distanceKm;
          nearest = segment;
        }
      }
    }
    return nearest;
  }

  double _distanceFromRoute(EcoLocation location) {
    final selectedRoute = _route;
    if (selectedRoute == null) return double.infinity;
    final routePoints = <EcoLocation>[
      selectedRoute.origin,
      for (final segment in selectedRoute.segments) ...segment.mapPath,
      selectedRoute.destination.location,
    ];
    if (routePoints.length < 2) return double.infinity;

    var shortestDistanceKm = double.infinity;
    for (var index = 0; index < routePoints.length - 1; index++) {
      shortestDistanceKm = math.min(
        shortestDistanceKm,
        _distanceToLineSegment(
          location,
          routePoints[index],
          routePoints[index + 1],
        ),
      );
    }
    return shortestDistanceKm;
  }

  double _distanceToLineSegment(
    EcoLocation point,
    EcoLocation start,
    EcoLocation end,
  ) => _projectOntoLineSegment(point, start, end).$1;

  /// Returns the shortest distance to a route line and the projected position
  /// on that line (0 at its start and 1 at its end).
  (double, double) _projectOntoLineSegment(
    EcoLocation point,
    EcoLocation start,
    EcoLocation end,
  ) {
    const latitudeKm = 110.574;
    final longitudeKm = 111.320 * math.cos(_degreesToRadians(point.latitude));
    final endX = (end.longitude - start.longitude) * longitudeKm;
    final endY = (end.latitude - start.latitude) * latitudeKm;
    final pointX = (point.longitude - start.longitude) * longitudeKm;
    final pointY = (point.latitude - start.latitude) * latitudeKm;
    final segmentLengthSquared = endX * endX + endY * endY;
    if (segmentLengthSquared == 0) {
      return (math.sqrt(pointX * pointX + pointY * pointY), 0);
    }
    final projection = ((pointX * endX + pointY * endY) / segmentLengthSquared)
        .clamp(0.0, 1.0);
    final deltaX = pointX - projection * endX;
    final deltaY = pointY - projection * endY;
    return (math.sqrt(deltaX * deltaX + deltaY * deltaY), projection);
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  String _routeErrorMessage(Object error) {
    final detail = error.toString();
    if (detail.contains('Google Maps service is not configured')) {
      return 'Live route service is not configured yet. Add the Google server key to Supabase Edge Function secrets.';
    }
    if (detail.contains('No rail-and-walk route is currently available')) {
      return 'No rail-and-walk route is available for this long journey right now. Try another time or choose a destination closer to a rail station.';
    }
    return 'A live rail-and-walk route could not be created. Check your connection and try another destination.';
  }
}
