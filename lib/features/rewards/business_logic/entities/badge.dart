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
class RewardBadge {
  const RewardBadge({
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
  int get remaining => (goal - progress).clamp(0, goal);
}
