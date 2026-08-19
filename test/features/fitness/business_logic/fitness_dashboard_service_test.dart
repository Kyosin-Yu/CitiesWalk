import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/services/fitness_dashboard_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aggregates completed journeys into real daily and weekly totals', () {
    const service = FitnessDashboardService();
    final dashboard = service.build(
      userName: 'Alex',
      now: DateTime(2026, 8, 19, 12),
      journeys: [
        CompletedFitnessJourney(
          id: 'today',
          walkingDistanceMeters: 1500,
          estimatedCalories: 100,
          estimatedCarbonSavedKg: .4,
          completedAt: DateTime(2026, 8, 19, 10),
        ),
        CompletedFitnessJourney(
          id: 'yesterday',
          walkingDistanceMeters: 2500,
          estimatedCalories: 200,
          estimatedCarbonSavedKg: .8,
          completedAt: DateTime(2026, 8, 18, 10),
        ),
        CompletedFitnessJourney(
          id: 'old',
          walkingDistanceMeters: 9000,
          estimatedCalories: 900,
          estimatedCarbonSavedKg: 3,
          completedAt: DateTime(2026, 7, 1),
        ),
      ],
    );

    expect(dashboard.walkingDistanceTodayKm, 1.5);
    expect(dashboard.caloriesTodayKcal, 100);
    expect(dashboard.carbonSavedTodayKg, .4);
    expect(dashboard.weeklyWalkingDistanceKm, 4);
    expect(dashboard.weeklyCaloriesKcal, 300);
    expect(dashboard.weeklyCarbonSavedKg, closeTo(1.2, .000001));
    expect(dashboard.monthlyCaloriesKcal, 300);
    expect(dashboard.monthlyCarbonSavedKg, closeTo(1.2, .000001));
    expect(dashboard.completedJourneysThisWeek, 2);
    expect(dashboard.streakDays, 2);
    expect(dashboard.dailySummaries, hasLength(7));
  });

  test('returns zero totals and seven safe chart points for no journeys', () {
    const service = FitnessDashboardService();
    final dashboard = service.build(
      userName: 'Alex',
      journeys: const [],
      now: DateTime(2026, 8, 19),
    );

    expect(dashboard.weeklyWalkingDistanceKm, 0);
    expect(dashboard.weeklyCaloriesKcal, 0);
    expect(dashboard.weeklyCarbonSavedKg, 0);
    expect(dashboard.monthlyCaloriesKcal, 0);
    expect(dashboard.monthlyCarbonSavedKg, 0);
    expect(dashboard.streakDays, 0);
    expect(dashboard.hasCompletedJourney, isFalse);
    expect(dashboard.dailySummaries, hasLength(7));
  });
}
