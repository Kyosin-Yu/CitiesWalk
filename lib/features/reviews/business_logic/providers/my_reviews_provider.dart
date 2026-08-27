import 'package:flutter/foundation.dart';

import '../entities/user_review.dart';
import '../repositories/review_repository.dart';

class MyReviewsProvider extends ChangeNotifier {
  MyReviewsProvider(this._repository, this._userId);

  final ReviewRepository _repository;
  final String _userId;

  List<UserReview> _reviews = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserReview> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _repository.fetchUserReviews(_userId);
    } catch (error, stackTrace) {
      debugPrint('Unable to load the current user reviews: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to load your reviews. Pull to try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
