import '../../business_logic/entities/health_activity.dart';

class DeviceHealthActivityModel {
  const DeviceHealthActivityModel({
    required this.status,
    this.syncedAt,
    this.stepsToday,
    this.walkingDistanceMetersToday,
    this.activeCaloriesToday,
    this.message,
  });

  final HealthIntegrationStatus status;
  final DateTime? syncedAt;
  final int? stepsToday;
  final int? walkingDistanceMetersToday;
  final int? activeCaloriesToday;
  final String? message;
}
