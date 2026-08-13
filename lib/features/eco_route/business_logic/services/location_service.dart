import '../entities/eco_location.dart';

abstract interface class LocationService {
  Future<EcoLocation> getCurrentLocation();

  /// Emits real device GPS fixes after permission has been granted.
  Stream<EcoLocation> watchCurrentLocation();
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
