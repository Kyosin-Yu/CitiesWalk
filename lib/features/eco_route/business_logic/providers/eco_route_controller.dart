import 'dart:async';

import 'package:flutter/foundation.dart';

import '../entities/eco_destination.dart';
import '../entities/eco_journey.dart';
import '../entities/eco_location.dart';
import '../entities/eco_route.dart';
import '../repositories/eco_route_repository.dart';
import '../repositories/journey_repository.dart';
import '../services/location_service.dart';

class EcoRouteController extends ChangeNotifier {
  EcoRouteController({
    required this.userId,
    required this.repository,
    required this.journeyRepository,
    required this.locationService,
  });

  final String userId;
  final EcoRouteRepository repository;
  final JourneyRepository journeyRepository;
  final LocationService locationService;

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
  EcoRoute? _route;
  EcoJourney? _journey;
  StreamSubscription<EcoLocation>? _locationSubscription;
  bool _isUsingDeviceLocation = false;
  bool _hasUsableOrigin = false;

  bool get isLoading => _isLoading;
  bool get hasInitialised => _hasInitialised;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get message => _message;
  EcoLocation get origin => _origin;
  List<EcoDestination> get destinations => _destinations;
  EcoRoute? get route => _route;
  EcoJourney? get journey => _journey;
  bool get hasDeviceLocation => _isUsingDeviceLocation;
  bool get hasUsableOrigin => _hasUsableOrigin;
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
      _destinations = await repository.fetchNearbyDestinations(origin: _origin);
      _destinations = [..._destinations]
        ..sort(
          (first, second) => _distanceSquared(
            first.location,
          ).compareTo(_distanceSquared(second.location)),
        );
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
      notifyListeners();
    } catch (_) {
      _message = 'Search is unavailable right now. Please try again.';
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
    } catch (error) {
      _message = _routeErrorMessage(error);
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  Future<void> setStartingPoint(EcoLocation location) async {
    _origin = location;
    _isUsingDeviceLocation = false;
    _hasUsableOrigin = true;
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _route = null;
    _journey = null;
    _message =
        'Starting point updated. Choose a destination to plan your route.';
    notifyListeners();

    try {
      _destinations = await repository.fetchNearbyDestinations(origin: _origin);
      _destinations = [..._destinations]
        ..sort(
          (first, second) => _distanceSquared(
            first.location,
          ).compareTo(_distanceSquared(second.location)),
        );
    } catch (_) {
      _message = 'Starting point updated, but nearby places are unavailable.';
    }
    notifyListeners();
  }

  void clearRoute() {
    _route = null;
    _journey = null;
    _message = null;
    notifyListeners();
  }

  void _startLocationTracking() {
    _locationSubscription = locationService.watchCurrentLocation().listen((
      location,
    ) {
      if (!_isUsingDeviceLocation || _route != null) return;
      _origin = location;
      notifyListeners();
    });
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

  double _distanceSquared(EcoLocation location) {
    final latitudeDifference = location.latitude - _origin.latitude;
    final longitudeDifference = location.longitude - _origin.longitude;
    return latitudeDifference * latitudeDifference +
        longitudeDifference * longitudeDifference;
  }

  String _routeErrorMessage(Object error) {
    final detail = error.toString();
    if (detail.contains('Google Maps service is not configured')) {
      return 'Live route service is not configured yet. Add the Google server key to Supabase Edge Function secrets.';
    }
    return 'A live rail-and-walk route could not be created. Check your connection and try another destination.';
  }
}
