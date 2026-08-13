import '../models/fitness_dashboard_model.dart';

/// Temporary local sample data until the completed-journey contract is ready.
/// No calorie or carbon formula is encoded here because it has not been agreed.
class FitnessLocalDataSource {
  const FitnessLocalDataSource();

  Future<FitnessDashboardModel> fetchDashboard() async =>
      const FitnessDashboardModel(
        userName: 'Alex Rahman',
        streakDays: 12,
        stepsToday: 8452,
        caloriesKcal: 486,
        carbonSavedKg: 12.6,
        ecoPoints: 2340,
      );
}
