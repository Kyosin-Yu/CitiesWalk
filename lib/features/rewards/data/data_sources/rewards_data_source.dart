import '../models/badge_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/point_transaction_model.dart';

/// Data-layer contract for obtaining Rewards records.
///
/// Implementations may use local sample data or Supabase, while repositories
/// and presentation code remain independent from the transport mechanism.
abstract interface class RewardsDataSource {
  Future<List<LeaderboardEntryModel>> fetchLeaderboard();

  Future<List<BadgeModel>> fetchBadges();

  Future<List<PointTransactionModel>> fetchPointHistory();

  Future<int> fetchCurrentUserPoints();
}
