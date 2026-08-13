import 'package:citieswalk/app/home_dashboard.dart';
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
          onNavigate: (index) => selectedIndex = index,
        ),
      ),
    );

    await tester.tap(find.text('Plan eco route'));

    expect(selectedIndex, 1);
  });
}

class _EmptyJourneyHistoryRepository implements JourneyHistoryRepository {
  const _EmptyJourneyHistoryRepository();

  @override
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  }) async => const [];
}
