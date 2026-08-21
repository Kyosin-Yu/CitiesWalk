class FitnessRecentBadge {
  const FitnessRecentBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final DateTime unlockedAt;
}
