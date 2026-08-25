import 'package:citieswalk/features/rewards/business_logic/entities/badge.dart';
import 'package:citieswalk/features/rewards/business_logic/entities/leaderboard_entry.dart';
import 'package:citieswalk/features/rewards/business_logic/entities/point_transaction.dart';
import 'package:citieswalk/features/rewards/business_logic/providers/rewards_controller.dart';
import 'package:citieswalk/features/rewards/business_logic/repositories/rewards_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _PostgrestFailureRepository implements RewardsRepository {
  const _PostgrestFailureRepository();

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() {
    throw const PostgrestException(message: 'Leaderboard query failed');
  }

  @override
  Future<List<RewardBadge>> getBadges() async => const <RewardBadge>[];

  @override
  Future<List<PointTransaction>> getPointHistory() async =>
      const <PointTransaction>[];

  @override
  Future<int> getCurrentUserPoints() async => 0;
}

class _SuccessfulRepository implements RewardsRepository {
  const _SuccessfulRepository();

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async =>
      const <LeaderboardEntry>[
        LeaderboardEntry(
          rank: 1,
          name: 'Walker One',
          points: 100,
          achievement: 'Champion',
          initials: 'WO',
        ),
        LeaderboardEntry(
          rank: 2,
          name: 'Walker Two',
          points: 80,
          achievement: 'Explorer',
          initials: 'WT',
        ),
      ];

  @override
  Future<List<RewardBadge>> getBadges() async => const <RewardBadge>[];

  @override
  Future<List<PointTransaction>> getPointHistory() async =>
      const <PointTransaction>[];

  @override
  Future<int> getCurrentUserPoints() async => 100;
}

void main() {
  late DebugPrintCallback originalDebugPrint;
  late List<String> messages;

  setUp(() {
    originalDebugPrint = debugPrint;
    messages = <String>[];
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
  });

  test('logs the number of loaded leaderboard entries', () async {
    final controller = RewardsController(const _SuccessfulRepository());

    await controller.load();

    expect(controller.status, RewardsStatus.success);
    expect(messages, contains('Loaded 2 leaderboard entries.'));
  });

  test('logs Supabase exceptions while loading rewards', () async {
    final controller = RewardsController(const _PostgrestFailureRepository());

    await controller.load();

    expect(controller.status, RewardsStatus.failure);
    expect(
      messages,
      contains(
        'Supabase error while loading Rewards data: '
        'Leaderboard query failed (code: null)',
      ),
    );
  });
}
