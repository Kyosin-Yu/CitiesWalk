import 'package:flutter_test/flutter_test.dart';
import 'package:citieswalk/app/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CitiesWalkApp());

    expect(find.text('CitiesWalk'), findsOneWidget);
  });
}