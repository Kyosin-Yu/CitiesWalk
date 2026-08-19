import '../../business_logic/entities/completed_fitness_journey.dart';

class FitnessJourneyModel {
  const FitnessJourneyModel({
    required this.id,
    required this.walkingDistanceMeters,
    required this.estimatedCalories,
    required this.estimatedCarbonSavedKg,
    required this.completedAt,
  });

  final String id;
  final int walkingDistanceMeters;
  final int estimatedCalories;
  final double estimatedCarbonSavedKg;
  final DateTime completedAt;

  factory FitnessJourneyModel.fromSupabaseRow(Map<String, dynamic> row) {
    return FitnessJourneyModel(
      id: row['id'] as String,
      walkingDistanceMeters:
          (row['estimated_walking_distance_meters'] as num?)?.round() ?? 0,
      estimatedCalories: (row['estimated_calories'] as num?)?.round() ?? 0,
      estimatedCarbonSavedKg:
          (row['estimated_carbon_saved_kg'] as num?)?.toDouble() ?? 0,
      completedAt: DateTime.parse(row['ended_at'] as String).toLocal(),
    );
  }

  CompletedFitnessJourney toEntity() => CompletedFitnessJourney(
    id: id,
    walkingDistanceMeters: walkingDistanceMeters,
    estimatedCalories: estimatedCalories,
    estimatedCarbonSavedKg: estimatedCarbonSavedKg,
    completedAt: completedAt,
  );
}
