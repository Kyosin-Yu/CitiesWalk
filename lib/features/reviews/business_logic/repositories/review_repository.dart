import '../entities/place_review.dart';
import '../entities/review_destination.dart';
import '../entities/user_review.dart';

/// Contract for retrieving and changing reviews for one destination.
///
/// A Supabase implementation can replace the temporary local implementation
/// once the team confirms the reviews schema and Row Level Security policies.
abstract interface class ReviewRepository {
  Future<List<PlaceReview>> fetchReviews(String destinationId);

  Future<List<UserReview>> fetchUserReviews(String userId);

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

  Future<PlaceReview> toggleHelpful({
    required String reviewId,
    required String userId,
  });
}
