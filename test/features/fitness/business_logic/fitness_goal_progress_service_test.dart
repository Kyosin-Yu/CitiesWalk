import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_goal.dart';
import 'package:citieswalk/features/fitness/business_logic/services/fitness_goal_progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FitnessGoalProgressService();

  test('counts only journeys started after an active goal was created', () {
    final progress = service.calculate(
      goal: FitnessGoal(
        id: 'goal-1',
        userId: 'user-1',
        metric: FitnessGoalMetric.calories,
        period: FitnessGoalPeriod.monthly,
        targetValue: 2000,
        status: FitnessGoalStatus.active,
        createdAt: DateTime(2026, 8, 1, 8),
        updatedAt: DateTime(2026, 8, 1, 8),
      ),
      journeys: [
        CompletedFitnessJourney(
          id: 'legacy-without-start',
          walkingDistanceMeters: 1000,
          estimatedCalories: 500,
          estimatedCarbonSavedKg: .3,
          startedAt: null,
          completedAt: DateTime(2026, 8, 5, 9),
        ),
        CompletedFitnessJourney(
          id: 'already-started',
          walkingDistanceMeters: 2000,
          estimatedCalories: 600,
          estimatedCarbonSavedKg: .5,
          startedAt: DateTime(2026, 8, 1, 7),
          completedAt: DateTime(2026, 8, 1, 9),
        ),
        CompletedFitnessJourney(
          id: 'eligible',
          walkingDistanceMeters: 5000,
          estimatedCalories: 1400,
          estimatedCarbonSavedKg: 1.2,
          startedAt: DateTime(2026, 8, 10, 9),
          completedAt: DateTime(2026, 8, 10, 10),
        ),
        CompletedFitnessJourney(
          id: 'ended-early',
          walkingDistanceMeters: 4000,
          estimatedCalories: 1000,
          estimatedCarbonSavedKg: 1,
          startedAt: DateTime(2026, 8, 11, 9),
          completedAt: DateTime(2026, 8, 11, 10),
          countsAsCompletedRoute: false,
        ),
      ],
      now: DateTime(2026, 8, 21),
    );

    expect(progress.currentValue, 1400);
    expect(progress.fraction, .7);
    expect(progress.percentage, 70);
    expect(progress.isComplete, isFalse);
  });

  test('keeps completed goal progress and reward result immutable', () {
    final progress = service.calculate(
      goal: FitnessGoal(
        id: 'goal-2',
        userId: 'user-1',
        metric: FitnessGoalMetric.walkingDistance,
        period: FitnessGoalPeriod.daily,
        targetValue: 2,
        status: FitnessGoalStatus.completed,
        createdAt: DateTime(2026, 8, 21, 8),
        updatedAt: DateTime(2026, 8, 21, 10),
        completedAt: DateTime(2026, 8, 21, 10),
        completedValue: 2.5,
        rewardPoints: 100,
        rewardPolicyVersion: 'v1',
      ),
      journeys: const [],
      now: DateTime(2026, 8, 21, 12),
    );

    expect(progress.currentValue, 2.5);
    expect(progress.fraction, 1);
    expect(progress.percentage, 100);
    expect(progress.isComplete, isTrue);
  });
}
