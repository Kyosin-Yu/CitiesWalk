import '../../business_logic/entities/health_activity.dart';
import '../../business_logic/repositories/health_activity_repository.dart';
import '../data_sources/device_health_data_source.dart';
import '../models/device_health_activity_model.dart';

class HealthActivityRepositoryImpl implements HealthActivityRepository {
  const HealthActivityRepositoryImpl(this._dataSource);

  final DeviceHealthDataSource _dataSource;

  @override
  Future<HealthActivityAccess> loadToday() async {
    final model = await _dataSource.loadToday();
    return _toEntity(model);
  }

  @override
  Future<HealthActivityAccess> requestAccessAndLoadToday() async {
    final model = await _dataSource.loadToday(requestAccess: true);
    return _toEntity(model);
  }

  @override
  Future<void> revokeAccess() => _dataSource.revokeAccess();

  @override
  Future<void> installHealthConnect() => _dataSource.installHealthConnect();

  HealthActivityAccess _toEntity(DeviceHealthActivityModel model) {
    final syncedAt = model.syncedAt;
    return HealthActivityAccess(
      status: model.status,
      message: model.message,
      snapshot: syncedAt == null
          ? null
          : HealthActivitySnapshot(
              syncedAt: syncedAt,
              stepsToday: model.stepsToday,
              walkingDistanceMetersToday: model.walkingDistanceMetersToday,
              activeCaloriesToday: model.activeCaloriesToday,
            ),
    );
  }
}
