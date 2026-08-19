class EcoJourneyHistoryItem {
  const EcoJourneyHistoryItem({
    required this.id,
    required this.destinationName,
    required this.destinationCategory,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.durationMinutes,
    required this.walkingDistanceMeters,
    required this.estimatedCalories,
    required this.estimatedCarbonSavedKg,
    required this.completedAt,
  });

  final String id;
  final String destinationName;
  final String? destinationCategory;
  final double destinationLatitude;
  final double destinationLongitude;
  final int durationMinutes;
  final int walkingDistanceMeters;
  final int estimatedCalories;
  final double estimatedCarbonSavedKg;
  final DateTime completedAt;
}
