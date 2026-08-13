import 'package:citieswalk/features/eco_route/data/repositories/sample_eco_route_repository.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_location.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_journey.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route_segment.dart';
import 'package:citieswalk/features/eco_route/business_logic/providers/eco_route_controller.dart';
import 'package:citieswalk/features/eco_route/business_logic/repositories/journey_repository.dart';
import 'package:citieswalk/features/eco_route/business_logic/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedLocationService implements LocationService {
  const _FixedLocationService();

  @override
  Future<EcoLocation> getCurrentLocation() async => const EcoLocation(
    latitude: 3.139,
    longitude: 101.6869,
    label: 'Test location',
  );

  @override
  Stream<EcoLocation> watchCurrentLocation() => const Stream.empty();
}

class _MemoryJourneyRepository implements JourneyRepository {
  String? createdJourneyId;
  DateTime? completedAt;

  @override
  Future<void> completeJourney({
    required String journeyId,
    required DateTime endedAt,
  }) async {
    createdJourneyId = journeyId;
    completedAt = endedAt;
  }

  @override
  Future<String> createStartedJourney({
    required String userId,
    required EcoRoute route,
    required DateTime startedAt,
  }) async => createdJourneyId = 'journey-1';
}

void main() {
  group('EcoRouteController', () {
    late EcoRouteController controller;
    late _MemoryJourneyRepository journeyRepository;

    setUp(() {
      journeyRepository = _MemoryJourneyRepository();
      controller = EcoRouteController(
        userId: 'user-123',
        repository: const SampleEcoRouteRepository(),
        journeyRepository: journeyRepository,
        locationService: const _FixedLocationService(),
      );
    });

    test('loads the device origin and suggested destinations', () async {
      await controller.initialise();

      expect(controller.origin.label, 'Test location');
      expect(controller.destinations, isNotEmpty);
    });

    test('saves and completes a journey for the authenticated user', () async {
      await controller.initialise();
      await controller.selectDestination(controller.destinations.first);
      await controller.startJourney();

      expect(controller.journey, isNotNull);
      expect(controller.journey!.userId, 'user-123');
      expect(controller.journey!.id, 'journey-1');

      await controller.endJourney();
      expect(controller.journey!.status, EcoJourneyStatus.completed);
      expect(journeyRepository.completedAt, isNotNull);
    });

    test('creates route geometry for the map preview', () async {
      await controller.initialise();
      await controller.selectDestination(controller.destinations.first);

      final route = controller.route;
      expect(route, isNotNull);
      expect(
        route!.segments,
        everyElement(
          isA<EcoRouteSegment>().having(
            (segment) => segment.mapPath.length,
            'map path point count',
            greaterThanOrEqualTo(2),
          ),
        ),
      );
    });
  });
}
