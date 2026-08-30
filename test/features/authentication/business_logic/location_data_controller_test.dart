import 'package:citieswalk/features/authentication/business_logic/entities/location_access.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/location_data_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/location_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads current foreground location access', () async {
    final repository = _LocationRepository();
    final controller = LocationDataController(repository);

    await controller.load();

    expect(controller.access?.servicesEnabled, isTrue);
    expect(controller.access?.permissionState, LocationPermissionState.allowed);
    expect(controller.errorMessage, isNull);
  });

  test('refreshes access after requesting permission', () async {
    final repository = _LocationRepository(
      access: const LocationAccess(
        servicesEnabled: true,
        permissionState: LocationPermissionState.denied,
      ),
    );
    final controller = LocationDataController(repository);

    await controller.requestAccess();

    expect(repository.requested, isTrue);
    expect(controller.access?.permissionState, LocationPermissionState.allowed);
  });
}

class _LocationRepository implements LocationSettingsRepository {
  _LocationRepository({
    this.access = const LocationAccess(
      servicesEnabled: true,
      permissionState: LocationPermissionState.allowed,
    ),
  });

  LocationAccess access;
  bool requested = false;

  @override
  Future<LocationAccess> checkAccess() async => access;

  @override
  Future<LocationAccess> requestAccess() async {
    requested = true;
    access = const LocationAccess(
      servicesEnabled: true,
      permissionState: LocationPermissionState.allowed,
    );
    return access;
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
