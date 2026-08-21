import '../../business_logic/entities/fitness_recent_badge.dart';

class FitnessRecentBadgeModel {
  const FitnessRecentBadgeModel({
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

  factory FitnessRecentBadgeModel.fromRows({
    required Map<String, dynamic> badge,
    required Map<String, dynamic> progress,
  }) => FitnessRecentBadgeModel(
    id: badge['id'] as String,
    title: badge['title'] as String,
    description: badge['description'] as String,
    iconKey: badge['icon_key'] as String,
    unlockedAt: DateTime.parse(progress['unlocked_at'] as String).toLocal(),
  );

  FitnessRecentBadge toEntity() => FitnessRecentBadge(
    id: id,
    title: title,
    description: description,
    iconKey: iconKey,
    unlockedAt: unlockedAt,
  );
}
