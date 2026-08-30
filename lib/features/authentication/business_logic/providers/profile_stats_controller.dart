import 'package:flutter/foundation.dart';

import '../entities/profile_stats.dart';
import '../repositories/profile_stats_repository.dart';

class ProfileStatsController extends ChangeNotifier {
  ProfileStatsController(this._repository);

  final ProfileStatsRepository _repository;

  ProfileStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({required String userId}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _repository.fetchStats(userId: userId);
    } catch (error) {
      _errorMessage = 'Unable to load profile statistics. Pull down to retry.';
      debugPrint('Profile statistics load failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
