import '../entities/place_review.dart';

/// Contract for selecting review images without exposing a platform plugin to
/// the presentation layer.
abstract class ReviewImageRepository {
  Future<List<ReviewPhoto>> pickPhotos();
}
