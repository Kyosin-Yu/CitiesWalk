import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/services/fitness_dashboard_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aggregates completed journeys into real daily and weekly totals', () {
    const service = FitnessDashboardService();
    final dashboard = service.build(
      userName: 'Alex',
      now: DateTime(2026, 8, 19, 12),
      ecoPoints: 135,
      journeys: [
        CompletedFitnessJourney(
          id: 'today',
          walkingDistanceMeters: 1500,
          estimatedCalories: 100,
          estimatedCarbonSavedKg: .4,
          startedAt: DateTime(2026, 8, 19, 9),
          completedAt: DateTime(2026, 8, 19, 10),
          stepCount: 1950,
          stepsSource: FitnessMetricSource.recorded,
        ),
        CompletedFitnessJourney(
          id: 'yesterday',
          walkingDistanceMeters: 2500,
          estimatedCalories: 200,
          estimatedCarbonSavedKg: .8,
          startedAt: DateTime(2026, 8, 18, 9),
          completedAt: DateTime(2026, 8, 18, 10),
          stepCount: 3250,
          stepsSource: FitnessMetricSource.recorded,
        ),
        CompletedFitnessJourney(
          id: 'old',
          walkingDistanceMeters: 9000,
          estimatedCalories: 900,
          estimatedCarbonSavedKg: 3,
          startedAt: DateTime(2026, 7, 1, 9),
          completedAt: DateTime(2026, 7, 1),
        ),
      ],
    );

    expect(dashboard.walkingDistanceTodayKm, 1.5);
    expect(dashboard.stepsToday, 1950);
    expect(dashboard.caloriesTodayKcal, 100);
    expect(dashboard.carbonSavedTodayKg, .4);
    expect(dashboard.weeklyWalkingDistanceKm, 4);
    expect(dashboard.weeklyCaloriesKcal, 300);
    expect(dashboard.weeklyCarbonSavedKg, closeTo(1.2, .000001));
    expect(dashboard.monthlyCaloriesKcal, 300);
    expect(dashboard.monthlyCarbonSavedKg, closeTo(1.2, .000001));
    expect(dashboard.completedJourneysThisWeek, 2);
    expect(dashboard.streakDays, 2);
    expect(dashboard.ecoPoints, 135);
    expect(dashboard.walkingSource, FitnessMetricSource.estimated);
    expect(dashboard.stepsSource, FitnessMetricSource.recorded);
    expect(dashboard.dailySummaries, hasLength(7));
  });

  test('marks a dashboard metric as mixed when its sources differ', () {
    const service = FitnessDashboardService();
    final dashboard = service.build(
      userName: 'Alex',
      now: DateTime(2026, 8, 19, 12),
      journeys: [
        CompletedFitnessJourney(
          id: 'recorded',
          walkingDistanceMeters: 1500,
          estimatedCalories: 100,
          estimatedCarbonSavedKg: .4,
          startedAt: DateTime(2026, 8, 19, 8),
          completedAt: DateTime(2026, 8, 19, 9),
          distanceSource: FitnessMetricSource.recorded,
        ),
        CompletedFitnessJourney(
          id: 'estimated',
          walkingDistanceMeters: 1000,
          estimatedCalories: 70,
          estimatedCarbonSavedKg: .2,
          startedAt: DateTime(2026, 8, 19, 10),
          completedAt: DateTime(2026, 8, 19, 11),
        ),
      ],
    );

    expect(dashboard.walkingSource, FitnessMetricSource.mixed);
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

  test('counts early-ended effort without counting a completed route', () {
    const service = FitnessDashboardService();
    final dashboard = service.build(
      userName: 'Alex',
      now: DateTime(2026, 8, 19, 12),
      journeys: [
        CompletedFitnessJourney(
          id: 'ended-early',
          walkingDistanceMeters: 850,
          estimatedCalories: 56,
          estimatedCarbonSavedKg: .18,
          startedAt: DateTime(2026, 8, 19, 9, 30),
          completedAt: DateTime(2026, 8, 19, 10),
          stepCount: 1105,
          countsAsCompletedRoute: false,
        ),
      ],
    );

    expect(dashboard.hasRecordedActivity, isTrue);
    expect(dashboard.walkingDistanceTodayKm, .85);
    expect(dashboard.stepsToday, 1105);
    expect(dashboard.caloriesTodayKcal, 56);
    expect(dashboard.completedJourneysThisWeek, 0);
    expect(dashboard.totalCompletedJourneys, 0);
    expect(dashboard.streakDays, 0);
  });
}
