class PlaceReview {
  const PlaceReview({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  PlaceReview copyWith({int? rating, String? comment, DateTime? createdAt}) {
    return PlaceReview(
      id: id,
      authorName: authorName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
