import 'package:geolocator/geolocator.dart';

import '../../business_logic/entities/location_access.dart';
import '../../business_logic/repositories/location_settings_repository.dart';

class DeviceLocationSettingsRepository implements LocationSettingsRepository {
  const DeviceLocationSettingsRepository();

  @override
  Future<LocationAccess> checkAccess() async => _access(
    await Geolocator.isLocationServiceEnabled(),
    await Geolocator.checkPermission(),
  );

  @override
  Future<LocationAccess> requestAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _access(serviceEnabled, permission);
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  LocationAccess _access(bool servicesEnabled, LocationPermission permission) {
    final permissionState = switch (permission) {
      LocationPermission.deniedForever =>
        LocationPermissionState.permanentlyDenied,
      LocationPermission.denied ||
      LocationPermission.unableToDetermine => LocationPermissionState.denied,
      _ => LocationPermissionState.allowed,
    };
    return LocationAccess(
      servicesEnabled: servicesEnabled,
      permissionState: permissionState,
    );
  }
}
