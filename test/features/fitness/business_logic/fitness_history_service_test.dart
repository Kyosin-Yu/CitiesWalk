import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_history.dart';
import 'package:citieswalk/features/fitness/business_logic/services/fitness_history_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FitnessHistoryService();
  final journeys = [
    CompletedFitnessJourney(
      id: 'morning-walk',
      walkingDistanceMeters: 1200,
      estimatedCalories: 90,
      estimatedCarbonSavedKg: .3,
      startedAt: DateTime(2026, 8, 3, 8),
      completedAt: DateTime(2026, 8, 3, 9),
      stepCount: 1600,
    ),
    CompletedFitnessJourney(
      id: 'evening-walk',
      walkingDistanceMeters: 800,
      estimatedCalories: 60,
      estimatedCarbonSavedKg: .2,
      startedAt: DateTime(2026, 8, 3, 17),
      completedAt: DateTime(2026, 8, 3, 18),
      stepCount: 1100,
    ),
    CompletedFitnessJourney(
      id: 'wednesday-walk',
      walkingDistanceMeters: 3000,
      estimatedCalories: 210,
      estimatedCarbonSavedKg: .8,
      startedAt: DateTime(2026, 8, 5, 10),
      completedAt: DateTime(2026, 8, 5, 11),
      stepCount: 4000,
    ),
    CompletedFitnessJourney(
      id: 'ended-early',
      walkingDistanceMeters: 500,
      estimatedCalories: 35,
      estimatedCarbonSavedKg: .1,
      startedAt: DateTime(2026, 9, 1, 10),
      completedAt: DateTime(2026, 9, 1, 10, 30),
      stepCount: 700,
      countsAsCompletedRoute: false,
    ),
  ];

  test('returns only dates that contain a fitness record', () {
    final dates = service.availableDates(journeys);

    expect(dates, [
      DateTime(2026, 8, 3),
      DateTime(2026, 8, 5),
      DateTime(2026, 9, 1),
    ]);
    expect(service.hasActivityOnDate(dates, DateTime(2026, 8, 4)), isFalse);
    expect(service.hasActivityOnDate(dates, DateTime(2026, 8, 5, 20)), isTrue);
  });

  test('builds daily totals and keeps each journey as a history item', () {
    final summary = service.build(
      journeys: journeys,
      period: FitnessHistoryPeriod.daily,
      anchorDate: DateTime(2026, 8, 3),
    );

    expect(summary.journeyCount, 2);
    expect(summary.completedRouteCount, 2);
    expect(summary.activeDays, 1);
    expect(summary.walkingDistanceKm, 2);
    expect(summary.caloriesKcal, 150);
    expect(summary.carbonSavedKg, .5);
    expect(summary.steps, 2700);
    expect(summary.buckets, hasLength(2));
    expect(summary.journeys.map((journey) => journey.id), [
      'evening-walk',
      'morning-walk',
    ]);
  });

  test('groups weekly and monthly history by active day', () {
    final weekly = service.build(
      journeys: journeys,
      period: FitnessHistoryPeriod.weekly,
      anchorDate: DateTime(2026, 8, 5),
    );
    final monthly = service.build(
      journeys: journeys,
      period: FitnessHistoryPeriod.monthly,
      anchorDate: DateTime(2026, 8, 5),
    );

    expect(weekly.journeyCount, 3);
    expect(weekly.activeDays, 2);
    expect(weekly.buckets, hasLength(2));
    expect(monthly.journeyCount, 3);
    expect(monthly.walkingDistanceKm, 5);
  });

  test('groups yearly history by month and identifies ended-early records', () {
    final summary = service.build(
      journeys: journeys,
      period: FitnessHistoryPeriod.yearly,
      anchorDate: DateTime(2026, 8, 5),
    );

    expect(summary.journeyCount, 4);
    expect(summary.completedRouteCount, 3);
    expect(summary.activeDays, 3);
    expect(summary.buckets, hasLength(2));
    expect(summary.buckets.first.startedAt, DateTime(2026, 9));
    expect(summary.buckets.first.completedRouteCount, 0);
  });
}
