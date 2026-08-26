import '../../business_logic/entities/point_transaction.dart';

/// Data-layer representation of a rewards point transaction.
class PointTransactionModel {
  const PointTransactionModel({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.points,
    required this.carbonSavedKg,
    required this.calories,
    required this.distanceKm,
    required this.journeyType,
    required this.icon,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final int points;
  final double carbonSavedKg;
  final int calories;
  final double distanceKm;
  final String journeyType;
  final String icon;

  PointTransaction toEntity() => PointTransaction(
    id: id,
    title: title,
    completedAt: completedAt,
    points: points,
    carbonSavedKg: carbonSavedKg,
    calories: calories,
    distanceKm: distanceKm,
    type: JourneyType.values.byName(journeyType),
    icon: icon,
  );

  factory PointTransactionModel.fromSupabaseRow(Map<String, dynamic> row) =>
      PointTransactionModel(
        id: row['id'] as String,
        title: row['title'] as String,
        completedAt: DateTime.parse(row['completed_at'] as String),
        points: row['points'] as int,
        carbonSavedKg: (row['carbon_saved_kg'] as num).toDouble(),
        calories: row['calories'] as int,
        distanceKm: (row['distance_km'] as num).toDouble(),
        journeyType: row['journey_type'] as String,
        icon: row['icon'] as String? ?? 'leaf',
      );

  factory PointTransactionModel.fromRewardTransactionRow(
    Map<String, dynamic> row, {
    Map<String, dynamic>? journey,
  }) {
    final sourceType = row['source_type'] as String?;
    final isFitnessGoal = sourceType == 'fitness_goal';
    final origin = _nonEmptyString(journey?['origin_name']);
    final destination = _nonEmptyString(journey?['destination_name']);
    final hasTransit = _number(journey?['actual_transit_distance_meters']) > 0;

    return PointTransactionModel(
      id: row['id'] as String,
      title: isFitnessGoal
          ? 'Fitness goal completed'
          : _journeyTitle(origin: origin, destination: destination),
      completedAt: DateTime.parse(
        row['journey_completed_at'] as String,
      ).toLocal(),
      points: _number(row['points']).toInt(),
      carbonSavedKg: _number(row['carbon_saved_kg']).toDouble(),
      calories: _number(row['calories_burned']).toInt(),
      distanceKm: _number(row['walking_distance_km']).toDouble(),
      journeyType: isFitnessGoal
          ? 'fitnessGoal'
          : hasTransit
          ? 'transit'
          : 'walk',
      icon: isFitnessGoal
          ? 'emojiEvents'
          : hasTransit
          ? 'accountBalance'
          : 'directionsWalk',
    );
  }
}

num _number(dynamic value) => switch (value) {
  num number => number,
  String text => num.tryParse(text) ?? 0,
  _ => 0,
};

String? _nonEmptyString(dynamic value) {
  final text = value as String?;
  return text == null || text.trim().isEmpty ? null : text.trim();
}

String _journeyTitle({String? origin, String? destination}) {
  if (origin != null && destination != null) return '$origin → $destination';
  return destination ?? origin ?? 'Completed eco-journey';
}
