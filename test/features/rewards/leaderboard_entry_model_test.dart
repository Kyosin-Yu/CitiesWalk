import 'package:citieswalk/features/rewards/data/models/leaderboard_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a private leaderboard row without exposing a name', () {
    final entry = LeaderboardEntryModel.fromLeaderboardRow(const {
      'user_id': null,
      'display_name': 'Anonymous',
      'initials': 'A',
      'total_points': 373,
      'rank': 7,
    }, currentUserId: 'current-user');

    expect(entry.name, 'Anonymous');
    expect(entry.initials, 'A');
    expect(entry.isCurrentUser, isFalse);
  });
}
