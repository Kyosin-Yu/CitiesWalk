import '../../business_logic/entities/place_review.dart';
import '../../business_logic/entities/review_photo_moderation_result.dart';
import '../../business_logic/repositories/review_image_repository.dart';
import '../data_sources/review_image_data_source.dart';
import '../data_sources/review_image_moderation_data_source.dart';

class ReviewImageRepositoryImpl implements ReviewImageRepository {
  const ReviewImageRepositoryImpl(
    this._dataSource, {
    this._moderationDataSource,
  });

  final ReviewImageDataSource _dataSource;
  final ReviewImageModerationDataSource? _moderationDataSource;

  @override
  Future<List<ReviewPhoto>> pickPhotos() => _dataSource.pickPhotos();

  @override
  Future<ReviewPhotoModerationResult> moderatePhoto(ReviewPhoto photo) {
    final dataSource = _moderationDataSource;
    if (dataSource == null) {
      return Future<ReviewPhotoModerationResult>.value(
        const ReviewPhotoModerationResult.rejected(
          'Photo moderation is unavailable. Please try again later.',
        ),
      );
    }
    return dataSource.moderate(photo);
  }
}
