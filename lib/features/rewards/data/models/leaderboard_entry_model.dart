import '../../business_logic/entities/leaderboard_entry.dart';

/// Data-layer representation of a leaderboard row.
class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.rank,
    required this.name,
    required this.points,
    required this.achievement,
    required this.initials,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final int points;
  final String achievement;
  final String initials;
  final bool isCurrentUser;

  LeaderboardEntry toEntity() => LeaderboardEntry(
    rank: rank,
    name: name,
    points: points,
    achievement: achievement,
    initials: initials,
    isCurrentUser: isCurrentUser,
  );

  factory LeaderboardEntryModel.fromSupabaseRow(Map<String, dynamic> row) =>
      LeaderboardEntryModel(
        rank: row['rank'] as int,
        name: row['display_name'] as String,
        points: row['points'] as int,
        achievement: row['achievement'] as String? ?? 'Eco Explorer',
        initials: row['initials'] as String? ?? '?',
        isCurrentUser: row['is_current_user'] as bool? ?? false,
      );
}
