import 'dart:math' as math;

import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/entities/eco_nearby_distance.dart';
import '../../business_logic/entities/eco_place_category.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/entities/eco_route_segment.dart';
import '../../business_logic/repositories/eco_route_repository.dart';

/// Local-only source for the Eco-Route prototype.
///
/// It does not call external routing or map services. All destinations,
/// itinerary details and map paths are safe dummy data for development.
class SampleEcoRouteRepository implements EcoRouteRepository {
  const SampleEcoRouteRepository();

  static const _klSentralStation = EcoLocation(
    latitude: 3.1348,
    longitude: 101.6869,
    label: 'KL Sentral station',
  );

  static const _klccStation = EcoLocation(
    latitude: 3.1588,
    longitude: 101.7116,
    label: 'KLCC station',
  );

  // Representative station points make the rail preview read as a rail path,
  // rather than a single diagonal line. The live Google Routes data source
  // replaces these sample points with provider-supplied transit geometry.
  static const _pasarSeniStation = EcoLocation(
    latitude: 3.1423,
    longitude: 101.6953,
    label: 'Pasar Seni station',
  );

  static const _masjidJamekStation = EcoLocation(
    latitude: 3.1492,
    longitude: 101.6967,
    label: 'Masjid Jamek station',
  );

  static const _dangWangiStation = EcoLocation(
    latitude: 3.1562,
    longitude: 101.7020,
    label: 'Dang Wangi station',
  );

  static const _kampungBaruStation = EcoLocation(
    latitude: 3.1617,
    longitude: 101.7054,
    label: 'Kampung Baru station',
  );

  static const _destinations = <EcoDestination>[
    EcoDestination(
      id: 'klcc-park',
      name: 'KLCC Park',
      category: 'Park',
      description: 'A green city park beside the Petronas Twin Towers.',
      location: EcoLocation(
        latitude: 3.1586,
        longitude: 101.7133,
        label: 'KLCC Park',
      ),
    ),
    EcoDestination(
      id: 'central-market',
      name: 'Central Market',
      category: 'Cultural landmark',
      description: 'A heritage market for Malaysian crafts and local food.',
      location: EcoLocation(
        latitude: 3.1454,
        longitude: 101.6953,
        label: 'Central Market',
      ),
    ),
    EcoDestination(
      id: 'perdana-garden',
      name: 'Perdana Botanical Garden',
      category: 'Park',
      description: 'A spacious botanical garden near Kuala Lumpur city centre.',
      location: EcoLocation(
        latitude: 3.1439,
        longitude: 101.6857,
        label: 'Perdana Botanical Garden',
      ),
    ),
    EcoDestination(
      id: 'jalan-alor',
      name: 'Jalan Alor',
      category: 'Local food',
      description: 'A lively street known for local food after sunset.',
      location: EcoLocation(
        latitude: 3.1457,
        longitude: 101.7081,
        label: 'Jalan Alor',
      ),
    ),
  ];

  @override
  Future<List<EcoDestination>> fetchNearbyDestinations({
    required EcoLocation origin,
    EcoPlaceCategory category = EcoPlaceCategory.all,
    EcoNearbyDistance nearbyDistance = EcoNearbyDistance.oneKm,
  }) async => _destinations.where((destination) {
    final matchesCategory =
        category == EcoPlaceCategory.all ||
        destination.category.toLowerCase().contains(
          category == EcoPlaceCategory.food
              ? 'food'
              : category == EcoPlaceCategory.parks
              ? 'park'
              : category == EcoPlaceCategory.markets
              ? 'market'
              : category == EcoPlaceCategory.history
              ? 'heritage'
              : category == EcoPlaceCategory.museums
              ? 'museum'
              : category == EcoPlaceCategory.campus
              ? 'campus'
              : category == EcoPlaceCategory.malls
              ? 'mall'
              : category == EcoPlaceCategory.transit
              ? 'station'
              : 'landmark',
        );
    return matchesCategory &&
        nearbyDistance.includes(_distanceBetween(origin, destination.location));
  }).toList();

  double _distanceBetween(EcoLocation first, EcoLocation second) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _degreesToRadians(second.latitude - first.latitude);
    final longitudeDelta = _degreesToRadians(
      second.longitude - first.longitude,
    );
    final a =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(_degreesToRadians(first.latitude)) *
            math.cos(_degreesToRadians(second.latitude)) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  @override
  Future<List<EcoDestination>> searchDestinations({
    required String query,
    required EcoLocation origin,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _destinations;

    return _destinations
        .where(
          (destination) =>
              destination.name.toLowerCase().contains(normalizedQuery) ||
              destination.category.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  @override
  Future<EcoRoute> buildRoute({
    required EcoLocation origin,
    required EcoDestination destination,
  }) async {
    return EcoRoute(
      origin: origin,
      destination: destination,
      estimatedCalories: 62,
      estimatedCarbonSavedKg: 0.9,
      segments: [
        EcoRouteSegment(
          type: EcoRouteSegmentType.walk,
          title: 'Walk to KL Sentral',
          detail: 'Follow the pedestrian path to the station entrance.',
          distanceKm: 0.4,
          durationMinutes: 6,
          steps: const [
            EcoRouteStep(
              instruction: 'Walk towards KL Sentral station.',
              distanceKm: 0.4,
              durationMinutes: 6,
            ),
          ],
          mapPath: [origin, _klSentralStation],
        ),
        EcoRouteSegment(
          type: EcoRouteSegmentType.transit,
          title: 'Kelana Jaya LRT line',
          detail: 'Travel towards the city centre.',
          distanceKm: 3.6,
          durationMinutes: 12,
          platform: 'Platform 2',
          steps: const [
            EcoRouteStep(
              instruction: 'Board the train at Platform 2.',
              distanceKm: 0,
              durationMinutes: 2,
            ),
            EcoRouteStep(
              instruction: 'Exit at KLCC station.',
              distanceKm: 3.6,
              durationMinutes: 10,
            ),
          ],
          mapPath: const [
            _klSentralStation,
            _pasarSeniStation,
            _masjidJamekStation,
            _dangWangiStation,
            _kampungBaruStation,
            _klccStation,
          ],
        ),
        EcoRouteSegment(
          type: EcoRouteSegmentType.walk,
          title: 'Walk to destination',
          detail: 'Use the marked pedestrian route from the station.',
          distanceKm: 0.5,
          durationMinutes: 6,
          steps: const [
            EcoRouteStep(
              instruction: 'Walk from the station to your destination.',
              distanceKm: 0.5,
              durationMinutes: 6,
            ),
          ],
          mapPath: [_klccStation, destination.location],
        ),
      ],
    );
  }
}
