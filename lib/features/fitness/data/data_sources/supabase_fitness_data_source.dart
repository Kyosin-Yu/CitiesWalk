import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/fitness_journey_model.dart';

class SupabaseFitnessDataSource {
  const SupabaseFitnessDataSource(this._client);

  final SupabaseClient _client;

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
}
