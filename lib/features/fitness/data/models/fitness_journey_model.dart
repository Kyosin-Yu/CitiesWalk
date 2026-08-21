import '../../business_logic/entities/completed_fitness_journey.dart';

class FitnessJourneyModel {
  const FitnessJourneyModel({
    required this.id,
    required this.walkingDistanceMeters,
    required this.estimatedCalories,
    required this.estimatedCarbonSavedKg,
    required this.startedAt,
    required this.completedAt,
    this.stepCount = 0,
    this.countsAsCompletedRoute = true,
    this.originName,
    this.destinationName,
    this.distanceSource = FitnessMetricSource.estimated,
    this.caloriesSource = FitnessMetricSource.estimated,
    this.carbonSource = FitnessMetricSource.estimated,
    this.stepsSource = FitnessMetricSource.unavailable,
  });

  final String id;
  final int walkingDistanceMeters;
  final int estimatedCalories;
  final double estimatedCarbonSavedKg;
  final DateTime? startedAt;
  final DateTime completedAt;
  final int stepCount;
  final bool countsAsCompletedRoute;
  final String? originName;
  final String? destinationName;
  final FitnessMetricSource distanceSource;
  final FitnessMetricSource caloriesSource;
  final FitnessMetricSource carbonSource;
  final FitnessMetricSource stepsSource;

  factory FitnessJourneyModel.fromSupabaseRow(Map<String, dynamic> row) {
    return FitnessJourneyModel(
      id: row['id'] as String,
      originName: _optionalText(row['origin_name']),
      destinationName: _optionalText(row['destination_name']),
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
      startedAt: _optionalDate(row['started_at']),
      completedAt: DateTime.parse(row['ended_at'] as String).toLocal(),
      stepCount: (row['actual_step_count'] as num?)?.round() ?? 0,
      countsAsCompletedRoute: row['status'] == 'completed',
      distanceSource: row['actual_walking_distance_meters'] == null
          ? FitnessMetricSource.estimated
          : FitnessMetricSource.recorded,
      caloriesSource: row['actual_calories_burned'] == null
          ? FitnessMetricSource.estimated
          : FitnessMetricSource.recorded,
      carbonSource: row['actual_carbon_saved_kg'] == null
          ? FitnessMetricSource.estimated
          : FitnessMetricSource.recorded,
      stepsSource: row['actual_step_count'] == null
          ? FitnessMetricSource.unavailable
          : FitnessMetricSource.recorded,
    );
  }

  CompletedFitnessJourney toEntity() => CompletedFitnessJourney(
    id: id,
    walkingDistanceMeters: walkingDistanceMeters,
    estimatedCalories: estimatedCalories,
    estimatedCarbonSavedKg: estimatedCarbonSavedKg,
    startedAt: startedAt,
    completedAt: completedAt,
    stepCount: stepCount,
    countsAsCompletedRoute: countsAsCompletedRoute,
    originName: originName,
    destinationName: destinationName,
    distanceSource: distanceSource,
    caloriesSource: caloriesSource,
    carbonSource: carbonSource,
    stepsSource: stepsSource,
  );

  static DateTime? _optionalDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toLocal();

  static String? _optionalText(Object? value) {
    final text = value as String?;
    return text == null || text.trim().isEmpty ? null : text.trim();
  }
}
