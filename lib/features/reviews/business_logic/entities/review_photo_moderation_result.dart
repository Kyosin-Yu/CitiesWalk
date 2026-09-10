/// The server-side review of a photo before it can be attached to a review.
class ReviewPhotoModerationResult {
  const ReviewPhotoModerationResult._({required this.isApproved, this.message});

  const ReviewPhotoModerationResult.approved() : this._(isApproved: true);

  const ReviewPhotoModerationResult.rejected(String message)
    : this._(isApproved: false, message: message);

  final bool isApproved;
  final String? message;
}
