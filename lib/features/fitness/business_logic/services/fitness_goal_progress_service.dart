import '../entities/fitness_dashboard.dart';
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
    required FitnessDashboard dashboard,
  }) => FitnessGoalProgress(
    currentValue: _currentValue(goal, dashboard),
    targetValue: goal.targetValue,
  );

  double _currentValue(FitnessGoal goal, FitnessDashboard dashboard) {
    return switch ((goal.metric, goal.period)) {
      (FitnessGoalMetric.walkingDistance, FitnessGoalPeriod.daily) =>
        dashboard.walkingDistanceTodayKm,
      (FitnessGoalMetric.walkingDistance, FitnessGoalPeriod.weekly) =>
        dashboard.weeklyWalkingDistanceKm,
      (FitnessGoalMetric.walkingDistance, FitnessGoalPeriod.monthly) =>
        dashboard.monthlyWalkingDistanceKm,
      (FitnessGoalMetric.calories, FitnessGoalPeriod.daily) =>
        dashboard.caloriesTodayKcal.toDouble(),
      (FitnessGoalMetric.calories, FitnessGoalPeriod.weekly) =>
        dashboard.weeklyCaloriesKcal.toDouble(),
      (FitnessGoalMetric.calories, FitnessGoalPeriod.monthly) =>
        dashboard.monthlyCaloriesKcal.toDouble(),
      (FitnessGoalMetric.carbonSaved, FitnessGoalPeriod.daily) =>
        dashboard.carbonSavedTodayKg,
      (FitnessGoalMetric.carbonSaved, FitnessGoalPeriod.weekly) =>
        dashboard.weeklyCarbonSavedKg,
      (FitnessGoalMetric.carbonSaved, FitnessGoalPeriod.monthly) =>
        dashboard.monthlyCarbonSavedKg,
    };
  }
}
