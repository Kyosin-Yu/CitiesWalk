import '../entities/place_review.dart';
import '../entities/review_destination.dart';

/// Contract for retrieving and changing reviews for one destination.
///
/// A Supabase implementation can replace the temporary local implementation
/// once the team confirms the reviews schema and Row Level Security policies.
abstract interface class ReviewRepository {
  Future<List<PlaceReview>> fetchReviews(String destinationId);

  Future<PlaceReview> addReview({
    required ReviewDestination destination,
    required PlaceReview review,
  });

  Future<PlaceReview> updateReview({
    required ReviewDestination destination,
    required PlaceReview review,
  });

  Future<void> deleteReview({
    required String destinationId,
    required String reviewId,
    required String userId,
  });

  Future<void> reportReview({
    required String reviewId,
    required String reporterId,
    required ReviewReportReason reason,
    String? details,
  });

  Future<PlaceReview> toggleHelpful({
    required String reviewId,
    required String userId,
  });
}

enum ReviewReportReason { spam, offensive, misleading, other }
