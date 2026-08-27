import 'package:citieswalk/features/reviews/business_logic/providers/my_reviews_provider.dart';
import 'package:citieswalk/features/reviews/data/repositories/in_memory_review_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads only reviews owned by the requested user', () async {
    final provider = MyReviewsProvider(
      InMemoryReviewRepository(),
      'seed-sarah',
    );

    await provider.load();

    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    expect(provider.reviews, isNotEmpty);
    expect(
      provider.reviews.every((item) => item.review.userId == 'seed-sarah'),
      isTrue,
    );

    provider.dispose();
  });
}
