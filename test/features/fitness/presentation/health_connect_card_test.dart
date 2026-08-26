import 'package:citieswalk/features/fitness/presentation/widgets/health_connect_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('explains Health Connect support without an action button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HealthConnectCard())),
    );

    expect(find.text('Health Connect support'), findsOneWidget);
    expect(
      find.textContaining('daily steps, walking distance and active calories'),
      findsOneWidget,
    );
    expect(
      find.text('Available on supported Android devices.'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });
}
