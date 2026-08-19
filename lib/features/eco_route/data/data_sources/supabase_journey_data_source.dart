import 'package:supabase_flutter/supabase_flutter.dart';

import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/entities/eco_location.dart';
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
          'destination_latitude, destination_longitude, '
          'estimated_duration_minutes, estimated_walking_distance_meters, '
          'estimated_calories, estimated_carbon_saved_kg, ended_at',
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
            destinationLatitude: (row['destination_latitude'] as num)
                .toDouble(),
            destinationLongitude: (row['destination_longitude'] as num)
                .toDouble(),
            durationMinutes: row['estimated_duration_minutes'] as int,
            walkingDistanceMeters:
                row['estimated_walking_distance_meters'] as int,
            estimatedCalories: row['estimated_calories'] as int,
            estimatedCarbonSavedKg: (row['estimated_carbon_saved_kg'] as num)
                .toDouble(),
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
    required EcoRoute finalRoute,
  }) => _client
      .from('eco_journeys')
      .update({
        'status': 'completed',
        ..._routeEstimateFields(finalRoute),
        'ended_at': endedAt.toIso8601String(),
        'updated_at': endedAt.toIso8601String(),
      })
      .eq('id', journeyId);

  Future<void> updateRouteEstimates({
    required String journeyId,
    required EcoRoute route,
  }) => _client
      .from('eco_journeys')
      .update({
        ..._routeEstimateFields(route),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', journeyId);

  Future<void> pauseJourney({required String journeyId}) => _client
      .from('eco_journeys')
      .update({
        'status': 'paused',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', journeyId);

  Future<void> resumeJourney({required String journeyId}) => _client
      .from('eco_journeys')
      .update({
        'status': 'in_progress',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', journeyId);

  Future<void> recordTrackPoint({
    required String journeyId,
    required EcoLocation location,
    required DateTime recordedAt,
  }) => _client.from('eco_journey_track_points').insert({
    'journey_id': journeyId,
    'latitude': location.latitude,
    'longitude': location.longitude,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
  });

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

  Map<String, Object?> _routeEstimateFields(EcoRoute route) => {
    'estimated_duration_minutes': route.durationMinutes,
    'estimated_walking_distance_meters': (route.walkingDistanceKm * 1000)
        .round(),
    'estimated_calories': route.estimatedCalories,
    'estimated_carbon_saved_kg': route.estimatedCarbonSavedKg,
  };
}
