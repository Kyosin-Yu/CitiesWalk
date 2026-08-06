import '../../business/models/eco_destination.dart';
import '../../business/models/eco_location.dart';
import '../../business/models/eco_route.dart';
import '../../business/models/eco_route_segment.dart';
import 'eco_route_repository.dart';

/// Replace with Nominatim and OpenTripPlanner-backed implementations once the
/// team confirms endpoint, GTFS feed, and usage configuration.
class SampleEcoRouteRepository implements EcoRouteRepository {
  const SampleEcoRouteRepository();

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
  Future<List<EcoDestination>> fetchNearbyDestinations() async => _destinations;

  @override
  Future<List<EcoDestination>> searchDestinations(String query) async {
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
      segments: const [
        EcoRouteSegment(
          type: EcoRouteSegmentType.walk,
          title: 'Walk to KL Sentral',
          detail: 'Follow the pedestrian path to the station entrance.',
          distanceKm: 0.4,
          durationMinutes: 6,
          steps: [
            EcoRouteStep(
              instruction: 'Walk towards KL Sentral station.',
              distanceKm: 0.4,
              durationMinutes: 6,
            ),
          ],
        ),
        EcoRouteSegment(
          type: EcoRouteSegmentType.transit,
          title: 'Kelana Jaya LRT line',
          detail: 'Travel towards the city centre.',
          distanceKm: 3.6,
          durationMinutes: 12,
          platform: 'Platform 2',
          steps: [
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
        ),
        EcoRouteSegment(
          type: EcoRouteSegmentType.walk,
          title: 'Walk to destination',
          detail: 'Use the marked pedestrian route from the station.',
          distanceKm: 0.5,
          durationMinutes: 6,
          steps: [
            EcoRouteStep(
              instruction: 'Walk from the station to your destination.',
              distanceKm: 0.5,
              durationMinutes: 6,
            ),
          ],
        ),
      ],
    );
  }
}
