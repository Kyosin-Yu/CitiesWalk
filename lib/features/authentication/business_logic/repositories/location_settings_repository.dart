import '../entities/location_access.dart';

abstract interface class LocationSettingsRepository {
  Future<LocationAccess> checkAccess();
  Future<LocationAccess> requestAccess();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}
