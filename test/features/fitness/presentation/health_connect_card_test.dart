import 'package:citieswalk/features/fitness/business_logic/entities/health_activity.dart';
import 'package:citieswalk/features/fitness/presentation/widgets/health_connect_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('explains read-only access before connecting', (tester) async {
    var connectCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthConnectCard(
            status: HealthIntegrationStatus.permissionRequired,
            isBusy: false,
            onConnect: () async => connectCalls++,
            onDisconnect: () async {},
            onInstall: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Connect health data'), findsOneWidget);
    expect(
      find.text('CitiesWalk requests read-only access to activity data.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Connect'));
    await tester.pump();
    expect(connectCalls, 1);
  });

  testWidgets('shows synced Health Connect values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthConnectCard(
            status: HealthIntegrationStatus.connected,
            snapshot: HealthActivitySnapshot(
              syncedAt: DateTime(2026, 8, 25, 10, 5),
              stepsToday: 6400,
              walkingDistanceMetersToday: 4900,
              activeCaloriesToday: 320,
            ),
            isBusy: false,
            onConnect: () async {},
            onDisconnect: () async {},
            onInstall: () async {},
          ),
        ),
      ),
    );

    expect(find.text('Health Connect synced'), findsOneWidget);
    expect(find.text('6400'), findsOneWidget);
    expect(find.text('4.90'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
  });
}
