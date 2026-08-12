import '../entities/eco_location.dart';

abstract interface class LocationService {
  Future<EcoLocation> getCurrentLocation();
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
