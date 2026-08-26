import '../../business_logic/entities/fitness_route_point.dart';

class FitnessRoutePointModel {
  const FitnessRoutePointModel({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;

  factory FitnessRoutePointModel.fromSupabaseRow(Map<String, dynamic> row) =>
      FitnessRoutePointModel(
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble(),
        recordedAt: DateTime.parse(row['recorded_at'] as String).toLocal(),
      );

  FitnessRoutePoint toEntity() => FitnessRoutePoint(
    latitude: latitude,
    longitude: longitude,
    recordedAt: recordedAt,
  );
}
