enum JourneyType { walk, transit, fitnessGoal }

/// One entry in the user's rewards point history.
class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.points,
    required this.carbonSavedKg,
    required this.calories,
    required this.distanceKm,
    required this.type,
    required this.icon,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final int points;
  final double carbonSavedKg;
  final int calories;
  final double distanceKm;
  final JourneyType type;
  final String icon;
}
