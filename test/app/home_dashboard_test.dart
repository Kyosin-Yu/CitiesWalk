import 'package:citieswalk/app/home_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens Explore from the eco-route call to action', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeDashboard(onNavigate: (index) => selectedIndex = index),
      ),
    );

    await tester.tap(find.text('Plan an eco route'));

    expect(selectedIndex, 1);
  });
}
