import '../../business_logic/entities/place_review.dart';
import '../../business_logic/repositories/review_image_repository.dart';
import '../data_sources/review_image_data_source.dart';

class ReviewImageRepositoryImpl implements ReviewImageRepository {
  const ReviewImageRepositoryImpl(this._dataSource);

  final ReviewImageDataSource _dataSource;

  @override
  Future<List<ReviewPhoto>> pickPhotos() => _dataSource.pickPhotos();
}
