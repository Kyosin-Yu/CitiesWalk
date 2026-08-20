import '../entities/completed_fitness_journey.dart';
import '../entities/fitness_goal.dart';

abstract interface class FitnessRepository {
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  });

  Future<List<FitnessGoal>> fetchGoals({required String userId});

  Future<FitnessGoal> createGoal({
    required String userId,
    required FitnessGoalInput input,
  });

  Future<FitnessGoal> updateGoal({
    required String userId,
    required String goalId,
    required FitnessGoalInput input,
  });

  Future<void> deleteGoal({required String userId, required String goalId});
}
