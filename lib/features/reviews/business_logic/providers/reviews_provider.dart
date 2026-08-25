import 'package:flutter/foundation.dart';

import '../../../../core/models/destination_review_summary.dart';
import '../entities/place_review.dart';
import '../entities/review_destination.dart';
import '../repositories/review_image_repository.dart';
import '../repositories/review_repository.dart';

/// ChangeNotifier state for the Community Reviews presentation layer.
class ReviewsProvider extends ChangeNotifier {
  static const maxPhotosPerReview = 5;
  static const maxPhotoBytes = 5 * 1024 * 1024;
  ReviewsProvider(
    this._repository,
    this._imageRepository,
    this._destination, {
    this.currentUserId = _fallbackCurrentUserId,
    this.currentUserName = 'You',
  }) {
    loadReviews();
  }

  static const _fallbackCurrentUserId = 'my-review';

  final ReviewRepository _repository;
  final ReviewImageRepository _imageRepository;
  final ReviewDestination _destination;
  final String currentUserId;
  final String currentUserName;
  List<PlaceReview> _reviews = const [];
  PlaceReview? _myReview;
  String? _errorMessage;
  List<ReviewPhoto> _draftPhotos = const [];
  final Set<String> _helpfulReviewIdsBeingUpdated = <String>{};
  bool _isSelectingPhotos = false;
  bool _isLoading = false;
  bool _isSaving = false;

  List<PlaceReview> get reviews => List.unmodifiable(_reviews);
  PlaceReview? get myReview => _myReview;
  String? get errorMessage => _errorMessage;
  List<ReviewPhoto> get draftPhotos => List.unmodifiable(_draftPhotos);
  bool get isSelectingPhotos => _isSelectingPhotos;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool isUpdatingHelpful(String reviewId) =>
      _helpfulReviewIdsBeingUpdated.contains(reviewId);
  DestinationReviewSummary get summary {
    if (_reviews.isEmpty) return DestinationReviewSummary.empty;
    final total = _reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return DestinationReviewSummary(
      averageRating: total / _reviews.length,
      reviewCount: _reviews.length,
    );
  }

  Future<void> loadReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _repository.fetchReviews(_destination.id);
      _myReview = null;
      for (final review in _reviews) {
        if (review.userId == currentUserId) {
          _myReview = review;
          break;
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Review loading failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to load reviews. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void beginDraft([List<ReviewPhoto> photos = const []]) {
    _draftPhotos = List.unmodifiable(photos);
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addDraftPhotos() async {
    _isSelectingPhotos = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photos = await _imageRepository.pickPhotos();
      final acceptedPhotos = photos
          .where((photo) => (photo.bytes?.lengthInBytes ?? 0) <= maxPhotoBytes)
          .toList();
      final rejectedCount = photos.length - acceptedPhotos.length;
      final remainingSlots = maxPhotosPerReview - _draftPhotos.length;
      if (remainingSlots <= 0) {
        _errorMessage = 'A review can have up to $maxPhotosPerReview photos.';
        return;
      }
      _draftPhotos = List.unmodifiable([
        ..._draftPhotos,
        ...acceptedPhotos.take(remainingSlots),
      ]);
      if (rejectedCount > 0 || acceptedPhotos.length > remainingSlots) {
        _errorMessage =
            'Photos must be 5 MB or smaller. Up to $maxPhotosPerReview photos can be added.';
      }
    } catch (error, stackTrace) {
      debugPrint('Review photo selection failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to select photos. Please try again.';
    } finally {
      _isSelectingPhotos = false;
      notifyListeners();
    }
  }

  void removeDraftPhoto(ReviewPhoto photo) {
    _draftPhotos = List.unmodifiable(
      _draftPhotos.where((item) => item.id != photo.id),
    );
    notifyListeners();
  }

  Future<bool> submitReview({
    required int rating,
    required String comment,
    required bool isAnonymous,
  }) async {
    final validationError = _validate(rating: rating, comment: comment);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    final review = PlaceReview(
      id: 'draft-${DateTime.now().microsecondsSinceEpoch}',
      userId: currentUserId,
      authorName: currentUserName,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
      photos: _draftPhotos,
    );
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myReview = await _repository.addReview(
        destination: _destination,
        review: review,
      );
      _draftPhotos = const [];
      await loadReviews();
      return _errorMessage == null;
    } catch (error, stackTrace) {
      debugPrint('Review submission failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to submit your review. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateMyReview({
    required int rating,
    required String comment,
    required bool isAnonymous,
  }) async {
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
      isAnonymous: isAnonymous,
      photos: _draftPhotos,
    );
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myReview = await _repository.updateReview(
        destination: _destination,
        review: updatedReview,
      );
      _draftPhotos = const [];
      await loadReviews();
      return _errorMessage == null;
    } catch (error, stackTrace) {
      debugPrint('Review update failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to save your review. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMyReview() async {
    final review = _myReview;
    if (review == null) {
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteReview(
        destinationId: _destination.id,
        reviewId: review.id,
        userId: currentUserId,
      );
      _myReview = null;
      await loadReviews();
      return _errorMessage == null;
    } catch (error, stackTrace) {
      debugPrint('Review deletion failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to delete your review. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> reportReview({
    required String reviewId,
    required ReviewReportReason reason,
    String? details,
  }) async {
    try {
      await _repository.reportReview(
        reviewId: reviewId,
        reporterId: currentUserId,
        reason: reason,
        details: details,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('Review reporting failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to send the report. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<PlaceReview?> toggleHelpful(String reviewId) async {
    if (!_helpfulReviewIdsBeingUpdated.add(reviewId)) {
      return null;
    }
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.toggleHelpful(
        reviewId: reviewId,
        userId: currentUserId,
      );
      _reviews = List.unmodifiable(
        _reviews.map((review) => review.id == reviewId ? updated : review),
      );
      if (_myReview?.id == reviewId) {
        _myReview = updated;
      }
      _errorMessage = null;
      notifyListeners();
      return updated;
    } catch (error, stackTrace) {
      debugPrint('Helpful mark update failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to update the helpful mark. Please try again.';
      return null;
    } finally {
      _helpfulReviewIdsBeingUpdated.remove(reviewId);
      notifyListeners();
    }
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
