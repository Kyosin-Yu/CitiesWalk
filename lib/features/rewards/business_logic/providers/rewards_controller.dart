import 'package:flutter/foundation.dart';

import '../entities/badge.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/point_transaction.dart';
import '../repositories/rewards_repository.dart';

enum RewardsStatus { initial, loading, success, failure }

/// Owns the UI state for the Rewards feature.
class RewardsController extends ChangeNotifier {
  RewardsController(this._repository);

  final RewardsRepository _repository;

  RewardsStatus _status = RewardsStatus.initial;
  List<LeaderboardEntry> _leaderboard = const <LeaderboardEntry>[];
  List<RewardBadge> _badges = const <RewardBadge>[];
  List<PointTransaction> _pointHistory = const <PointTransaction>[];
  String? _errorMessage;

  RewardsStatus get status => _status;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  List<RewardBadge> get badges => _badges;
  List<PointTransaction> get pointHistory => _pointHistory;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = RewardsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await Future.wait<Object>(<Future<Object>>[
        _repository.getLeaderboard(),
        _repository.getBadges(),
        _repository.getPointHistory(),
      ]);
      _leaderboard = result[0] as List<LeaderboardEntry>;
      _badges = result[1] as List<RewardBadge>;
      _pointHistory = result[2] as List<PointTransaction>;
      _status = RewardsStatus.success;
    } catch (error, stackTrace) {
      debugPrint('Unable to load Rewards data: $error');
      debugPrintStack(stackTrace: stackTrace);
      _status = RewardsStatus.failure;
      _errorMessage = 'Unable to load rewards at the moment.';
    }

    notifyListeners();
  }
}
