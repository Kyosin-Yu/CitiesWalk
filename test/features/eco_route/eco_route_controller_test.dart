import 'package:citieswalk/features/eco_route/data/repositories/sample_eco_route_repository.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_location.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route_segment.dart';
import 'package:citieswalk/features/eco_route/business_logic/providers/eco_route_controller.dart';
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
}

void main() {
  group('EcoRouteController', () {
    late EcoRouteController controller;

    setUp(() {
      controller = EcoRouteController(
        userId: 'user-123',
        repository: const SampleEcoRouteRepository(),
        locationService: const _FixedLocationService(),
      );
    });

    test('loads the device origin and suggested destinations', () async {
      await controller.initialise();

      expect(controller.origin.label, 'Test location');
      expect(controller.destinations, isNotEmpty);
    });

    test('creates a local journey for the authenticated user', () async {
      await controller.initialise();
      await controller.selectDestination(controller.destinations.first);
      controller.startJourney();

      expect(controller.journey, isNotNull);
      expect(controller.journey!.userId, 'user-123');
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
