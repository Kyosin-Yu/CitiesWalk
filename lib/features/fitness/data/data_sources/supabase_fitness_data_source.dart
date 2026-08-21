import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fitness_journey_model.dart';
import '../models/fitness_goal_model.dart';
import '../models/fitness_recent_badge_model.dart';
import '../../business_logic/entities/fitness_goal.dart';

class SupabaseFitnessDataSource {
  const SupabaseFitnessDataSource(this._client);

  final SupabaseClient _client;

  static const _goalColumns =
      'id, user_id, metric, period, target_value, status, completed_at, '
      'cancelled_at, completed_value, reward_points, reward_policy_version, '
      'created_at, updated_at';

  Future<List<FitnessJourneyModel>> fetchCompletedJourneys({
    required String userId,
  }) async {
    final rows = await _client
        .from('eco_journeys')
        .select(
          'id, origin_name, destination_name, '
          'estimated_walking_distance_meters, estimated_calories, '
          'estimated_carbon_saved_kg, actual_walking_distance_meters, '
          'actual_step_count, actual_calories_burned, '
          'actual_carbon_saved_kg, started_at, ended_at, status',
        )
        .eq('user_id', userId)
        .inFilter('status', const ['completed', 'ended_early'])
        .not('ended_at', 'is', null)
        .order('ended_at', ascending: false);

    return (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(FitnessJourneyModel.fromSupabaseRow)
        .toList(growable: false);
  }

  Future<List<FitnessGoalModel>> fetchGoals({required String userId}) async {
    final rows = await _client
        .from('fitness_goals')
        .select(_goalColumns)
        .eq('user_id', userId)
        .order('created_at');

    return (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(FitnessGoalModel.fromSupabaseRow)
        .toList(growable: false);
  }

  Future<List<FitnessRecentBadgeModel>> fetchRecentBadges({
    required String userId,
  }) async {
    final progressRows = await _client
        .from('user_badges')
        .select('badge_id, unlocked_at')
        .eq('user_id', userId)
        .not('unlocked_at', 'is', null)
        .order('unlocked_at', ascending: false)
        .limit(4);
    final progress = (progressRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    if (progress.isEmpty) return const [];

    final badgeIds = progress
        .map((row) => row['badge_id'] as String)
        .toList(growable: false);
    final badgeRows = await _client
        .from('badges')
        .select('id, title, description, icon_key')
        .inFilter('id', badgeIds)
        .eq('is_active', true);
    final badgesById = <String, Map<String, dynamic>>{
      for (final row
          in (badgeRows as List<dynamic>).whereType<Map<String, dynamic>>())
        row['id'] as String: row,
    };

    return [
      for (final row in progress)
        if (badgesById[row['badge_id']] case final badge?)
          FitnessRecentBadgeModel.fromRows(badge: badge, progress: row),
    ];
  }

  Future<FitnessGoalModel> createGoal({
    required String userId,
    required FitnessGoalInput input,
  }) async {
    final row = await _client
        .from('fitness_goals')
        .insert({
          'user_id': userId,
          'metric': input.metric.storageValue,
          'period': input.period.storageValue,
          'target_value': input.targetValue,
        })
        .select(_goalColumns)
        .single();
    return FitnessGoalModel.fromSupabaseRow(row);
  }

  Future<FitnessGoalModel> cancelGoal({
    required String userId,
    required String goalId,
  }) async {
    final response = await _client.rpc(
      'cancel_fitness_goal',
      params: {'target_goal_id': goalId},
    );
    final row = Map<String, dynamic>.from(response as Map);
    if (row['user_id'] != userId) {
      throw const FormatException('Cancelled goal ownership is invalid.');
    }
    return FitnessGoalModel.fromSupabaseRow(row);
  }
}
