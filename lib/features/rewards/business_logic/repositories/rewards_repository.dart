import '../entities/badge.dart';
import '../entities/leaderboard_entry.dart';
import '../entities/point_transaction.dart';

/// Contract between the Rewards business logic and its data sources.
abstract class RewardsRepository {
  Future<List<LeaderboardEntry>> getLeaderboard();

  Future<List<RewardBadge>> getBadges();

  Future<List<PointTransaction>> getPointHistory();

  Future<int> getCurrentUserPoints();
}
