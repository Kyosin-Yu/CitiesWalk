import '../../business_logic/entities/completed_fitness_journey.dart';

class FitnessJourneyModel {
  const FitnessJourneyModel({
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

  factory FitnessJourneyModel.fromSupabaseRow(Map<String, dynamic> row) {
    return FitnessJourneyModel(
      id: row['id'] as String,
      walkingDistanceMeters:
          (row['actual_walking_distance_meters'] as num?)?.round() ??
          (row['estimated_walking_distance_meters'] as num?)?.round() ??
          0,
      estimatedCalories:
          (row['actual_calories_burned'] as num?)?.round() ??
          (row['estimated_calories'] as num?)?.round() ??
          0,
      estimatedCarbonSavedKg:
          (row['actual_carbon_saved_kg'] as num?)?.toDouble() ??
          (row['estimated_carbon_saved_kg'] as num?)?.toDouble() ??
          0,
      completedAt: DateTime.parse(row['ended_at'] as String).toLocal(),
      stepCount: (row['actual_step_count'] as num?)?.round() ?? 0,
    );
  }

  CompletedFitnessJourney toEntity() => CompletedFitnessJourney(
    id: id,
    walkingDistanceMeters: walkingDistanceMeters,
    estimatedCalories: estimatedCalories,
    estimatedCarbonSavedKg: estimatedCarbonSavedKg,
    completedAt: completedAt,
    stepCount: stepCount,
  );
}
