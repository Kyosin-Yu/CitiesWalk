import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/providers/fitness_controller.dart';
import 'package:citieswalk/features/fitness/business_logic/repositories/fitness_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads completed Eco Route data and toggles notifications', () async {
    final controller = FitnessController(
      userId: 'user-1',
      userName: 'Alex',
      repository: _FakeFitnessRepository(),
    );

    await controller.loadDashboard();

    expect(controller.status, FitnessStatus.success);
    expect(controller.dashboard?.userName, 'Alex');
    expect(controller.dashboard?.weeklyWalkingDistanceKm, 2.4);
    expect(controller.dashboard?.weeklyCaloriesKcal, 180);
    expect(controller.dashboard?.weeklyCarbonSavedKg, .6);
    expect(controller.dashboard?.stepsToday, isNull);
    expect(controller.dashboard?.ecoPoints, isNull);

    controller.toggleNotifications();
    expect(controller.notificationsEnabled, isFalse);
  });

  test('exposes a safe failure state when route sync fails', () async {
    final controller = FitnessController(
      userId: 'user-1',
      userName: 'Alex',
      repository: _FailingFitnessRepository(),
    );

    await controller.loadDashboard();

    expect(controller.status, FitnessStatus.failure);
    expect(controller.dashboard, isNull);
    expect(controller.errorMessage, isNotEmpty);
  });
}

class _FakeFitnessRepository implements FitnessRepository {
  @override
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  }) async => [
    CompletedFitnessJourney(
      id: 'journey-1',
      walkingDistanceMeters: 2400,
      estimatedCalories: 180,
      estimatedCarbonSavedKg: .6,
      completedAt: DateTime.now(),
    ),
  ];
}

class _FailingFitnessRepository implements FitnessRepository {
  @override
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  }) => Future.error(Exception('offline'));
}
