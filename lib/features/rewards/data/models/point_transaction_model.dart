import '../../business_logic/entities/point_transaction.dart';

/// Data-layer representation of a rewarded journey record.
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
}
