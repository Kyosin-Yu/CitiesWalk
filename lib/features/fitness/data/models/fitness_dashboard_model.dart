import '../../business_logic/entities/fitness_dashboard.dart';

class FitnessDashboardModel {
  const FitnessDashboardModel({
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

  FitnessDashboard toEntity() => FitnessDashboard(
    userName: userName,
    streakDays: streakDays,
    stepsToday: stepsToday,
    caloriesKcal: caloriesKcal,
    carbonSavedKg: carbonSavedKg,
    ecoPoints: ecoPoints,
  );
}
