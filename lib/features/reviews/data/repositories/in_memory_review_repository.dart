import '../../business_logic/entities/place_review.dart';
import '../datasources/review_seed_data.dart';
import 'review_repository.dart';

/// In-memory data source for the Reviews MVP.
///
/// It deliberately has no Supabase code while the team has not confirmed the
/// review table, ownership rules, or database migration.
class InMemoryReviewRepository implements ReviewRepository {
  InMemoryReviewRepository()
    : _reviewsByDestination = {
        for (final entry in initialReviewsByDestination.entries)
          entry.key: List<PlaceReview>.of(entry.value),
      };

  final Map<String, List<PlaceReview>> _reviewsByDestination;

  @override
  List<PlaceReview> fetchReviews(String destinationId) {
    return List.unmodifiable(_reviewsByDestination[destinationId] ?? const []);
  }

  @override
  void addReview({required String destinationId, required PlaceReview review}) {
    _reviewsByDestination.putIfAbsent(destinationId, () => []).add(review);
  }

  @override
  void updateReview({
    required String destinationId,
    required PlaceReview review,
  }) {
    final reviews = _reviewsByDestination[destinationId];
    final reviewIndex =
        reviews?.indexWhere((item) => item.id == review.id) ?? -1;
    if (reviewIndex == -1) {
      throw StateError('The review could not be found.');
    }
    reviews![reviewIndex] = review;
  }

  @override
  void deleteReview({required String destinationId, required String reviewId}) {
    _reviewsByDestination[destinationId]?.removeWhere(
      (review) => review.id == reviewId,
    );
  }
}
