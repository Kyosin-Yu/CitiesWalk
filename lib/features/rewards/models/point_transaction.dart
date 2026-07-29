enum JourneyType { walk, transit }

/// Points awarded for one completed eco-journey.
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

  factory PointTransaction.fromSupabaseRow(Map<String, dynamic> row) {
    return PointTransaction(
      id: row['id'] as String,
      title: row['title'] as String,
      completedAt: DateTime.parse(row['completed_at'] as String),
      points: row['points'] as int,
      carbonSavedKg: (row['carbon_saved_kg'] as num).toDouble(),
      calories: row['calories'] as int,
      distanceKm: (row['distance_km'] as num).toDouble(),
      type: JourneyType.values.byName(row['journey_type'] as String),
      icon: row['icon'] as String? ?? 'leaf',
    );
  }
}
