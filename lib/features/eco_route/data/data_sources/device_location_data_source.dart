import 'package:geolocator/geolocator.dart';

import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/services/location_service.dart';

/// Device-specific location access for the Eco-Route data layer.
class DeviceLocationDataSource implements LocationService {
  const DeviceLocationDataSource();

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
