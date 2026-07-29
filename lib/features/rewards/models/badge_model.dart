enum BadgeStatus { unlocked, locked }

enum BadgeIcon {
  city,
  recycle,
  sunrise,
  globe,
  accountBalance,
  owl,
  leaf,
  directionsWalk,
}

/// An achievement that can be earned by completing eco-friendly activities.
class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
    required this.progress,
    required this.goal,
    this.earnedOn,
    this.completionLocation,
  });

  final String id;
  final String title;
  final String description;
  final BadgeStatus status;
  final BadgeIcon icon;
  final int progress;
  final int goal;
  final DateTime? earnedOn;
  final String? completionLocation;

  bool get isUnlocked => status == BadgeStatus.unlocked;
  double get progressFraction =>
      goal == 0 ? 0 : (progress / goal).clamp(0, 1).toDouble();
  int get remaining => (goal - progress).clamp(0, goal) as int;

  factory BadgeModel.fromSupabaseRow(Map<String, dynamic> row) {
    return BadgeModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      status: row['unlocked'] == true
          ? BadgeStatus.unlocked
          : BadgeStatus.locked,
      icon: BadgeIcon.values.byName(row['icon'] as String),
      progress: row['progress'] as int,
      goal: row['goal'] as int,
      earnedOn: row['earned_on'] == null
          ? null
          : DateTime.parse(row['earned_on'] as String),
      completionLocation: row['completion_location'] as String?,
    );
  }
}
