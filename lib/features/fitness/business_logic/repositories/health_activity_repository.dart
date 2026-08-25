import '../entities/health_activity.dart';

abstract interface class HealthActivityRepository {
  Future<HealthActivityAccess> loadToday();

  Future<HealthActivityAccess> requestAccessAndLoadToday();

  Future<void> revokeAccess();

  Future<void> installHealthConnect();
}
