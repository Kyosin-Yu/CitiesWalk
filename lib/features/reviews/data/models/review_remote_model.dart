import '../../business_logic/entities/place_review.dart';

/// Maps the `destination_reviews` and `review_photos` database rows to the
/// Reviews business entity. This model must not be used by presentation code.
class ReviewRemoteModel {
  const ReviewRemoteModel(this.row);

  final Map<String, dynamic> row;

  String get id => row['id'] as String;

  PlaceReview toEntity({
    required List<ReviewPhoto> photos,
    required bool isMarkedHelpful,
  }) {
    return PlaceReview(
      id: id,
      userId: row['user_id'] as String,
      authorName: row['author_name'] as String,
      rating: row['rating'] as int,
      comment: row['comment'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      isAnonymous: row['is_anonymous'] as bool? ?? false,
      photos: photos,
      helpfulCount: row['helpful_count'] as int? ?? 0,
      isMarkedHelpful: isMarkedHelpful,
    );
  }

  static Map<String, dynamic> insertPayload(PlaceReview review) {
    return {
      'user_id': review.userId,
      'author_name': review.isAnonymous
          ? 'Anonymous walker'
          : review.authorName,
      'rating': review.rating,
      'comment': review.comment,
      'is_anonymous': review.isAnonymous,
      'moderation_status': 'published',
    };
  }

  /// Only fields the review owner is allowed to edit after creation.
  /// Destination identity and moderation state are deliberately immutable here.
  static Map<String, dynamic> updatePayload(PlaceReview review) {
    return {
      'author_name': review.isAnonymous
          ? 'Anonymous walker'
          : review.authorName,
      'rating': review.rating,
      'comment': review.comment,
      'is_anonymous': review.isAnonymous,
    };
  }
}
