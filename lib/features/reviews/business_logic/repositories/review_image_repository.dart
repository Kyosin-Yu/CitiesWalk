import '../entities/place_review.dart';
import '../entities/review_photo_moderation_result.dart';

/// Contract for selecting review images without exposing a platform plugin to
/// the presentation layer.
abstract class ReviewImageRepository {
  Future<List<ReviewPhoto>> pickPhotos();

  /// Reviews locally selected photos before they can be attached to a review.
  Future<ReviewPhotoModerationResult> moderatePhoto(ReviewPhoto photo);
}
