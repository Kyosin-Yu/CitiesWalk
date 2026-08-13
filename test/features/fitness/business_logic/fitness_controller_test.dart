import 'package:flutter_test/flutter_test.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_dashboard.dart';
import 'package:citieswalk/features/fitness/business_logic/providers/fitness_controller.dart';
import 'package:citieswalk/features/fitness/business_logic/repositories/fitness_repository.dart';

void main() {
  test('loads dashboard data and toggles notification state', () async {
    final controller = FitnessController(_FakeFitnessRepository());

    await controller.loadDashboard();

    expect(controller.status, FitnessStatus.success);
    expect(controller.dashboard?.userName, 'Alex Rahman');
    expect(controller.notificationsEnabled, isTrue);

    controller.toggleNotifications();

    expect(controller.notificationsEnabled, isFalse);
  });
}

class _FakeFitnessRepository implements FitnessRepository {
  @override
  Future<FitnessDashboard> getDashboard() async => const FitnessDashboard(
    userName: 'Alex Rahman',
    streakDays: 12,
    stepsToday: 8452,
    caloriesKcal: 486,
    carbonSavedKg: 12.6,
    ecoPoints: 2340,
  );
}
