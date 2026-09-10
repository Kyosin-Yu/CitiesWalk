import 'dart:typed_data';

import 'package:citieswalk/features/reviews/business_logic/entities/place_review.dart';
import 'package:citieswalk/features/reviews/business_logic/entities/review_photo_moderation_result.dart';
import 'package:citieswalk/features/reviews/business_logic/providers/reviews_provider.dart';
import 'package:citieswalk/features/reviews/business_logic/repositories/review_image_repository.dart';
import 'package:citieswalk/features/reviews/business_logic/services/review_text_moderation_service.dart';
import 'package:citieswalk/features/reviews/data/datasources/review_seed_data.dart';
import 'package:citieswalk/features/reviews/data/repositories/in_memory_review_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewTextModerationService', () {
    const service = ReviewTextModerationService();

    test('rejects offensive language', () {
      expect(
        service.validate('This place is shit.'),
        'Please remove offensive language from your review.',
      );
    });

    test('rejects links and promotional contact details', () {
      expect(
        service.validate(
          'Message me on WhatsApp or visit https://example.com.',
        ),
        'Reviews cannot include links, contact details, or promotional content.',
      );
    });

    test('allows an ordinary destination review', () {
      expect(
        service.validate('A pleasant walking route with clear signs.'),
        isNull,
      );
    });
  });

  test('does not add a photo rejected by server-side moderation', () async {
    final provider = ReviewsProvider(
      InMemoryReviewRepository(),
      _FakeImageRepository(
        photos: <ReviewPhoto>[
          ReviewPhoto(
            id: 'unsafe-photo',
            name: 'unsafe.png',
            bytes: Uint8List.fromList(<int>[1, 2, 3]),
            contentType: 'image/png',
          ),
        ],
        moderationResult: const ReviewPhotoModerationResult.rejected(
          'This photo cannot be attached because it contains inappropriate content.',
        ),
      ),
      reviewDestinations.first,
    );
    await provider.loadReviews();

    await provider.addDraftPhotos();

    expect(provider.draftPhotos, isEmpty);
    expect(
      provider.errorMessage,
      'This photo cannot be attached because it contains inappropriate content.',
    );
  });
}

class _FakeImageRepository implements ReviewImageRepository {
  const _FakeImageRepository({
    required this.photos,
    required this.moderationResult,
  });

  final List<ReviewPhoto> photos;
  final ReviewPhotoModerationResult moderationResult;

  @override
  Future<List<ReviewPhoto>> pickPhotos() async => photos;

  @override
  Future<ReviewPhotoModerationResult> moderatePhoto(ReviewPhoto photo) async =>
      moderationResult;
}
