import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fitness_journey_model.dart';
import '../models/fitness_goal_model.dart';
import '../../business_logic/entities/fitness_goal.dart';

class SupabaseFitnessDataSource {
  const SupabaseFitnessDataSource(this._client);

  final SupabaseClient _client;

  static const _goalColumns =
      'id, user_id, metric, period, target_value, created_at, updated_at';

  Future<List<FitnessJourneyModel>> fetchCompletedJourneys({
    required String userId,
  }) async {
    final rows = await _client
        .from('eco_journeys')
        .select(
          'id, estimated_walking_distance_meters, estimated_calories, '
          'estimated_carbon_saved_kg, ended_at',
        )
        .eq('user_id', userId)
        .eq('status', 'completed')
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

  Future<FitnessGoalModel> updateGoal({
    required String userId,
    required String goalId,
    required FitnessGoalInput input,
  }) async {
    final row = await _client
        .from('fitness_goals')
        .update({
          'metric': input.metric.storageValue,
          'period': input.period.storageValue,
          'target_value': input.targetValue,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', goalId)
        .eq('user_id', userId)
        .select(_goalColumns)
        .single();
    return FitnessGoalModel.fromSupabaseRow(row);
  }

  Future<void> deleteGoal({
    required String userId,
    required String goalId,
  }) async {
    await _client
        .from('fitness_goals')
        .delete()
        .eq('id', goalId)
        .eq('user_id', userId);
  }
}
