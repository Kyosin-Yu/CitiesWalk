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
    required int actualDurationMinutes,
    required double actualWalkingDistanceKm,
    required double actualTransitDistanceKm,
    required int actualStepCount,
    required int actualCaloriesBurned,
    required double actualCarbonSavedKg,
  });

  /// Persists the real progress achieved when the traveller intentionally ends
  /// a trip before reaching the destination. It is not a completed journey.
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
  });

  /// Deletes an unfinished journey. Cascading foreign keys remove its route
  /// steps and GPS samples, so it cannot appear in journey history.
  Future<void> cancelJourney({required String journeyId});

  Future<void> updateRouteEstimates({
    required String journeyId,
    required EcoRoute route,
  });

  Future<void> recordTrackPoint({
    required String journeyId,
    required EcoLocation location,
    required DateTime recordedAt,
  });
}
