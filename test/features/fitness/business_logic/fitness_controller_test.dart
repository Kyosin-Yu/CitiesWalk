import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_goal.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_history.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_recent_badge.dart';
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
    expect(controller.dashboard?.stepsToday, 0);
    expect(controller.dashboard?.ecoPoints, isNull);
    expect(controller.availableHistoryDates, hasLength(1));
    expect(controller.selectedHistoryDate, isNotNull);
    expect(controller.historySummary?.journeyCount, 1);
    expect(controller.recentActivities, hasLength(1));
    expect(controller.recentBadges, hasLength(1));
    expect(
      controller.isHistoryDateSelectable(
        DateTime.now().subtract(const Duration(days: 5)),
      ),
      isFalse,
    );

    controller.selectHistoryPeriod(FitnessHistoryPeriod.yearly);
    expect(controller.historyPeriod, FitnessHistoryPeriod.yearly);

    controller.selectGoalFilter(FitnessGoalStatus.completed);
    expect(controller.goalFilter, FitnessGoalStatus.completed);
    expect(controller.visibleGoals, isEmpty);

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

  test('creates and cancels a locked personal fitness goal', () async {
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
    expect(controller.goals.single.isActive, isTrue);

    final cancelled = await controller.cancelGoal(controller.goals.single);

    expect(cancelled, isTrue);
    expect(controller.goals.single.isCancelled, isTrue);

    expect(
      await controller.createGoal(
        const FitnessGoalInput(
          metric: FitnessGoalMetric.walkingDistance,
          period: FitnessGoalPeriod.daily,
          targetValue: 3,
        ),
      ),
      isTrue,
    );
    expect(controller.goals.where((goal) => goal.isActive), hasLength(1));
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
      startedAt: DateTime.now().subtract(const Duration(hours: 1)),
      completedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<FitnessGoal>> fetchGoals({required String userId}) async =>
      List.of(_goals);

  @override
  Future<List<FitnessRecentBadge>> fetchRecentBadges({
    required String userId,
  }) async => [
    FitnessRecentBadge(
      id: 'badge-1',
      title: 'First Walker',
      description: 'Complete your first walk.',
      iconKey: 'directionsWalk',
      unlockedAt: DateTime.now(),
    ),
  ];

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
      status: FitnessGoalStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    _goals.add(goal);
    return goal;
  }

  @override
  Future<FitnessGoal> cancelGoal({
    required String userId,
    required String goalId,
  }) async {
    final index = _goals.indexWhere((goal) => goal.id == goalId);
    final previous = _goals[index];
    final cancelled = FitnessGoal(
      id: previous.id,
      userId: userId,
      metric: previous.metric,
      period: previous.period,
      targetValue: previous.targetValue,
      status: FitnessGoalStatus.cancelled,
      createdAt: previous.createdAt,
      updatedAt: DateTime.now(),
      cancelledAt: DateTime.now(),
    );
    _goals[index] = cancelled;
    return cancelled;
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
  Future<List<FitnessRecentBadge>> fetchRecentBadges({
    required String userId,
  }) async => [];

  @override
  Future<FitnessGoal> createGoal({
    required String userId,
    required FitnessGoalInput input,
  }) => throw UnimplementedError();

  @override
  Future<FitnessGoal> cancelGoal({
    required String userId,
    required String goalId,
  }) => throw UnimplementedError();
}
