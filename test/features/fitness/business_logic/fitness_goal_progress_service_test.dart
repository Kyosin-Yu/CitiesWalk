import 'package:citieswalk/features/fitness/business_logic/entities/fitness_dashboard.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_goal.dart';
import 'package:citieswalk/features/fitness/business_logic/services/fitness_goal_progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FitnessGoalProgressService();
  final dashboard = FitnessDashboard(
    userName: 'Alex',
    streakDays: 1,
    walkingDistanceTodayKm: 2.5,
    caloriesTodayKcal: 175,
    carbonSavedTodayKg: .4,
    weeklyWalkingDistanceKm: 8,
    previousWeekWalkingDistanceKm: 6,
    monthlyWalkingDistanceKm: 20,
    weeklyCaloriesKcal: 560,
    weeklyCarbonSavedKg: 1.5,
    monthlyCaloriesKcal: 1400,
    monthlyCarbonSavedKg: 4,
    completedJourneysThisWeek: 3,
    totalCompletedJourneys: 8,
    dailySummaries: const [],
  );

  test('calculates progress using the matching metric and period', () {
    final progress = service.calculate(
      goal: FitnessGoal(
        id: 'goal-1',
        userId: 'user-1',
        metric: FitnessGoalMetric.calories,
        period: FitnessGoalPeriod.monthly,
        targetValue: 2000,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      dashboard: dashboard,
    );

    expect(progress.currentValue, 1400);
    expect(progress.fraction, .7);
    expect(progress.percentage, 70);
    expect(progress.isComplete, isFalse);
  });

  test('caps completed goal progress at one hundred percent', () {
    final progress = service.calculate(
      goal: FitnessGoal(
        id: 'goal-2',
        userId: 'user-1',
        metric: FitnessGoalMetric.walkingDistance,
        period: FitnessGoalPeriod.daily,
        targetValue: 2,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      dashboard: dashboard,
    );

    expect(progress.fraction, 1);
    expect(progress.percentage, 100);
    expect(progress.isComplete, isTrue);
  });
}
