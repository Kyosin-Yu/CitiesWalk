import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_goal.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_history.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/fitness_recent_badge.dart';
import 'package:citieswalk/features/fitness/business_logic/providers/fitness_controller.dart';
import 'package:citieswalk/features/fitness/business_logic/repositories/fitness_repository.dart';
import 'package:citieswalk/features/fitness/presentation/pages/fitness_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows the calendar and changes the history range', (
    tester,
  ) async {
    final controller = FitnessController(
      userId: 'user-1',
      userName: 'Alex',
      repository: _HistoryRepository(),
    );
    await controller.loadDashboard();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: controller,
          child: const FitnessHistoryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fitness History'), findsOneWidget);
    expect(find.text('Activity calendar'), findsOneWidget);
    expect(
      find.text('Dates without a saved Fitness record are disabled.'),
      findsOneWidget,
    );
    expect(controller.historyPeriod, FitnessHistoryPeriod.daily);
    expect(controller.isHistoryDateSelectable(DateTime(2026, 8, 4)), isFalse);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    expect(controller.historyPeriod, FitnessHistoryPeriod.monthly);
    expect(controller.historySummary?.journeyCount, 2);
    expect(controller.historySummary?.walkingDistanceKm, 5);
  });
}

class _HistoryRepository implements FitnessRepository {
  @override
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  }) async => [
    CompletedFitnessJourney(
      id: 'first',
      walkingDistanceMeters: 2000,
      estimatedCalories: 140,
      estimatedCarbonSavedKg: .5,
      startedAt: DateTime(2026, 8, 3, 8),
      completedAt: DateTime(2026, 8, 3, 9),
    ),
    CompletedFitnessJourney(
      id: 'second',
      walkingDistanceMeters: 3000,
      estimatedCalories: 210,
      estimatedCarbonSavedKg: .8,
      startedAt: DateTime(2026, 8, 5, 8),
      completedAt: DateTime(2026, 8, 5, 9),
    ),
  ];

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
