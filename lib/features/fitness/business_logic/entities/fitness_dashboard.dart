import 'completed_fitness_journey.dart';

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
    this.walkingSource = FitnessMetricSource.unavailable,
    this.caloriesSource = FitnessMetricSource.unavailable,
    this.carbonSource = FitnessMetricSource.unavailable,
  });

  final String userName;
  final int streakDays;
  final int? stepsToday;
  final double walkingDistanceTodayKm;
  final int caloriesTodayKcal;
  final double carbonSavedTodayKg;
  final int? ecoPoints;
  final FitnessMetricSource stepsSource;
  final FitnessMetricSource walkingSource;
  final FitnessMetricSource caloriesSource;
  final FitnessMetricSource carbonSource;
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

  bool get hasCompletedJourney => totalCompletedJourneys > 0;
  bool get hasRecordedActivity => activityJourneyCount > 0;
}
