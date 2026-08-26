import '../../business_logic/entities/completed_fitness_journey.dart';
import '../../business_logic/entities/fitness_goal.dart';
import '../../business_logic/entities/fitness_recent_badge.dart';
import '../../business_logic/entities/fitness_route_point.dart';
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

  @override
  Future<List<FitnessRoutePoint>> fetchJourneyRoutePoints({
    required String userId,
    required String journeyId,
  }) async {
    final models = await _dataSource.fetchJourneyRoutePoints(
      userId: userId,
      journeyId: journeyId,
    );
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<List<FitnessGoal>> fetchGoals({required String userId}) async {
    final models = await _dataSource.fetchGoals(userId: userId);
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<List<FitnessRecentBadge>> fetchRecentBadges({
    required String userId,
  }) async {
    final models = await _dataSource.fetchRecentBadges(userId: userId);
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<FitnessGoal> createGoal({
    required String userId,
    required FitnessGoalInput input,
  }) async {
    final model = await _dataSource.createGoal(userId: userId, input: input);
    return model.toEntity();
  }

  @override
  Future<FitnessGoal> cancelGoal({
    required String userId,
    required String goalId,
  }) async {
    final model = await _dataSource.cancelGoal(userId: userId, goalId: goalId);
    return model.toEntity();
  }
}
