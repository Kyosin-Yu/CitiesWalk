import 'dart:typed_data';

class PlaceReview {
  const PlaceReview({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isAnonymous = false,
    this.photos = const [],
    this.helpfulCount = 0,
    this.isMarkedHelpful = false,
  });

  final String id;
  final String userId;
  final String authorName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final bool isAnonymous;
  final List<ReviewPhoto> photos;
  final int helpfulCount;
  final bool isMarkedHelpful;

  String get displayAuthorName => isAnonymous ? 'Anonymous walker' : authorName;

  PlaceReview copyWith({
    String? id,
    String? userId,
    String? authorName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    bool? isAnonymous,
    List<ReviewPhoto>? photos,
    int? helpfulCount,
    bool? isMarkedHelpful,
  }) {
    return PlaceReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      photos: photos ?? this.photos,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isMarkedHelpful: isMarkedHelpful ?? this.isMarkedHelpful,
    );
  }
}

/// An image selected locally or already stored for a review.
class ReviewPhoto {
  const ReviewPhoto({
    required this.id,
    required this.name,
    this.bytes,
    this.storagePath,
    this.signedUrl,
    this.contentType,
  });

  final String id;
  final String name;
  final Uint8List? bytes;
  final String? storagePath;
  final String? signedUrl;
  final String? contentType;

  bool get isLocal => bytes != null;

  ReviewPhoto copyWith({
    String? id,
    String? name,
    Uint8List? bytes,
    String? storagePath,
    String? signedUrl,
    String? contentType,
  }) {
    return ReviewPhoto(
      id: id ?? this.id,
      name: name ?? this.name,
      bytes: bytes ?? this.bytes,
      storagePath: storagePath ?? this.storagePath,
      signedUrl: signedUrl ?? this.signedUrl,
      contentType: contentType ?? this.contentType,
    );
  }
}
