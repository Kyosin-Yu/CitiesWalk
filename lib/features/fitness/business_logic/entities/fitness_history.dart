import 'completed_fitness_journey.dart';

enum FitnessHistoryPeriod {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const FitnessHistoryPeriod(this.label);

  final String label;
}

class FitnessHistoryBucket {
  const FitnessHistoryBucket({
    required this.startedAt,
    required this.journeyCount,
    required this.completedRouteCount,
    required this.steps,
    required this.walkingDistanceKm,
    required this.caloriesKcal,
    required this.carbonSavedKg,
  });

  final DateTime startedAt;
  final int journeyCount;
  final int completedRouteCount;
  final int steps;
  final double walkingDistanceKm;
  final int caloriesKcal;
  final double carbonSavedKg;
}

class FitnessHistorySummary {
  const FitnessHistorySummary({
    required this.period,
    required this.anchorDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.journeyCount,
    required this.completedRouteCount,
    required this.activeDays,
    required this.steps,
    required this.walkingDistanceKm,
    required this.caloriesKcal,
    required this.carbonSavedKg,
    required this.buckets,
    required this.journeys,
  });

  final FitnessHistoryPeriod period;
  final DateTime anchorDate;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int journeyCount;
  final int completedRouteCount;
  final int activeDays;
  final int steps;
  final double walkingDistanceKm;
  final int caloriesKcal;
  final double carbonSavedKg;
  final List<FitnessHistoryBucket> buckets;
  final List<CompletedFitnessJourney> journeys;

  bool get hasActivity => journeyCount > 0;
}
