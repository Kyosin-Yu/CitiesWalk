enum FitnessGoalMetric {
  walkingDistance('walking_distance', 'Walking distance', 'km'),
  calories('calories', 'Calories', 'kcal'),
  carbonSaved('carbon_saved', 'CO₂ saved', 'kg');

  const FitnessGoalMetric(this.storageValue, this.label, this.unit);

  final String storageValue;
  final String label;
  final String unit;
}

enum FitnessGoalPeriod {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly');

  const FitnessGoalPeriod(this.storageValue, this.label);

  final String storageValue;
  final String label;
}

class FitnessGoal {
  const FitnessGoal({
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
}

class FitnessGoalInput {
  const FitnessGoalInput({
    required this.metric,
    required this.period,
    required this.targetValue,
  });

  final FitnessGoalMetric metric;
  final FitnessGoalPeriod period;
  final double targetValue;
}
