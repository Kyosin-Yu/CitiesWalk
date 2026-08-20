import '../../business_logic/entities/fitness_goal.dart';

class FitnessGoalModel {
  const FitnessGoalModel({
    required this.id,
    required this.userId,
    required this.metric,
    required this.period,
    required this.targetValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final FitnessGoalMetric metric;
  final FitnessGoalPeriod period;
  final double targetValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FitnessGoalModel.fromSupabaseRow(Map<String, dynamic> row) {
    final metricValue = row['metric'] as String;
    final periodValue = row['period'] as String;
    return FitnessGoalModel(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      metric: FitnessGoalMetric.values.firstWhere(
        (metric) => metric.storageValue == metricValue,
        orElse: () => throw FormatException(
          'Unsupported fitness goal metric: $metricValue',
        ),
      ),
      period: FitnessGoalPeriod.values.firstWhere(
        (period) => period.storageValue == periodValue,
        orElse: () => throw FormatException(
          'Unsupported fitness goal period: $periodValue',
        ),
      ),
      targetValue: (row['target_value'] as num).toDouble(),
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
    );
  }

  FitnessGoal toEntity() => FitnessGoal(
    id: id,
    userId: userId,
    metric: metric,
    period: period,
    targetValue: targetValue,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
