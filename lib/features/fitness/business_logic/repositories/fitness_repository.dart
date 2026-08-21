import '../entities/completed_fitness_journey.dart';
import '../entities/fitness_goal.dart';
import '../entities/fitness_recent_badge.dart';

abstract interface class FitnessRepository {
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  });

  Future<List<FitnessGoal>> fetchGoals({required String userId});

  Future<List<FitnessRecentBadge>> fetchRecentBadges({required String userId});

  Future<FitnessGoal> createGoal({
    required String userId,
    required FitnessGoalInput input,
  });

  Future<FitnessGoal> cancelGoal({
    required String userId,
    required String goalId,
  });
}
