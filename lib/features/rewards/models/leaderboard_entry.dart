/// A single participant's standing in the Green & Fit leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
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

  factory LeaderboardEntry.fromSupabaseRow(Map<String, dynamic> row) {
    return LeaderboardEntry(
      rank: row['rank'] as int,
      name: row['display_name'] as String,
      points: row['points'] as int,
      achievement: row['achievement'] as String? ?? 'Eco Explorer',
      initials: row['initials'] as String? ?? '?',
      isCurrentUser: row['is_current_user'] as bool? ?? false,
    );
  }
}
