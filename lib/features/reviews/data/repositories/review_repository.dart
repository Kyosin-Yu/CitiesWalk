import '../../business_logic/entities/place_review.dart';

/// Contract for retrieving and changing reviews for one destination.
///
/// A Supabase implementation can replace the temporary local implementation
/// once the team confirms the reviews schema and Row Level Security policies.
abstract interface class ReviewRepository {
  List<PlaceReview> fetchReviews(String destinationId);

  void addReview({required String destinationId, required PlaceReview review});

  void updateReview({
    required String destinationId,
    required PlaceReview review,
  });

  void deleteReview({required String destinationId, required String reviewId});
}
