import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/services/location_service.dart';

/// Device-specific location access for the Eco-Route data layer.
class DeviceLocationDataSource implements LocationService {
  const DeviceLocationDataSource();

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

    var position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        timeLimit: Duration(seconds: 20),
      ),
    );

    // A first GPS fix can be based on Wi-Fi or a mobile tower. Wait briefly
    // for a more accurate satellite fix before displaying it as the origin.
    if (position.accuracy > 80) {
      try {
        position =
            await Geolocator.getPositionStream(locationSettings: _settings)
                .firstWhere((fix) => fix.accuracy <= 80)
                .timeout(const Duration(seconds: 12));
      } on TimeoutException {
        // Keep the best fix available. The live stream continues refining it.
      }
    }
    return EcoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      label: 'GPS location (±${position.accuracy.round()} m)',
    );
  }

  @override
  Stream<EcoLocation> watchCurrentLocation() =>
      Geolocator.getPositionStream(locationSettings: _settings).map(
        (position) => EcoLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          label: 'GPS location (±${position.accuracy.round()} m)',
        ),
      );
}
