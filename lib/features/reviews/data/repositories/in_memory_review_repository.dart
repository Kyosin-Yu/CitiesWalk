import '../../../../core/models/destination_review_summary.dart';
import '../../../../core/services/destination_review_summary_service.dart';
import '../../business_logic/entities/place_review.dart';
import '../../business_logic/entities/review_destination.dart';
import '../../business_logic/repositories/review_repository.dart';
import '../datasources/review_seed_data.dart';

/// In-memory data source for the Reviews MVP.
///
/// It deliberately has no Supabase code while the team has not confirmed the
/// review table, ownership rules, or database migration.
class InMemoryReviewRepository
    implements ReviewRepository, DestinationReviewSummaryService {
  InMemoryReviewRepository()
    : _reviewsByDestination = {
        for (final entry in initialReviewsByDestination.entries)
          entry.key: List<PlaceReview>.of(entry.value),
      };

  final Map<String, List<PlaceReview>> _reviewsByDestination;
  final Set<String> _helpfulMarks = <String>{};

  @override
  Future<List<PlaceReview>> fetchReviews(String destinationId) async {
    return List.unmodifiable(_reviewsByDestination[destinationId] ?? const []);
  }

  @override
  Future<DestinationReviewSummary> getDestinationReviewSummary(
    String destinationId,
  ) async {
    final reviews = await fetchReviews(destinationId);
    if (reviews.isEmpty) return DestinationReviewSummary.empty;

    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return DestinationReviewSummary(
      averageRating: total / reviews.length,
      reviewCount: reviews.length,
    );
  }

  @override
  Future<PlaceReview> addReview({
    required ReviewDestination destination,
    required PlaceReview review,
  }) async {
    _reviewsByDestination.putIfAbsent(destination.id, () => []).add(review);
    return review;
  }

  @override
  Future<PlaceReview> updateReview({
    required ReviewDestination destination,
    required PlaceReview review,
  }) async {
    final reviews = _reviewsByDestination[destination.id];
    final reviewIndex =
        reviews?.indexWhere((item) => item.id == review.id) ?? -1;
    if (reviewIndex == -1) {
      throw StateError('The review could not be found.');
    }
    reviews![reviewIndex] = review;
    return review;
  }

  @override
  Future<void> deleteReview({
    required String destinationId,
    required String reviewId,
    required String userId,
  }) async {
    _reviewsByDestination[destinationId]?.removeWhere(
      (review) => review.id == reviewId,
    );
  }

  @override
  Future<void> reportReview({
    required String reviewId,
    required String reporterId,
    required ReviewReportReason reason,
    String? details,
  }) async {
    // The in-memory variant intentionally has no moderation queue.
  }

  @override
  Future<PlaceReview> toggleHelpful({
    required String reviewId,
    required String userId,
  }) async {
    for (final reviews in _reviewsByDestination.values) {
      final index = reviews.indexWhere((review) => review.id == reviewId);
      if (index == -1) continue;

      final review = reviews[index];
      if (review.userId == userId) {
        throw StateError('You cannot mark your own review as helpful.');
      }
      final markKey = '$userId::$reviewId';
      final isMarked = _helpfulMarks.contains(markKey);
      if (isMarked) {
        _helpfulMarks.remove(markKey);
      } else {
        _helpfulMarks.add(markKey);
      }
      final updated = review.copyWith(
        helpfulCount: isMarked
            ? (review.helpfulCount - 1).clamp(0, 1 << 31)
            : review.helpfulCount + 1,
        isMarkedHelpful: !isMarked,
      );
      reviews[index] = updated;
      return updated;
    }
    throw StateError('The review could not be found.');
  }
}
