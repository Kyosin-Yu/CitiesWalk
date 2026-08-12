import '../../business_logic/entities/fitness_dashboard.dart';
import '../../business_logic/repositories/fitness_repository.dart';
import '../data_sources/fitness_local_data_source.dart';

class FitnessRepositoryImpl implements FitnessRepository {
  const FitnessRepositoryImpl(this._localDataSource);

  final FitnessLocalDataSource _localDataSource;

  @override
  Future<FitnessDashboard> getDashboard() async =>
      (await _localDataSource.fetchDashboard()).toEntity();
}
