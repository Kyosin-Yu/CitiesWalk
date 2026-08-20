class CompletedFitnessJourney {
  const CompletedFitnessJourney({
    required this.id,
    required this.walkingDistanceMeters,
    required this.estimatedCalories,
    required this.estimatedCarbonSavedKg,
    required this.completedAt,
    this.stepCount = 0,
  });

  final String id;
  final int walkingDistanceMeters;
  final int estimatedCalories;
  final double estimatedCarbonSavedKg;
  final DateTime completedAt;
  final int stepCount;
}
