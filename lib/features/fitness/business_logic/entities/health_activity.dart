enum HealthIntegrationStatus {
  unsupported,
  unavailable,
  permissionRequired,
  connected,
  error,
}

class HealthActivitySnapshot {
  const HealthActivitySnapshot({
    required this.syncedAt,
    this.stepsToday,
    this.walkingDistanceMetersToday,
    this.activeCaloriesToday,
  });

  final DateTime syncedAt;
  final int? stepsToday;
  final int? walkingDistanceMetersToday;
  final int? activeCaloriesToday;

  bool get hasAnyData =>
      stepsToday != null ||
      walkingDistanceMetersToday != null ||
      activeCaloriesToday != null;

  bool get hasActivity =>
      (stepsToday ?? 0) > 0 ||
      (walkingDistanceMetersToday ?? 0) > 0 ||
      (activeCaloriesToday ?? 0) > 0;
}

class HealthActivityAccess {
  const HealthActivityAccess({
    required this.status,
    this.snapshot,
    this.message,
  });

  final HealthIntegrationStatus status;
  final HealthActivitySnapshot? snapshot;
  final String? message;
}
