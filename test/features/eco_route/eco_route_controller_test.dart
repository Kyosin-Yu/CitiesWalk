import 'dart:async';

import 'package:citieswalk/features/eco_route/data/repositories/sample_eco_route_repository.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_location.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_nearby_distance.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_place_category.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_destination.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_journey.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_route_segment.dart';
import 'package:citieswalk/features/eco_route/business_logic/providers/eco_route_controller.dart';
import 'package:citieswalk/features/eco_route/business_logic/repositories/journey_repository.dart';
import 'package:citieswalk/features/eco_route/business_logic/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedLocationService implements LocationService {
  _FixedLocationService();

  final StreamController<EcoLocation> _locations =
      StreamController<EcoLocation>.broadcast();
  EcoLocation currentLocation = const EcoLocation(
    latitude: 3.139,
    longitude: 101.6869,
    label: 'Test location',
  );

  @override
  Future<EcoLocation> getCurrentLocation() async => currentLocation;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Stream<EcoLocation> watchCurrentLocation() => _locations.stream;

  void emit(EcoLocation location) => _locations.add(location);

  Future<void> dispose() => _locations.close();
}

class _MemoryJourneyRepository implements JourneyRepository {
  String? createdJourneyId;
  DateTime? completedAt;
  final List<EcoLocation> trackPoints = [];
  bool isPaused = false;
  bool wasCancelled = false;
  bool wasEndedEarly = false;
  int? actualStepCount;
  int startedJourneys = 0;

  @override
  Future<void> completeJourney({
    required String journeyId,
    required DateTime endedAt,
    required EcoRoute finalRoute,
    required int actualDurationMinutes,
    required double actualWalkingDistanceKm,
    required double actualTransitDistanceKm,
    required int actualStepCount,
    required int actualCaloriesBurned,
    required double actualCarbonSavedKg,
  }) async {
    createdJourneyId = journeyId;
    completedAt = endedAt;
    this.actualStepCount = actualStepCount;
  }

  @override
  Future<void> endJourneyEarly({
    required String journeyId,
    required DateTime endedAt,
    required EcoRoute finalRoute,
    required int actualDurationMinutes,
    required double actualWalkingDistanceKm,
    required double actualTransitDistanceKm,
    required int actualStepCount,
    required int actualCaloriesBurned,
    required double actualCarbonSavedKg,
  }) async {
    createdJourneyId = journeyId;
    completedAt = endedAt;
    this.actualStepCount = actualStepCount;
    wasEndedEarly = true;
  }

  @override
  Future<void> cancelJourney({required String journeyId}) async {
    wasCancelled = true;
  }

  @override
  Future<void> updateRouteEstimates({
    required String journeyId,
    required EcoRoute route,
  }) async {}

  @override
  Future<String> createStartedJourney({
    required String userId,
    required EcoRoute route,
    required DateTime startedAt,
  }) async {
    startedJourneys++;
    return createdJourneyId = 'journey-$startedJourneys';
  }

  @override
  Future<void> pauseJourney({required String journeyId}) async {
    isPaused = true;
  }

  @override
  Future<void> resumeJourney({required String journeyId}) async {
    isPaused = false;
  }

  @override
  Future<void> recordTrackPoint({
    required String journeyId,
    required EcoLocation location,
    required DateTime recordedAt,
  }) async {
    trackPoints.add(location);
  }
}

void main() {
  group('EcoRouteController', () {
    late EcoRouteController controller;
    late _MemoryJourneyRepository journeyRepository;
    late _FixedLocationService locationService;

    setUp(() {
      journeyRepository = _MemoryJourneyRepository();
      locationService = _FixedLocationService();
      controller = EcoRouteController(
        userId: 'user-123',
        repository: const SampleEcoRouteRepository(),
        journeyRepository: journeyRepository,
        locationService: locationService,
      );
    });

    tearDown(() async {
      controller.dispose();
      await locationService.dispose();
    });

    test('loads the device origin and suggested destinations', () async {
      await controller.initialise();

      expect(controller.origin.label, 'Test location');
      expect(controller.selectedNearbyDistance, EcoNearbyDistance.oneKm);
      expect(controller.destinations, isNotEmpty);
    });

    test('filters nearby recommendations by place category', () async {
      await controller.initialise();
      await controller.applyNearbyFilters(
        category: EcoPlaceCategory.food,
        nearbyDistance: EcoNearbyDistance.fiveKm,
      );

      expect(controller.selectedCategory, EcoPlaceCategory.food);
      expect(controller.selectedNearbyDistance, EcoNearbyDistance.fiveKm);
      expect(controller.destinations, isNotEmpty);
      expect(
        controller.destinations,
        everyElement(
          predicate<EcoDestination>(
            (destination) =>
                destination.category.toLowerCase().contains('food'),
          ),
        ),
      );
    });

    test('filters nearby recommendations by selected distance', () async {
      await controller.initialise();
      await controller.selectNearbyDistance(EcoNearbyDistance.oneKm);

      expect(controller.selectedNearbyDistance, EcoNearbyDistance.oneKm);
      expect(controller.destinations.map((destination) => destination.name), [
        'Perdana Botanical Garden',
      ]);
    });

    test(
      'does not complete a journey before GPS reaches the destination',
      () async {
        await controller.initialise();
        await controller.selectDestination(controller.destinations.first);
        await controller.startJourney();

        expect(controller.journey, isNotNull);
        expect(controller.journey!.userId, 'user-123');
        expect(controller.journey!.id, 'journey-1');

        final didComplete = await controller.finishJourneyIfArrived();

        expect(didComplete, isFalse);
        expect(controller.journey!.status, EcoJourneyStatus.inProgress);
        expect(journeyRepository.completedAt, isNull);
      },
    );

    test('does not create a second record while a journey is active', () async {
      await controller.initialise();
      await controller.selectDestination(controller.destinations.first);
      await controller.startJourney();
      await controller.startJourney();

      expect(journeyRepository.startedJourneys, 1);
      expect(controller.journey!.status, EcoJourneyStatus.inProgress);
    });

    test(
      'completes only when the GPS location reaches the destination',
      () async {
        await controller.initialise();
        await controller.selectDestination(controller.destinations.first);
        await controller.startJourney();

        locationService.emit(controller.route!.destination.location);
        await Future<void>.delayed(const Duration(milliseconds: 1));

        expect(controller.journey!.status, EcoJourneyStatus.completed);
        expect(journeyRepository.completedAt, isNotNull);
        expect(journeyRepository.actualStepCount, isNotNull);
      },
    );

    test('cancelling removes an unfinished journey from persistence', () async {
      await controller.initialise();
      await controller.selectDestination(controller.destinations.first);
      await controller.startJourney();

      final didCancel = await controller.cancelJourney();

      expect(didCancel, isTrue);
      expect(journeyRepository.wasCancelled, isTrue);
      expect(controller.journey, isNull);
    });

    test('ends early while retaining the recorded partial progress', () async {
      await controller.initialise();
      await controller.selectDestination(controller.destinations.first);
      await controller.startJourney();

      final didEndEarly = await controller.endJourneyEarly();

      expect(didEndEarly, isTrue);
      expect(journeyRepository.wasEndedEarly, isTrue);
      expect(controller.journey!.status, EcoJourneyStatus.endedEarly);
      expect(journeyRepository.wasCancelled, isFalse);
    });

    test(
      'pauses and resumes an active journey while retaining its track',
      () async {
        await controller.initialise();
        await controller.selectDestination(controller.destinations.first);
        await controller.startJourney();

        await controller.pauseJourney();
        expect(controller.journey!.status, EcoJourneyStatus.paused);
        expect(journeyRepository.isPaused, isTrue);

        await controller.resumeJourney();
        expect(controller.journey!.status, EcoJourneyStatus.inProgress);
        expect(journeyRepository.isPaused, isFalse);
        expect(journeyRepository.trackPoints, hasLength(1));
      },
    );

    test(
      'completes on resume when the fresh GPS fix is at the destination',
      () async {
        await controller.initialise();
        await controller.selectDestination(controller.destinations.first);
        await controller.startJourney();
        await controller.pauseJourney();
        locationService.currentLocation =
            controller.route!.destination.location;

        await controller.resumeJourney();
        await Future<void>.delayed(const Duration(milliseconds: 1));

        expect(controller.journey!.status, EcoJourneyStatus.completed);
        expect(journeyRepository.completedAt, isNotNull);
        expect(controller.trackedWalkingDistanceKm, 0);
      },
    );

    test(
      'does not clear an active journey when the user leaves route preview',
      () async {
        await controller.initialise();
        await controller.selectDestination(controller.destinations.first);
        await controller.startJourney();

        controller.clearRoute();

        expect(controller.route, isNotNull);
        expect(controller.journey?.status, EcoJourneyStatus.inProgress);
        expect(controller.message, contains('still active'));
      },
    );

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
