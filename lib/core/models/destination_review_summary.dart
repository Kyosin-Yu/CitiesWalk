/// A review aggregate shared by the Eco-Route and Reviews features.
class DestinationReviewSummary {
  const DestinationReviewSummary({
    required this.averageRating,
    required this.reviewCount,
  });

  static const empty = DestinationReviewSummary(
    averageRating: 0,
    reviewCount: 0,
  );

  final double averageRating;
  final int reviewCount;

  bool get hasReviews => reviewCount > 0;
}
