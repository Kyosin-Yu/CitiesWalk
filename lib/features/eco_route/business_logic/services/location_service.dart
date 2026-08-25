import '../entities/eco_location.dart';

abstract interface class LocationService {
  Future<EcoLocation> getCurrentLocation();

  /// Opens the system page used to enable device-wide location services.
  Future<bool> openLocationSettings();

  /// Opens CitiesWalk's app-specific settings, for permission or precision.
  Future<bool> openAppSettings();

  /// Emits real device GPS fixes after permission has been granted.
  Stream<EcoLocation> watchCurrentLocation();
}

enum LocationServiceFailure {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  reducedAccuracy,
  insufficientAccuracy,
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message, {this.failure});

  final String message;
  final LocationServiceFailure? failure;

  @override
  String toString() => message;
}
