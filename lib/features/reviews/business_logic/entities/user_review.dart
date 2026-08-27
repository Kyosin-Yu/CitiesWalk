import 'place_review.dart';
import 'review_destination.dart';

class UserReview {
  const UserReview({required this.destination, required this.review});

  final ReviewDestination destination;
  final PlaceReview review;
}
