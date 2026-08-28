import 'package:citieswalk/features/fitness/presentation/widgets/health_connect_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the Health Connect linking tutorial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HealthConnectCard())),
    );

    expect(find.text('Health Connect support'), findsOneWidget);
    expect(
      find.textContaining('daily steps, walking distance and active calories'),
      findsOneWidget,
    );
    expect(find.text('How to link'), findsOneWidget);

    await tester.tap(find.byKey(const Key('health-connect-tutorial-button')));
    await tester.pumpAndSettle();

    expect(find.text('Link Health Connect'), findsOneWidget);
    expect(find.text('Choose a data source'), findsOneWidget);
    expect(find.text('Enable sharing'), findsOneWidget);
    expect(find.text('Allow CitiesWalk access'), findsOneWidget);
    expect(find.text('Return and refresh'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });
}
