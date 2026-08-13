import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citieswalk/features/reviews/presentation/reviews_screen.dart';

void main() {
  testWidgets('reviews list follows the Community Review design', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewsScreen()));

    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('Petaling Street (Chinatown)'), findsOneWidget);
    expect(find.text('Write a Review'), findsOneWidget);
  });

  testWidgets('user can submit a review', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewsScreen()));

    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Give 5 stars'));
    await tester.enterText(
      find.byType(TextField),
      'The food stalls were wonderful and easy to reach by train.',
    );
    await tester.pump();
    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();

    expect(find.text('Review Submitted'), findsOneWidget);
    expect(
      find.text('♧  Your review is now visible to fellow walkers.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Back to Reviews'));
    await tester.pumpAndSettle();
    expect(find.text('4 Reviews'), findsOneWidget);
    expect(
      find.text('The food stalls were wonderful and easy to reach by train.'),
      findsOneWidget,
    );

    await tester.tap(find.text('My Reviews'));
    await tester.pumpAndSettle();
    expect(find.text('1 review written'), findsOneWidget);
    expect(
      find.text('The food stalls were wonderful and easy to reach by train.'),
      findsOneWidget,
    );
  });

  testWidgets('rating description matches the selected star count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewsScreen()));

    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Give 1 stars'));
    await tester.pumpAndSettle();

    expect(find.text('Poor'), findsOneWidget);
    expect(find.text('Very Good'), findsNothing);
  });

  testWidgets('user can view review detail and manage their review', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewsScreen()));

    await tester.tap(find.text('Sarah Lim'));
    await tester.pumpAndSettle();
    expect(find.text('Review Detail'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Reviews'));
    await tester.pumpAndSettle();
    expect(find.text('My Reviews'), findsOneWidget);
  });

  testWidgets('user can edit and delete their own review', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReviewsScreen()));

    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Give 4 stars'));
    await tester.enterText(
      find.byType(TextField),
      'A vibrant place with fantastic food and friendly vendors.',
    );
    await tester.pump();
    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Reviews'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Reviews'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Updated review with a brilliant evening food walk.',
    );
    await tester.pump();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(
      find.text('Updated review with a brilliant evening food walk.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Review?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('No reviews written'), findsOneWidget);
  });
}
