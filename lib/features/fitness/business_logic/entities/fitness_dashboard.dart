class FitnessDashboard {
  const FitnessDashboard({
    required this.userName,
    required this.streakDays,
    required this.stepsToday,
    required this.caloriesKcal,
    required this.carbonSavedKg,
    required this.ecoPoints,
  });

  final String userName;
  final int streakDays;
  final int stepsToday;
  final int caloriesKcal;
  final double carbonSavedKg;
  final int ecoPoints;
}
