enum LocationPermissionState { allowed, denied, permanentlyDenied }

class LocationAccess {
  const LocationAccess({
    required this.servicesEnabled,
    required this.permissionState,
  });

  final bool servicesEnabled;
  final LocationPermissionState permissionState;
}
