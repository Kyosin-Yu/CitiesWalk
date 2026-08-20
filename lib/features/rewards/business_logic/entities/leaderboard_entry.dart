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
}
