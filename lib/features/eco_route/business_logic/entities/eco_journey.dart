import 'eco_route.dart';

enum EcoJourneyStatus { preview, inProgress, paused, completed, endedEarly }

class EcoJourney {
  const EcoJourney({
    this.id,
    required this.userId,
    required this.route,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.actualWalkingDistanceKm = 0,
    this.actualTransitDistanceKm = 0,
    this.actualStepCount = 0,
    this.actualCaloriesBurned = 0,
    this.actualCarbonSavedKg = 0,
  });

  final String? id;
  final String userId;
  final EcoRoute route;
  final EcoJourneyStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double actualWalkingDistanceKm;
  final double actualTransitDistanceKm;
  final int actualStepCount;
  final int actualCaloriesBurned;
  final double actualCarbonSavedKg;
}
