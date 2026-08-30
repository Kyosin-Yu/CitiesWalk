import 'completed_fitness_journey.dart';
import 'health_activity.dart';

class FitnessDaySummary {
  const FitnessDaySummary({
    required this.date,
    required this.walkingDistanceKm,
    required this.caloriesKcal,
    required this.carbonSavedKg,
    required this.completedJourneys,
  });

  final DateTime date;
  final double walkingDistanceKm;
  final int caloriesKcal;
  final double carbonSavedKg;
  final int completedJourneys;
}

class FitnessDashboard {
  const FitnessDashboard({
    required this.userName,
    required this.streakDays,
    required this.walkingDistanceTodayKm,
    required this.caloriesTodayKcal,
    required this.carbonSavedTodayKg,
    required this.journeyStepsToday,
    required this.weeklyWalkingDistanceKm,
    required this.previousWeekWalkingDistanceKm,
    required this.monthlyWalkingDistanceKm,
    required this.weeklyCaloriesKcal,
    required this.weeklyCarbonSavedKg,
    required this.monthlyCaloriesKcal,
    required this.monthlyCarbonSavedKg,
    required this.completedJourneysThisWeek,
    required this.totalCompletedJourneys,
    required this.dailySummaries,
    this.activityJourneyCount = 0,
    this.stepsToday,
    this.ecoPoints,
    this.stepsSource = FitnessMetricSource.unavailable,
    this.journeyStepsSource = FitnessMetricSource.unavailable,
    this.walkingSource = FitnessMetricSource.unavailable,
    this.caloriesSource = FitnessMetricSource.unavailable,
    this.carbonSource = FitnessMetricSource.unavailable,
    this.healthActivity,
  });

  final String userName;
  final int streakDays;
  final int? stepsToday;
  final int journeyStepsToday;
  final double walkingDistanceTodayKm;
  final int caloriesTodayKcal;
  final double carbonSavedTodayKg;
  final int? ecoPoints;
  final FitnessMetricSource stepsSource;
  final FitnessMetricSource journeyStepsSource;
  final FitnessMetricSource walkingSource;
  final FitnessMetricSource caloriesSource;
  final FitnessMetricSource carbonSource;
  final HealthActivitySnapshot? healthActivity;
  final double weeklyWalkingDistanceKm;
  final double previousWeekWalkingDistanceKm;
  final double monthlyWalkingDistanceKm;
  final int weeklyCaloriesKcal;
  final double weeklyCarbonSavedKg;
  final int monthlyCaloriesKcal;
  final double monthlyCarbonSavedKg;
  final int completedJourneysThisWeek;
  final int totalCompletedJourneys;
  final List<FitnessDaySummary> dailySummaries;
  final int activityJourneyCount;

  int? get overallStepsToday => healthActivity?.stepsToday;

  bool get hasCompletedJourney => totalCompletedJourneys > 0;
  bool get hasRecordedActivity =>
      activityJourneyCount > 0 || (healthActivity?.hasActivity ?? false);
}
