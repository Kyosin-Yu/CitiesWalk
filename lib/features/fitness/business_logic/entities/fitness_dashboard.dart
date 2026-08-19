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
    required this.completedJourneysThisWeek,
    required this.totalCompletedJourneys,
    required this.dailySummaries,
    this.stepsToday,
    this.ecoPoints,
  });

  final String userName;
  final int streakDays;
  final int? stepsToday;
  final double walkingDistanceTodayKm;
  final int caloriesTodayKcal;
  final double carbonSavedTodayKg;
  final int? ecoPoints;
  final double weeklyWalkingDistanceKm;
  final double previousWeekWalkingDistanceKm;
  final double monthlyWalkingDistanceKm;
  final int weeklyCaloriesKcal;
  final double weeklyCarbonSavedKg;
  final int completedJourneysThisWeek;
  final int totalCompletedJourneys;
  final List<FitnessDaySummary> dailySummaries;

  bool get hasCompletedJourney => totalCompletedJourneys > 0;
}
