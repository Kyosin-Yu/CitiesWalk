import '../entities/completed_fitness_journey.dart';
import '../entities/fitness_goal.dart';

class FitnessGoalProgress {
  const FitnessGoalProgress({
    required this.currentValue,
    required this.targetValue,
  });

  final double currentValue;
  final double targetValue;

  double get fraction =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0.0, 1.0);

  int get percentage => (fraction * 100).round();
  bool get isComplete => currentValue >= targetValue;
}

class FitnessGoalProgressService {
  const FitnessGoalProgressService();

  FitnessGoalProgress calculate({
    required FitnessGoal goal,
    required List<CompletedFitnessJourney> journeys,
    DateTime? now,
  }) {
    if (goal.isCompleted) {
      return FitnessGoalProgress(
        currentValue: goal.completedValue ?? goal.targetValue,
        targetValue: goal.targetValue,
      );
    }
    if (goal.isCancelled) {
      return FitnessGoalProgress(
        currentValue: 0,
        targetValue: goal.targetValue,
      );
    }

    final reference = (now ?? DateTime.now()).toLocal();
    final periodStart = _periodStart(goal.period, reference);
    final progressStart = goal.createdAt.isAfter(periodStart)
        ? goal.createdAt
        : periodStart;
    final eligibleJourneys = journeys.where((journey) {
      final startedAt = journey.startedAt;
      return journey.countsAsCompletedRoute &&
          startedAt != null &&
          !startedAt.isBefore(progressStart) &&
          !journey.completedAt.isAfter(reference);
    });

    final currentValue = switch (goal.metric) {
      FitnessGoalMetric.walkingDistance => eligibleJourneys.fold<double>(
        0,
        (total, journey) => total + journey.walkingDistanceMeters / 1000,
      ),
      FitnessGoalMetric.calories => eligibleJourneys.fold<double>(
        0,
        (total, journey) => total + journey.estimatedCalories,
      ),
      FitnessGoalMetric.carbonSaved => eligibleJourneys.fold<double>(
        0,
        (total, journey) => total + journey.estimatedCarbonSavedKg,
      ),
    };

    return FitnessGoalProgress(
      currentValue: (currentValue * 100).round() / 100,
      targetValue: goal.targetValue,
    );
  }

  DateTime _periodStart(FitnessGoalPeriod period, DateTime reference) {
    return switch (period) {
      FitnessGoalPeriod.daily => DateTime(
        reference.year,
        reference.month,
        reference.day,
      ),
      FitnessGoalPeriod.weekly => DateTime(
        reference.year,
        reference.month,
        reference.day,
      ).subtract(Duration(days: reference.weekday - DateTime.monday)),
      FitnessGoalPeriod.monthly => DateTime(reference.year, reference.month),
    };
  }
}
