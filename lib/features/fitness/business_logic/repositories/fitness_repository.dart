import '../entities/fitness_dashboard.dart';

abstract class FitnessRepository {
  Future<FitnessDashboard> getDashboard();
}
