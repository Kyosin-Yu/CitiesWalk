class EcoJourneyHistoryItem {
  const EcoJourneyHistoryItem({
    required this.id,
    required this.destinationName,
    required this.destinationCategory,
    required this.durationMinutes,
    required this.walkingDistanceMeters,
    required this.completedAt,
  });

  final String id;
  final String destinationName;
  final String? destinationCategory;
  final int durationMinutes;
  final int walkingDistanceMeters;
  final DateTime completedAt;
}
