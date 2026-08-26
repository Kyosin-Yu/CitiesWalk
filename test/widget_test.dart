import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citieswalk/features/reviews/business_logic/entities/place_review.dart';
import 'package:citieswalk/features/reviews/business_logic/providers/reviews_provider.dart';
import 'package:citieswalk/features/reviews/data/data_sources/review_image_data_source.dart';
import 'package:citieswalk/features/reviews/data/datasources/review_seed_data.dart';
import 'package:citieswalk/features/reviews/data/repositories/in_memory_review_repository.dart';
import 'package:citieswalk/features/reviews/data/repositories/review_image_repository_impl.dart';
import 'package:citieswalk/features/reviews/presentation/reviews_screen.dart';

Widget _buildReviewsScreen() {
  final destination = reviewDestinations.first;
  return MaterialApp(
    home: ReviewsScreen(
      destination: destination,
      reviewsProvider: ReviewsProvider(
        InMemoryReviewRepository(),
        ReviewImageRepositoryImpl(ReviewImageDataSource()),
        destination,
      ),
    ),
  );
}

void main() {
  test('in-memory reviews produce a destination rating summary', () async {
    final summary = await InMemoryReviewRepository()
        .getDestinationReviewSummary('petaling-street');

    expect(summary.reviewCount, 3);
    expect(summary.averageRating, closeTo(4.33, 0.01));
  });

  test(
    'a user can add and remove one helpful mark from another review',
    () async {
      final repository = InMemoryReviewRepository();
      final review = (await repository.fetchReviews('petaling-street')).first;

      final marked = await repository.toggleHelpful(
        reviewId: review.id,
        userId: 'my-review',
      );
      expect(marked.helpfulCount, review.helpfulCount + 1);
      expect(marked.isMarkedHelpful, isTrue);

      final unmarked = await repository.toggleHelpful(
        reviewId: review.id,
        userId: 'my-review',
      );
      expect(unmarked.helpfulCount, review.helpfulCount);
      expect(unmarked.isMarkedHelpful, isFalse);
    },
  );

  testWidgets('reviews list follows the Community Review design', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildReviewsScreen());

    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('Petaling Street (Chinatown)'), findsOneWidget);
    expect(find.text('Write a Review'), findsOneWidget);
  });

  testWidgets('user can submit a review', (WidgetTester tester) async {
    await tester.pumpWidget(_buildReviewsScreen());

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
    await tester.pumpWidget(_buildReviewsScreen());

    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Give 1 stars'));
    await tester.pumpAndSettle();

    expect(find.text('Poor'), findsOneWidget);
    expect(find.text('Very Good'), findsNothing);
  });

  testWidgets('user can post a review anonymously', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildReviewsScreen());

    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Give 3 stars'));
    await tester.enterText(
      find.byType(TextField),
      'Useful walking route, but it was crowded in the evening.',
    );
    await tester.scrollUntilVisible(
      find.text('Post anonymously'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Post anonymously'));
    await tester.pump();
    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Reviews'));
    await tester.pumpAndSettle();

    expect(find.text('Anonymous walker'), findsOneWidget);
    expect(find.text('You'), findsNothing);
  });

  testWidgets('review editor supports adding more than one photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildReviewsScreen());

    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Add photos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Add photos'), findsOneWidget);
    expect(
      find.text(
        'You can select up to 5 JPEG, PNG, or WebP photos (5 MB each).',
      ),
      findsOneWidget,
    );
  });

  testWidgets('user can view review detail and manage their review', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildReviewsScreen());

    final sarahReview = find.ancestor(
      of: find.text('Sarah Lim'),
      matching: find.byType(InkWell),
    );
    await tester.scrollUntilVisible(
      sarahReview,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Move the review card into view before tapping it.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(sarahReview);
    await tester.pumpAndSettle();
    expect(find.text('Review Detail'), findsOneWidget);
    await tester.tap(find.text('Mark Helpful (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Helpful (1)'), findsOneWidget);
    expect(find.text('Report'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Reviews'));
    await tester.pumpAndSettle();
    expect(find.text('My Reviews'), findsOneWidget);
  });

  testWidgets('a posted review photo opens in a full screen preview', (
    WidgetTester tester,
  ) async {
    final destination = reviewDestinations.first;
    final repository = InMemoryReviewRepository();
    await repository.addReview(
      destination: destination,
      review: PlaceReview(
        id: 'photo-review',
        userId: 'photo-owner',
        authorName: 'Photo reviewer',
        rating: 5,
        comment: 'The photo can be opened after the review is posted.',
        createdAt: DateTime(2026, 8, 24),
        photos: [
          ReviewPhoto(
            id: 'photo-1',
            name: 'photo-test.png',
            bytes: Uint8List(0),
          ),
        ],
      ),
    );
    final provider = ReviewsProvider(
      repository,
      ReviewImageRepositoryImpl(ReviewImageDataSource()),
      destination,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ReviewsScreen(
          destination: destination,
          reviewsProvider: provider,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final photoStrip = find.byKey(
      const ValueKey('review-photo-strip-photo-review'),
    );
    await tester.scrollUntilVisible(
      photoStrip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(photoStrip, findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('review-photo-photo-1')));
    await tester.pumpAndSettle();

    expect(find.text('1 of 1'), findsOneWidget);
  });

  testWidgets('user can edit and delete their own review', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildReviewsScreen());

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
    expect(find.text('Review deleted.'), findsOneWidget);
    expect(find.text('No reviews written'), findsOneWidget);
  });
}
