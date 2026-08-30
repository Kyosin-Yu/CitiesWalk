import '../entities/profile_stats.dart';

abstract interface class ProfileStatsRepository {
  Future<ProfileStats> fetchStats({required String userId});
}
