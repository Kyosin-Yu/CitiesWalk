import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/services/location_service.dart';

/// Device-specific location access for the Eco-Route data layer.
class DeviceLocationDataSource implements LocationService {
  const DeviceLocationDataSource();

  static const _maximumAcceptedAccuracyMeters = 35.0;

  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
  );

  @override
  Future<EcoLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Turn on location services to use your current location.',
        failure: LocationServiceFailure.servicesDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(
        'Location permission was not granted.',
        failure: LocationServiceFailure.permissionDenied,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission is permanently denied. Enable it in device settings.',
        failure: LocationServiceFailure.permissionDeniedForever,
      );
    }

    final accuracyStatus = await Geolocator.getLocationAccuracy();
    if (accuracyStatus == LocationAccuracyStatus.reduced) {
      throw const LocationServiceException(
        'Precise location is turned off. Enable Precise location for CitiesWalk in your device settings, then try again.',
        failure: LocationServiceFailure.reducedAccuracy,
      );
    }

    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        timeLimit: Duration(seconds: 25),
      ),
    );

    if (initialPosition.accuracy <= _maximumAcceptedAccuracyMeters) {
      return _toEcoLocation(initialPosition);
    }

    // A first position can be based on Wi-Fi or a mobile tower. Do not use it
    // as the route origin if it is too broad; wait for a proper GPS fix.
    try {
      final precisePosition =
          await Geolocator.getPositionStream(locationSettings: _settings)
              .firstWhere(
                (fix) => fix.accuracy <= _maximumAcceptedAccuracyMeters,
              )
              .timeout(const Duration(seconds: 20));
      return _toEcoLocation(precisePosition);
    } on TimeoutException {
      throw LocationServiceException(
        'GPS is currently only accurate to ±${initialPosition.accuracy.round()} m. Move outdoors, turn on Google Location Accuracy, then refresh your location.',
        failure: LocationServiceFailure.insufficientAccuracy,
      );
    }
  }

  @override
  Stream<EcoLocation> watchCurrentLocation() =>
      Geolocator.getPositionStream(locationSettings: _settings)
          .where(
            (position) => position.accuracy <= _maximumAcceptedAccuracyMeters,
          )
          .map(_toEcoLocation);

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  EcoLocation _toEcoLocation(Position position) => EcoLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    label: 'GPS location (±${position.accuracy.round()} m)',
  );
}
