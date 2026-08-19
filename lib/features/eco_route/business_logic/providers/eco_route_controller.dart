import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../../core/models/destination_review_summary.dart';
import '../../../../core/services/destination_review_summary_service.dart';
import '../entities/eco_destination.dart';
import '../entities/eco_journey.dart';
import '../entities/eco_journey_history_item.dart';
import '../entities/eco_location.dart';
import '../entities/eco_place_category.dart';
import '../entities/eco_route.dart';
import '../entities/eco_route_segment.dart';
import '../repositories/eco_route_repository.dart';
import '../repositories/journey_repository.dart';
import '../services/location_service.dart';

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
  bool _isLoadingDestinations = false;
  EcoRoute? _route;
  EcoJourney? _journey;
  StreamSubscription<EcoLocation>? _locationSubscription;
  bool _isUsingDeviceLocation = false;
  bool _hasUsableOrigin = false;
  EcoLocation? _currentJourneyLocation;
  EcoLocation? _lastTrackedLocation;
  EcoLocation? _lastPersistedLocation;
  double _trackedDistanceKm = 0;
  double _trackedDistanceAtRouteStartKm = 0;
  double _liveCaloriesBurned = 0;
  double _liveCarbonSavedKg = 0;
  bool _isRerouting = false;
  DateTime? _lastRerouteAt;
  Map<String, DestinationReviewSummary> _reviewSummaries = const {};

  static const _offRouteThresholdKm = 0.09;
  static const _rerouteCooldown = Duration(seconds: 90);

  bool get isLoading => _isLoading;
  bool get hasInitialised => _hasInitialised;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get message => _message;
  EcoLocation get origin => _origin;
  List<EcoDestination> get destinations => _destinations;
  EcoPlaceCategory get selectedCategory => _selectedCategory;
  bool get isLoadingDestinations => _isLoadingDestinations;
  EcoRoute? get route => _route;
  EcoJourney? get journey => _journey;
  bool get hasDeviceLocation => _isUsingDeviceLocation;
  bool get hasUsableOrigin => _hasUsableOrigin;
  EcoLocation? get currentJourneyLocation => _currentJourneyLocation;
  double get trackedDistanceKm => _trackedDistanceKm;
  double get liveCaloriesBurned => _liveCaloriesBurned;
  double get liveCarbonSavedKg => _liveCarbonSavedKg;
  bool get isRerouting => _isRerouting;
  DestinationReviewSummary reviewSummaryFor(EcoDestination destination) =>
      _reviewSummaries[destination.id] ?? DestinationReviewSummary.empty;
  DestinationReviewSummary get selectedDestinationReviewSummary {
    final destination = _route?.destination;
    return destination == null
        ? DestinationReviewSummary.empty
        : reviewSummaryFor(destination);
  }

  double get remainingDistanceKm => _route == null
      ? 0
      : math.max(
          0,
          _route!.totalDistanceKm -
              (_trackedDistanceKm - _trackedDistanceAtRouteStartKm),
        );
  bool get isJourneyTracking => _journey?.status == EcoJourneyStatus.inProgress;
  String? get nextInstruction {
    final selectedRoute = _route;
    if (selectedRoute == null || !isJourneyTracking) return null;
    final progress = selectedRoute.totalDistanceKm == 0
        ? 0.0
        : (_trackedDistanceKm - _trackedDistanceAtRouteStartKm) /
              selectedRoute.totalDistanceKm;
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
    _origin = _fallbackLocation;
    _isUsingDeviceLocation = false;
    _hasUsableOrigin = false;
    _currentJourneyLocation = null;
    _lastTrackedLocation = null;
    _lastPersistedLocation = null;
    _trackedDistanceKm = 0;
    _trackedDistanceAtRouteStartKm = 0;
    _liveCaloriesBurned = 0;
    _liveCarbonSavedKg = 0;
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
      _destinations = await repository.fetchNearbyDestinations(
        origin: _origin,
        category: _selectedCategory,
      );
      _destinations = [..._destinations]
        ..sort(
          (first, second) => _distanceSquared(
            first.location,
          ).compareTo(_distanceSquared(second.location)),
        );
      await _refreshDestinationReviewSummaries();
    } catch (_) {
      _message = 'Destinations are unavailable right now. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDeviceLocation() => initialise();

  Future<void> searchDestinations(String query) async {
    try {
      _destinations = await repository.searchDestinations(
        query: query,
        origin: _origin,
      );
      await _refreshDestinationReviewSummaries();
      notifyListeners();
    } catch (_) {
      _message = 'Search is unavailable right now. Please try again.';
      notifyListeners();
    }
  }

  Future<void> selectCategory(EcoPlaceCategory category) async {
    if (_selectedCategory == category && _destinations.isNotEmpty) return;
    _selectedCategory = category;
    _isLoadingDestinations = true;
    _message = null;
    notifyListeners();
    try {
      _destinations = await repository.fetchNearbyDestinations(
        origin: _origin,
        category: category,
      );
      _destinations = [..._destinations]
        ..sort(
          (first, second) => _distanceSquared(
            first.location,
          ).compareTo(_distanceSquared(second.location)),
        );
      await _refreshDestinationReviewSummaries();
    } catch (_) {
      _message =
          'Nearby ${category.label.toLowerCase()} are unavailable right now.';
    } finally {
      _isLoadingDestinations = false;
      notifyListeners();
    }
  }

  Future<void> selectDestination(EcoDestination destination) async {
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

  Future<void> replanJourney(EcoJourneyHistoryItem journey) async {
    if (!_hasInitialised) {
      await initialise();
    }
    if (!_hasUsableOrigin) return;

    _route = null;
    _journey = null;
    _currentJourneyLocation = null;
    _lastTrackedLocation = null;
    _lastPersistedLocation = null;
    _trackedDistanceKm = 0;
    _trackedDistanceAtRouteStartKm = 0;
    _liveCaloriesBurned = 0;
    _liveCarbonSavedKg = 0;
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
    _currentJourneyLocation = null;
    _lastTrackedLocation = null;
    _lastPersistedLocation = null;
    _trackedDistanceKm = 0;
    _trackedDistanceAtRouteStartKm = 0;
    _liveCaloriesBurned = 0;
    _liveCarbonSavedKg = 0;
    _lastRerouteAt = null;
    _message =
        'Starting point updated. Choose a destination to plan your route.';
    notifyListeners();

    try {
      _destinations = await repository.fetchNearbyDestinations(
        origin: _origin,
        category: _selectedCategory,
      );
      _destinations = [..._destinations]
        ..sort(
          (first, second) => _distanceSquared(
            first.location,
          ).compareTo(_distanceSquared(second.location)),
        );
      await _refreshDestinationReviewSummaries();
    } catch (_) {
      _message = 'Starting point updated, but nearby places are unavailable.';
    }
    notifyListeners();
  }

  void clearRoute() {
    _route = null;
    _journey = null;
    _currentJourneyLocation = null;
    _lastTrackedLocation = null;
    _lastPersistedLocation = null;
    _trackedDistanceKm = 0;
    _trackedDistanceAtRouteStartKm = 0;
    _liveCaloriesBurned = 0;
    _liveCarbonSavedKg = 0;
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
    final previous = _lastTrackedLocation;
    if (previous != null) {
      final movementKm = _distanceBetween(previous, location);
      // Ignore impossible jumps caused by a temporary poor GPS measurement.
      if (movementKm <= 0.35) {
        _trackedDistanceKm += movementKm;
        _updateLiveEcoEstimates(location, movementKm);
      }
    }
    _currentJourneyLocation = location;
    _lastTrackedLocation = location;
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
              recordedAt: DateTime.now().toUtc(),
            )
            .catchError((_) {}),
      );
    }
    unawaited(_rerouteIfNeeded(location));
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
      _trackedDistanceAtRouteStartKm = _trackedDistanceKm;
      _lastRerouteAt = DateTime.now();
      _journey = EcoJourney(
        id: activeJourney?.id,
        userId: activeJourney!.userId,
        route: updatedRoute,
        status: activeJourney.status,
        startedAt: activeJourney.startedAt,
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
      _currentJourneyLocation = _origin;
      _lastTrackedLocation = _origin;
      _lastPersistedLocation = _origin;
      _trackedDistanceKm = 0;
      _trackedDistanceAtRouteStartKm = 0;
      _liveCaloriesBurned = 0;
      _liveCarbonSavedKg = 0;
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

  Future<void> endJourney() async {
    final activeJourney = _journey;
    if (activeJourney == null) return;

    final journeyId = activeJourney.id;
    if (journeyId == null) return;

    final endedAt = DateTime.now().toUtc();
    try {
      await journeyRepository.completeJourney(
        journeyId: journeyId,
        endedAt: endedAt,
        finalRoute: activeJourney.route,
      );
      _journey = EcoJourney(
        id: journeyId,
        userId: activeJourney.userId,
        route: activeJourney.route,
        status: EcoJourneyStatus.completed,
        startedAt: activeJourney.startedAt,
        endedAt: endedAt,
      );
      _message = null;
    } catch (_) {
      _message = 'Unable to complete this journey. Please try again.';
    }
    notifyListeners();
  }

  Future<void> pauseJourney() async {
    final activeJourney = _journey;
    if (activeJourney?.id == null ||
        activeJourney?.status != EcoJourneyStatus.inProgress) {
      return;
    }
    try {
      await journeyRepository.pauseJourney(journeyId: activeJourney!.id!);
      _journey = EcoJourney(
        id: activeJourney.id,
        userId: activeJourney.userId,
        route: activeJourney.route,
        status: EcoJourneyStatus.paused,
        startedAt: activeJourney.startedAt,
      );
    } catch (_) {
      _message = 'Unable to pause this journey. Please try again.';
    }
    notifyListeners();
  }

  Future<void> resumeJourney() async {
    final activeJourney = _journey;
    if (activeJourney?.id == null ||
        activeJourney?.status != EcoJourneyStatus.paused) {
      return;
    }
    try {
      await journeyRepository.resumeJourney(journeyId: activeJourney!.id!);
      _journey = EcoJourney(
        id: activeJourney.id,
        userId: activeJourney.userId,
        route: activeJourney.route,
        status: EcoJourneyStatus.inProgress,
        startedAt: activeJourney.startedAt,
      );
      _lastTrackedLocation = _currentJourneyLocation;
    } catch (_) {
      _message = 'Unable to resume this journey. Please try again.';
    }
    notifyListeners();
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
  ) {
    const latitudeKm = 110.574;
    final longitudeKm = 111.320 * math.cos(_degreesToRadians(point.latitude));
    final endX = (end.longitude - start.longitude) * longitudeKm;
    final endY = (end.latitude - start.latitude) * latitudeKm;
    final pointX = (point.longitude - start.longitude) * longitudeKm;
    final pointY = (point.latitude - start.latitude) * latitudeKm;
    final segmentLengthSquared = endX * endX + endY * endY;
    if (segmentLengthSquared == 0) {
      return math.sqrt(pointX * pointX + pointY * pointY);
    }
    final projection = ((pointX * endX + pointY * endY) / segmentLengthSquared)
        .clamp(0.0, 1.0);
    final deltaX = pointX - projection * endX;
    final deltaY = pointY - projection * endY;
    return math.sqrt(deltaX * deltaX + deltaY * deltaY);
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  String _routeErrorMessage(Object error) {
    final detail = error.toString();
    if (detail.contains('Google Maps service is not configured')) {
      return 'Live route service is not configured yet. Add the Google server key to Supabase Edge Function secrets.';
    }
    return 'A live rail-and-walk route could not be created. Check your connection and try another destination.';
  }
}
