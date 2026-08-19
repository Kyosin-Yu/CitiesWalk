import '../../business_logic/entities/completed_fitness_journey.dart';
import '../../business_logic/repositories/fitness_repository.dart';
import '../data_sources/supabase_fitness_data_source.dart';

class FitnessRepositoryImpl implements FitnessRepository {
  const FitnessRepositoryImpl(this._dataSource);

  final SupabaseFitnessDataSource _dataSource;

  @override
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  }) async {
    final models = await _dataSource.fetchCompletedJourneys(userId: userId);
    return models.map((model) => model.toEntity()).toList(growable: false);
  }
}
