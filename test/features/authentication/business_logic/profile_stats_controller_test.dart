import 'package:citieswalk/features/authentication/business_logic/entities/profile_stats.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/profile_stats_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/profile_stats_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the authenticated user profile statistics', () async {
    final controller = ProfileStatsController(
      _ProfileStatsRepository(
        const ProfileStats(
          journeyCount: 4,
          reviewCount: 2,
          badgeCount: 3,
          points: 125,
        ),
      ),
    );

    await controller.load(userId: 'user-1');

    expect(controller.stats?.journeyCount, 4);
    expect(controller.stats?.reviewCount, 2);
    expect(controller.stats?.badgeCount, 3);
    expect(controller.stats?.points, 125);
    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNull);
  });

  test('exposes a retryable error when loading fails', () async {
    final controller = ProfileStatsController(_ProfileStatsRepository(null));

    await controller.load(userId: 'user-1');

    expect(controller.stats, isNull);
    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNotNull);
  });
}

class _ProfileStatsRepository implements ProfileStatsRepository {
  const _ProfileStatsRepository(this.result);

  final ProfileStats? result;

  @override
  Future<ProfileStats> fetchStats({required String userId}) async {
    if (result == null) throw StateError('offline');
    return result!;
  }
}
