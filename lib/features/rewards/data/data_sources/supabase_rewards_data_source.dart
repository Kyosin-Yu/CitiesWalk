import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/eco_points_service.dart';
import '../models/badge_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/point_transaction_model.dart';
import 'rewards_data_source.dart';

/// Reads the current user's rewards data from the shared Supabase project.
///
/// Point creation remains server-side in the completed-journey database
/// trigger. This data source is read-only and relies on the database RLS
/// policies.
class SupabaseRewardsDataSource implements RewardsDataSource {
  const SupabaseRewardsDataSource(this._client, this._ecoPointsService);

  final SupabaseClient _client;
  final EcoPointsService _ecoPointsService;

  static const _badgeColumns =
      'id, title, description, icon_key, target_value, display_order';
  static const _transactionColumns =
      'id, journey_id, source_type, points, walking_distance_km, carbon_saved_kg, '
      'calories_burned, journey_completed_at';

  @override
  Future<List<LeaderboardEntryModel>> fetchLeaderboard() async {
    final userId = _requireUserId();
    final result = await _client.rpc('get_current_weekly_leaderboard');
    final entries = _rows(result)
        .map(
          (row) => LeaderboardEntryModel.fromLeaderboardRow(
            row,
            currentUserId: userId,
          ),
        )
        .toList(growable: true);

    if (!entries.any((entry) => entry.isCurrentUser)) {
      final profile = await _client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();
      final name = _nonEmptyString(profile?['full_name']) ?? 'You';
      entries.add(
        LeaderboardEntryModel(
          rank: 0,
          name: name,
          points: await _ecoPointsService.fetchCurrentWeekPoints(
            userId: userId,
          ),
          achievement: 'Complete a journey to join',
          initials: _initials(name),
          isCurrentUser: true,
        ),
      );
    }

    return entries;
  }

  @override
  Future<List<BadgeModel>> fetchBadges() async {
    final userId = _requireUserId();
    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      _client
          .from('badges')
          .select(_badgeColumns)
          .eq('is_active', true)
          .order('display_order'),
      _client
          .from('user_badges')
          .select('badge_id, progress, unlocked_at, unlocked_journey_id')
          .eq('user_id', userId),
    ]);
    final badges = _rows(results[0]);
    final userBadges = _rows(results[1]);
    final progressByBadge = <String, Map<String, dynamic>>{
      for (final row in userBadges) row['badge_id'] as String: row,
    };
    final unlockedJourneyIds = userBadges
        .map((row) => row['unlocked_journey_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    final locationsByJourney = await _fetchLocations(unlockedJourneyIds);

    return badges
        .map((badge) {
          final progress = progressByBadge[badge['id'] as String];
          final unlockedAt = progress?['unlocked_at'] as String?;
          final journeyId = progress?['unlocked_journey_id'] as String?;
          return BadgeModel(
            id: badge['id'] as String,
            title: badge['title'] as String,
            description: badge['description'] as String,
            unlocked: unlockedAt != null,
            icon: _badgeIcon(badge['icon_key']),
            progress: _number(progress?['progress']).toInt(),
            goal: _number(badge['target_value']).toInt(),
            earnedOn: unlockedAt == null
                ? null
                : DateTime.parse(unlockedAt).toLocal(),
            completionLocation: journeyId == null
                ? null
                : locationsByJourney[journeyId],
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<PointTransactionModel>> fetchPointHistory() async {
    final rows = _rows(
      await _client
          .from('reward_point_transactions')
          .select(_transactionColumns)
          .eq('user_id', _requireUserId())
          .order('journey_completed_at', ascending: false),
    );
    final journeyIds = rows
        .map((row) => row['journey_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    final journeysById = await _fetchJourneys(journeyIds);

    return rows
        .map((row) {
          final journeyId = row['journey_id'] as String?;
          return PointTransactionModel.fromRewardTransactionRow(
            row,
            journey: journeyId == null ? null : journeysById[journeyId],
          );
        })
        .toList(growable: false);
  }

  @override
  Future<int> fetchCurrentUserPoints() async {
    return _ecoPointsService.fetchLifetimePoints(userId: _requireUserId());
  }

  Future<Map<String, String>> _fetchLocations(List<String> journeyIds) async {
    if (journeyIds.isEmpty) return const <String, String>{};
    final rows = _rows(
      await _client
          .from('eco_journeys')
          .select('id, destination_name')
          .inFilter('id', journeyIds),
    );
    return <String, String>{
      for (final row in rows)
        row['id'] as String: ?_nonEmptyString(row['destination_name']),
    };
  }

  Future<Map<String, Map<String, dynamic>>> _fetchJourneys(
    List<String> journeyIds,
  ) async {
    if (journeyIds.isEmpty) return const <String, Map<String, dynamic>>{};
    final rows = _rows(
      await _client
          .from('eco_journeys')
          .select(
            'id, origin_name, destination_name, actual_transit_distance_meters',
          )
          .inFilter('id', journeyIds),
    );
    return <String, Map<String, dynamic>>{
      for (final row in rows) row['id'] as String: row,
    };
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in to view rewards.');
    }
    return userId;
  }

  List<Map<String, dynamic>> _rows(dynamic result) => (result as List<dynamic>)
      .map((row) => Map<String, dynamic>.from(row as Map<dynamic, dynamic>))
      .toList(growable: false);

  num _number(dynamic value) => switch (value) {
    num number => number,
    String text => num.tryParse(text) ?? 0,
    _ => 0,
  };

  String? _nonEmptyString(dynamic value) {
    final text = value as String?;
    return text == null || text.trim().isEmpty ? null : text.trim();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _badgeIcon(dynamic iconKey) {
    const compatibleIcons = <String>{
      'city',
      'recycle',
      'sunrise',
      'globe',
      'accountBalance',
      'owl',
      'leaf',
      'directionsWalk',
    };
    final icon = iconKey as String?;
    return compatibleIcons.contains(icon) ? icon! : 'leaf';
  }
}
