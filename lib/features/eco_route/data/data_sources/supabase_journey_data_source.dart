import 'package:supabase_flutter/supabase_flutter.dart';

import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/entities/eco_route_segment.dart';
import '../../business_logic/entities/eco_journey_history_item.dart';

/// Supabase access for the user-owned Eco-Route journey records.
class SupabaseJourneyDataSource {
  SupabaseJourneyDataSource(this._client);

  final SupabaseClient _client;

  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  }) async {
    final rows = await _client
        .from('eco_journeys')
        .select(
          'id, destination_name, destination_category, '
          'estimated_duration_minutes, estimated_walking_distance_meters, ended_at',
        )
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('ended_at', ascending: false)
        .limit(5);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((row) => row['ended_at'] != null)
        .map(
          (row) => EcoJourneyHistoryItem(
            id: row['id'] as String,
            destinationName: row['destination_name'] as String,
            destinationCategory: row['destination_category'] as String?,
            durationMinutes: row['estimated_duration_minutes'] as int,
            walkingDistanceMeters:
                row['estimated_walking_distance_meters'] as int,
            completedAt: DateTime.parse(row['ended_at'] as String).toLocal(),
          ),
        )
        .toList();
  }

  Future<String> createStartedJourney({
    required String userId,
    required EcoRoute route,
    required DateTime startedAt,
  }) async {
    final journey = await _client
        .from('eco_journeys')
        .insert({
          'user_id': userId,
          'status': 'in_progress',
          'origin_name': route.origin.label,
          'origin_latitude': route.origin.latitude,
          'origin_longitude': route.origin.longitude,
          'destination_name': route.destination.name,
          'destination_category': route.destination.category,
          'destination_latitude': route.destination.location.latitude,
          'destination_longitude': route.destination.location.longitude,
          'estimated_duration_minutes': route.durationMinutes,
          'estimated_walking_distance_meters': (route.walkingDistanceKm * 1000)
              .round(),
          'estimated_calories': route.estimatedCalories,
          'estimated_carbon_saved_kg': route.estimatedCarbonSavedKg,
          'started_at': startedAt.toIso8601String(),
        })
        .select('id')
        .single();

    final journeyId = journey['id'] as String;
    try {
      if (route.segments.isNotEmpty) {
        await _client.from('eco_route_steps').insert([
          for (var index = 0; index < route.segments.length; index++)
            _stepRow(
              journeyId: journeyId,
              order: index + 1,
              segment: route.segments[index],
            ),
        ]);
      }
      return journeyId;
    } catch (_) {
      // Avoid leaving a partial journey record if saving its steps fails.
      await _client.from('eco_journeys').delete().eq('id', journeyId);
      rethrow;
    }
  }

  Future<void> completeJourney({
    required String journeyId,
    required DateTime endedAt,
  }) => _client
      .from('eco_journeys')
      .update({
        'status': 'completed',
        'ended_at': endedAt.toIso8601String(),
        'updated_at': endedAt.toIso8601String(),
      })
      .eq('id', journeyId);

  Map<String, Object?> _stepRow({
    required String journeyId,
    required int order,
    required EcoRouteSegment segment,
  }) => {
    'journey_id': journeyId,
    'step_order': order,
    'transport_mode': segment.type == EcoRouteSegmentType.transit
        ? 'transit'
        : 'walk',
    'line_name': segment.type == EcoRouteSegmentType.transit
        ? segment.title
        : null,
    'instruction': segment.detail,
    'distance_meters': (segment.distanceKm * 1000).round(),
    'duration_minutes': segment.durationMinutes,
  };
}
