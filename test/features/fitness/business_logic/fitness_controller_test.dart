import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_goal.dart';
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

  test('creates, updates and deletes personal fitness goals', () async {
    final repository = _FakeFitnessRepository();
    final controller = FitnessController(
      userId: 'user-1',
      userName: 'Alex',
      repository: repository,
    );
    await controller.loadDashboard();

    final created = await controller.createGoal(
      const FitnessGoalInput(
        metric: FitnessGoalMetric.walkingDistance,
        period: FitnessGoalPeriod.daily,
        targetValue: 5,
      ),
    );

    expect(created, isTrue);
    expect(controller.goals, hasLength(1));
    expect(controller.progressFor(controller.goals.single).currentValue, 2.4);

    final updated = await controller.updateGoal(
      controller.goals.single,
      const FitnessGoalInput(
        metric: FitnessGoalMetric.walkingDistance,
        period: FitnessGoalPeriod.daily,
        targetValue: 3,
      ),
    );

    expect(updated, isTrue);
    expect(controller.goals.single.targetValue, 3);

    final deleted = await controller.deleteGoal(controller.goals.single);

    expect(deleted, isTrue);
    expect(controller.goals, isEmpty);
  });

  test('prevents duplicate metric and period goals', () async {
    final controller = FitnessController(
      userId: 'user-1',
      userName: 'Alex',
      repository: _FakeFitnessRepository(),
    );
    await controller.loadDashboard();
    const input = FitnessGoalInput(
      metric: FitnessGoalMetric.calories,
      period: FitnessGoalPeriod.weekly,
      targetValue: 1000,
    );

    expect(await controller.createGoal(input), isTrue);
    expect(await controller.createGoal(input), isFalse);
    expect(controller.goals, hasLength(1));
    expect(controller.goalErrorMessage, contains('already exists'));
  });
}

class _FakeFitnessRepository implements FitnessRepository {
  final List<FitnessGoal> _goals = [];
  var _nextId = 1;

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

  @override
  Future<List<FitnessGoal>> fetchGoals({required String userId}) async =>
      List.of(_goals);

  @override
  Future<FitnessGoal> createGoal({
    required String userId,
    required FitnessGoalInput input,
  }) async {
    final now = DateTime.now();
    final goal = FitnessGoal(
      id: 'goal-${_nextId++}',
      userId: userId,
      metric: input.metric,
      period: input.period,
      targetValue: input.targetValue,
      createdAt: now,
      updatedAt: now,
    );
    _goals.add(goal);
    return goal;
  }

  @override
  Future<FitnessGoal> updateGoal({
    required String userId,
    required String goalId,
    required FitnessGoalInput input,
  }) async {
    final index = _goals.indexWhere((goal) => goal.id == goalId);
    final previous = _goals[index];
    final updated = FitnessGoal(
      id: previous.id,
      userId: userId,
      metric: input.metric,
      period: input.period,
      targetValue: input.targetValue,
      createdAt: previous.createdAt,
      updatedAt: DateTime.now(),
    );
    _goals[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteGoal({
    required String userId,
    required String goalId,
  }) async {
    _goals.removeWhere((goal) => goal.id == goalId);
  }
}

class _FailingFitnessRepository implements FitnessRepository {
  @override
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  }) => Future.error(Exception('offline'));

  @override
  Future<List<FitnessGoal>> fetchGoals({required String userId}) async => [];

  @override
  Future<FitnessGoal> createGoal({
    required String userId,
    required FitnessGoalInput input,
  }) => throw UnimplementedError();

  @override
  Future<FitnessGoal> updateGoal({
    required String userId,
    required String goalId,
    required FitnessGoalInput input,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteGoal({required String userId, required String goalId}) =>
      throw UnimplementedError();
}
