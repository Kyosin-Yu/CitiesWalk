import '../../../../core/models/destination_review_summary.dart';
import '../../../../core/services/destination_review_summary_service.dart';
import '../../business_logic/entities/place_review.dart';
import '../../business_logic/entities/review_destination.dart';
import '../../business_logic/entities/user_review.dart';
import '../../business_logic/repositories/review_repository.dart';
import '../data_sources/supabase_review_data_source.dart';

/// Production repository backed by Supabase Database and Storage.
class SupabaseReviewRepository
    implements ReviewRepository, DestinationReviewSummaryService {
  const SupabaseReviewRepository(this._dataSource);

  final SupabaseReviewDataSource _dataSource;

  @override
  Future<List<PlaceReview>> fetchReviews(String destinationId) =>
      _dataSource.fetchReviews(destinationId);

  @override
  Future<List<UserReview>> fetchUserReviews(String userId) =>
      _dataSource.fetchUserReviews(userId);

  @override
  Future<PlaceReview> addReview({
    required ReviewDestination destination,
    required PlaceReview review,
  }) => _dataSource.createReview(destination: destination, review: review);

  @override
  Future<PlaceReview> updateReview({
    required ReviewDestination destination,
    required PlaceReview review,
  }) => _dataSource.updateReview(review: review);

  @override
  Future<void> deleteReview({
    required String destinationId,
    required String reviewId,
    required String userId,
  }) => _dataSource.deleteReview(reviewId: reviewId, userId: userId);

  @override
  Future<PlaceReview> toggleHelpful({
    required String reviewId,
    required String userId,
  }) => _dataSource.toggleHelpful(reviewId: reviewId, userId: userId);

  @override
  Future<DestinationReviewSummary> getDestinationReviewSummary(
    String destinationId,
  ) => _dataSource.fetchRatingSummary(destinationId);
}
