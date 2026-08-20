import '../../business_logic/entities/badge.dart';
import '../../business_logic/entities/leaderboard_entry.dart';
import '../../business_logic/entities/point_transaction.dart';
import '../../business_logic/repositories/rewards_repository.dart';
import '../data_sources/rewards_data_source.dart';

/// Maps Rewards data-source records into business entities.
class RewardsRepositoryImpl implements RewardsRepository {
  const RewardsRepositoryImpl(this._dataSource);

  final RewardsDataSource _dataSource;

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async =>
      (await _dataSource.fetchLeaderboard())
          .map((model) => model.toEntity())
          .toList(growable: false);

  @override
  Future<List<RewardBadge>> getBadges() async =>
      (await _dataSource.fetchBadges())
          .map((model) => model.toEntity())
          .toList(growable: false);

  @override
  Future<List<PointTransaction>> getPointHistory() async =>
      (await _dataSource.fetchPointHistory())
          .map((model) => model.toEntity())
          .toList(growable: false);

  @override
  Future<int> getCurrentUserPoints() => _dataSource.fetchCurrentUserPoints();
}
