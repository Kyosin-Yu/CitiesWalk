import 'package:geolocator/geolocator.dart';

import '../models/eco_location.dart';

abstract interface class LocationService {
  Future<EcoLocation> getCurrentLocation();
}

class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  @override
  Future<EcoLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Turn on location services to use your current location.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(
        'Location permission was not granted.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission is permanently denied. Enable it in device settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition();
    return EcoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      label: 'Current location',
    );
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
