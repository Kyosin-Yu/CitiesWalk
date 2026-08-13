import '../entities/eco_route.dart';

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
  });
}
