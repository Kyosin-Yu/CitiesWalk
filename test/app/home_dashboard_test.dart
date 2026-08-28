import 'package:citieswalk/app/home_dashboard.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_destination.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import 'package:citieswalk/features/eco_route/business_logic/repositories/journey_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens Explore from the eco-route call to action', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeDashboard(
          userId: 'test-user',
          journeyHistoryRepository: const _EmptyJourneyHistoryRepository(),
          historyRefreshSignal: ValueNotifier(0),
          onRefresh: () async {},
          onNavigate: (index) => selectedIndex = index,
          onPlanAgain: (_) => selectedIndex = 1,
        ),
      ),
    );

    await tester.tap(find.text('Plan eco route'));

    expect(selectedIndex, 1);
  });

  testWidgets('replans a selected completed journey from trip history', (
    tester,
  ) async {
    EcoJourneyHistoryItem? selectedTrip;
    final trip = EcoJourneyHistoryItem(
      id: 'journey-1',
      destinationName: 'Batu Caves',
      destinationCategory: 'Landmark',
      destinationLatitude: 3.2379,
      destinationLongitude: 101.684,
      durationMinutes: 42,
      walkingDistanceMeters: 900,
      transitDistanceMeters: 2100,
      stepCount: 1170,
      estimatedCalories: 63,
      estimatedCarbonSavedKg: 1.2,
      completedAt: DateTime(2026, 8, 19),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeDashboard(
          userId: 'test-user',
          journeyHistoryRepository: _JourneyHistoryRepository([trip]),
          historyRefreshSignal: ValueNotifier(0),
          onRefresh: () async {},
          onNavigate: (_) {},
          onPlanAgain: (value) => selectedTrip = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Plan again'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('63 kcal · 1.20 kg CO₂ saved'), findsOneWidget);
    await tester.tap(find.text('Plan again'));
    expect(selectedTrip, trip);
  });

  testWidgets('plans a featured place from Home in Eco-Route', (tester) async {
    EcoDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeDashboard(
          userId: 'test-user',
          journeyHistoryRepository: const _EmptyJourneyHistoryRepository(),
          historyRefreshSignal: ValueNotifier(0),
          onRefresh: () async {},
          onNavigate: (_) {},
          onPlanAgain: (_) {},
          onPlanDestination: (destination) => selectedDestination = destination,
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('KLCC Park'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('KLCC Park'));

    expect(selectedDestination?.id, 'klcc-park');
  });
}

class _EmptyJourneyHistoryRepository implements JourneyHistoryRepository {
  const _EmptyJourneyHistoryRepository();

  @override
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  }) async => const [];
}

class _JourneyHistoryRepository implements JourneyHistoryRepository {
  const _JourneyHistoryRepository(this._journeys);

  final List<EcoJourneyHistoryItem> _journeys;

  @override
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  }) async => _journeys;
}
