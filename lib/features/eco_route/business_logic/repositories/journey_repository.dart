import '../entities/eco_route.dart';
import '../entities/eco_location.dart';

/// Persistence contract for journeys that a signed-in user starts or completes.
abstract interface class JourneyRepository {
  Future<String> createStartedJourney({
    required String userId,
    required EcoRoute route,
    required DateTime startedAt,
  });

  Future<void> completeJourney({
    required String journeyId,
    required DateTime endedAt,
    required EcoRoute finalRoute,
  });

  Future<void> updateRouteEstimates({
    required String journeyId,
    required EcoRoute route,
  });

  Future<void> pauseJourney({required String journeyId});

  Future<void> resumeJourney({required String journeyId});

  Future<void> recordTrackPoint({
    required String journeyId,
    required EcoLocation location,
    required DateTime recordedAt,
  });
}
