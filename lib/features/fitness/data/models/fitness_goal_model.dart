import '../../business_logic/entities/fitness_goal.dart';

class FitnessGoalModel {
  const FitnessGoalModel({
    required this.id,
    required this.userId,
    required this.metric,
    required this.period,
    required this.targetValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.completedValue,
    this.rewardPoints,
    this.rewardPolicyVersion,
  });

  final String id;
  final String userId;
  final FitnessGoalMetric metric;
  final FitnessGoalPeriod period;
  final double targetValue;
  final FitnessGoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final double? completedValue;
  final int? rewardPoints;
  final String? rewardPolicyVersion;

  factory FitnessGoalModel.fromSupabaseRow(Map<String, dynamic> row) {
    final metricValue = row['metric'] as String;
    final periodValue = row['period'] as String;
    final statusValue = row['status'] as String;
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
      status: FitnessGoalStatus.values.firstWhere(
        (status) => status.storageValue == statusValue,
        orElse: () => throw FormatException(
          'Unsupported fitness goal status: $statusValue',
        ),
      ),
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
      completedAt: _optionalDate(row['completed_at']),
      cancelledAt: _optionalDate(row['cancelled_at']),
      completedValue: (row['completed_value'] as num?)?.toDouble(),
      rewardPoints: (row['reward_points'] as num?)?.round(),
      rewardPolicyVersion: row['reward_policy_version'] as String?,
    );
  }

  FitnessGoal toEntity() => FitnessGoal(
    id: id,
    userId: userId,
    metric: metric,
    period: period,
    targetValue: targetValue,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
    completedAt: completedAt,
    cancelledAt: cancelledAt,
    completedValue: completedValue,
    rewardPoints: rewardPoints,
    rewardPolicyVersion: rewardPolicyVersion,
  );

  static DateTime? _optionalDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toLocal();
}
