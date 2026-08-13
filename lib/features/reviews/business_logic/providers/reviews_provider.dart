import 'package:flutter/foundation.dart';

import '../../data/repositories/review_repository.dart';
import '../entities/place_review.dart';
import '../entities/review_destination.dart';

/// ChangeNotifier state for the Community Reviews presentation layer.
class ReviewsProvider extends ChangeNotifier {
  ReviewsProvider(this._repository, this._destination) {
    loadReviews();
  }

  static const _currentUserReviewId = 'my-review';

  final ReviewRepository _repository;
  final ReviewDestination _destination;
  List<PlaceReview> _reviews = const [];
  PlaceReview? _myReview;
  String? _errorMessage;

  List<PlaceReview> get reviews => List.unmodifiable(_reviews);
  PlaceReview? get myReview => _myReview;
  String? get errorMessage => _errorMessage;

  void loadReviews() {
    _reviews = _repository.fetchReviews(_destination.id);
    _errorMessage = null;
    notifyListeners();
  }

  bool submitReview({required int rating, required String comment}) {
    final validationError = _validate(rating: rating, comment: comment);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    final review = PlaceReview(
      id: _currentUserReviewId,
      authorName: 'You',
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    _repository.addReview(destinationId: _destination.id, review: review);
    _myReview = review;
    loadReviews();
    return true;
  }

  bool updateMyReview({required int rating, required String comment}) {
    final review = _myReview;
    final validationError = _validate(rating: rating, comment: comment);
    if (review == null) {
      _errorMessage = 'No review is available to edit.';
      notifyListeners();
      return false;
    }
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    final updatedReview = review.copyWith(
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    _repository.updateReview(
      destinationId: _destination.id,
      review: updatedReview,
    );
    _myReview = updatedReview;
    loadReviews();
    return true;
  }

  void deleteMyReview() {
    final review = _myReview;
    if (review == null) {
      return;
    }
    _repository.deleteReview(
      destinationId: _destination.id,
      reviewId: review.id,
    );
    _myReview = null;
    loadReviews();
  }

  String? _validate({required int rating, required String comment}) {
    if (rating < 1 || rating > 5) {
      return 'Please select a rating from 1 to 5 stars.';
    }
    if (comment.trim().isEmpty) {
      return 'Please write a review before submitting.';
    }
    return null;
  }
}
