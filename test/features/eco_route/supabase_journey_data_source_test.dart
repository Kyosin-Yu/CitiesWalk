import 'dart:convert';

import 'package:citieswalk/features/eco_route/business_logic/entities/eco_destination.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_location.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route_segment.dart';
import 'package:citieswalk/features/eco_route/data/data_sources/supabase_journey_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('completed trip uses the atomic database completion pipeline', () async {
    const journeyId = '624265fe-18ab-41ce-abed-1d7aaa8db8ed';
    final requestPaths = <String>[];

    final httpClient = MockClient((request) async {
      requestPaths.add(request.url.path);

      if (request.url.path == '/rest/v1/eco_journeys') {
        expect(request.method, 'PATCH');
        expect(request.url.queryParameters['id'], 'eq.$journeyId');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'completed');
        expect(body['actual_walking_distance_meters'], 5);
        return http.Response(
          jsonEncode(<String, dynamic>{'id': journeyId}),
          200,
          headers: <String, String>{'content-type': 'application/json'},
          request: request,
        );
      }

      fail('Unexpected Supabase request: ${request.method} ${request.url}');
    });
    final client = SupabaseClient(
      'https://test.supabase.co',
      'test-publishable-key',
      accessToken: () async => 'test-user-jwt',
      httpClient: httpClient,
    );
    addTearDown(client.dispose);
    final dataSource = SupabaseJourneyDataSource(client);

    await dataSource.completeJourney(
      journeyId: journeyId,
      endedAt: DateTime.utc(2026, 8, 26, 9, 6),
      finalRoute: _route,
      actualDurationMinutes: 6,
      actualWalkingDistanceKm: 0.005,
      actualTransitDistanceKm: 0,
      actualStepCount: 646,
      actualCaloriesBurned: 35,
      actualCarbonSavedKg: 0,
    );

    expect(requestPaths, <String>['/rest/v1/eco_journeys']);
  });
}

const _route = EcoRoute(
  origin: EcoLocation(latitude: 3.2, longitude: 101.7, label: 'Start'),
  destination: EcoDestination(
    id: 'destination-1',
    name: 'DK ABA',
    category: 'Place to visit',
    description: 'Test destination',
    location: EcoLocation(latitude: 3.21, longitude: 101.71, label: 'DK ABA'),
  ),
  segments: <EcoRouteSegment>[
    EcoRouteSegment(
      type: EcoRouteSegmentType.walk,
      title: 'Walk',
      detail: 'Walk to the destination',
      distanceKm: 0.5,
      durationMinutes: 6,
      steps: <EcoRouteStep>[
        EcoRouteStep(
          instruction: 'Continue walking',
          distanceKm: 0.5,
          durationMinutes: 6,
        ),
      ],
    ),
  ],
  estimatedCalories: 35,
  estimatedCarbonSavedKg: 0,
  isLiveRoute: true,
);
