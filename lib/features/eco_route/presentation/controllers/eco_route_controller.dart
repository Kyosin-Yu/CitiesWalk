import 'package:flutter/foundation.dart';

import '../../data/repositories/eco_route_repository.dart';
import '../../business/models/eco_destination.dart';
import '../../business/models/eco_journey.dart';
import '../../business/models/eco_location.dart';
import '../../business/models/eco_route.dart';
import '../../business/services/location_service.dart';

class EcoRouteController extends ChangeNotifier {
  EcoRouteController({
    required this.userId,
    required this.repository,
    required this.locationService,
  });

  final String userId;
  final EcoRouteRepository repository;
  final LocationService locationService;

  static const _fallbackLocation = EcoLocation(
    latitude: 3.1340,
    longitude: 101.6869,
    label: 'KL Sentral (sample origin)',
  );

  bool _isLoading = true;
  bool _hasInitialised = false;
  bool _isLoadingRoute = false;
  String? _message;
  EcoLocation _origin = _fallbackLocation;
  List<EcoDestination> _destinations = const [];
  EcoRoute? _route;
  EcoJourney? _journey;

  bool get isLoading => _isLoading;
  bool get hasInitialised => _hasInitialised;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get message => _message;
  EcoLocation get origin => _origin;
  List<EcoDestination> get destinations => _destinations;
  EcoRoute? get route => _route;
  EcoJourney? get journey => _journey;

  Future<void> initialise() async {
    _isLoading = true;
    _hasInitialised = true;
    _message = null;
    notifyListeners();

    try {
      _origin = await locationService.getCurrentLocation();
    } on LocationServiceException catch (error) {
      _message = '${error.message} Showing routes from KL Sentral instead.';
    } catch (_) {
      _message =
          'Unable to read your location. Showing routes from KL Sentral instead.';
    }

    try {
      _destinations = await repository.fetchNearbyDestinations();
    } catch (_) {
      _message = 'Destinations are unavailable right now. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchDestinations(String query) async {
    try {
      _destinations = await repository.searchDestinations(query);
      notifyListeners();
    } catch (_) {
      _message = 'Search is unavailable right now. Please try again.';
      notifyListeners();
    }
  }

  Future<void> selectDestination(EcoDestination destination) async {
    _isLoadingRoute = true;
    _message = null;
    notifyListeners();

    try {
      _route = await repository.buildRoute(
        origin: _origin,
        destination: destination,
      );
    } catch (_) {
      _message =
          'A route could not be created. Please choose another destination.';
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void startJourney() {
    final selectedRoute = _route;
    if (selectedRoute == null) return;

    _journey = EcoJourney(
      userId: userId,
      route: selectedRoute,
      status: EcoJourneyStatus.inProgress,
      startedAt: DateTime.now().toUtc(),
    );
    notifyListeners();
  }
}
