import 'package:supabase_flutter/supabase_flutter.dart';

import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/entities/eco_route_segment.dart';

/// Calls the protected `eco-route` Supabase Edge Function.
///
/// Google Places and Routes keys are stored in Edge Function secrets, not in
/// the Android app, its manifest, or the Git repository.
class GoogleEcoRouteDataSource {
  GoogleEcoRouteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<EcoDestination>> fetchNearby(EcoLocation origin) async {
    final data = await _invoke({
      'action': 'nearby',
      'origin': _locationPayload(origin),
    });
    return _destinationsFrom(data['places']);
  }

  Future<List<EcoDestination>> search({
    required String query,
    required EcoLocation origin,
  }) async {
    final data = await _invoke({
      'action': 'search',
      'query': query,
      'origin': _locationPayload(origin),
    });
    return _destinationsFrom(data['places']);
  }

  Future<EcoRoute> buildRoute({
    required EcoLocation origin,
    required EcoDestination destination,
  }) async {
    final data = await _invoke({
      'action': 'route',
      'origin': _locationPayload(origin),
      'destination': {
        ..._locationPayload(destination.location),
        'id': destination.id,
        'name': destination.name,
        'category': destination.category,
        'description': destination.description,
      },
    });

    final rawSegments = List<Object?>.from(data['segments'] as List);
    return EcoRoute(
      origin: origin,
      destination: destination,
      estimatedCalories: (data['estimatedCalories'] as num).round(),
      estimatedCarbonSavedKg: (data['estimatedCarbonSavedKg'] as num)
          .toDouble(),
      isLiveRoute: true,
      segments: rawSegments
          .map(
            (segment) =>
                _segmentFrom(Map<String, dynamic>.from(segment! as Map)),
          )
          .toList(growable: false),
    );
  }

  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    final response = await _client.functions.invoke('eco-route', body: body);
    if (response.data is! Map) {
      throw const FormatException(
        'The live Eco-Route service returned no data.',
      );
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  List<EcoDestination> _destinationsFrom(Object? rawPlaces) {
    final places = List<Object?>.from(rawPlaces as List);
    return places
        .map((place) {
          final data = Map<String, dynamic>.from(place! as Map);
          return EcoDestination(
            id: data['id'] as String,
            name: data['name'] as String,
            category: data['category'] as String,
            description: data['description'] as String,
            location: EcoLocation(
              latitude: (data['latitude'] as num).toDouble(),
              longitude: (data['longitude'] as num).toDouble(),
              label: data['name'] as String,
            ),
          );
        })
        .toList(growable: false);
  }

  EcoRouteSegment _segmentFrom(Map<String, dynamic> segment) {
    final distanceMeters = (segment['distanceMeters'] as num).toDouble();
    final durationMinutes = (segment['durationMinutes'] as num).round();
    return EcoRouteSegment(
      type: segment['type'] == 'transit'
          ? EcoRouteSegmentType.transit
          : EcoRouteSegmentType.walk,
      title: segment['title'] as String,
      detail: segment['detail'] as String,
      distanceKm: distanceMeters / 1000,
      durationMinutes: durationMinutes,
      platform: segment['boardingStation'] as String?,
      steps: [
        EcoRouteStep(
          instruction: segment['instruction'] as String,
          distanceKm: distanceMeters / 1000,
          durationMinutes: durationMinutes,
        ),
      ],
      mapPath: List<Object?>.from(
        segment['encodedPolylines'] as List? ?? const [],
      ).expand((polyline) => _decodePolyline(polyline as String)).toList(),
    );
  }

  List<EcoLocation> _decodePolyline(String encoded) {
    final points = <EcoLocation>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      final latitudeValue = _decodeValue(encoded, index);
      index = latitudeValue.$2;
      latitude += latitudeValue.$1;
      final longitudeValue = _decodeValue(encoded, index);
      index = longitudeValue.$2;
      longitude += longitudeValue.$1;
      points.add(
        EcoLocation(
          latitude: latitude / 1e5,
          longitude: longitude / 1e5,
          label: 'Route path',
        ),
      );
    }
    return points;
  }

  (int, int) _decodeValue(String encoded, int index) {
    var result = 0;
    var shift = 0;
    var value = 0;
    do {
      value = encoded.codeUnitAt(index++) - 63;
      result |= (value & 0x1f) << shift;
      shift += 5;
    } while (value >= 0x20 && index < encoded.length);
    return ((result & 1) == 1 ? ~(result >> 1) : result >> 1, index);
  }

  Map<String, double> _locationPayload(EcoLocation location) => {
    'latitude': location.latitude,
    'longitude': location.longitude,
  };
}
