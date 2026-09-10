import 'package:citieswalk/features/rewards/data/models/leaderboard_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final rank in [0, 1, 5]) {
    test('privacy hides name and photo at rank $rank', () {
      final entry = LeaderboardEntryModel(
        rank: rank,
        name: 'Old name',
        points: 12,
        achievement: 'Eco Explorer',
        initials: 'ON',
        isCurrentUser: true,
      );
      final hidden = entry
          .withProfile(
            name: 'Kyosin_Yu',
            publicProfile: false,
            imageUrl: 'https://example.com/photo.png',
          )
          .toEntity();
      expect(hidden.name, 'Anonymous');
      expect(hidden.initials, 'A');
      expect(hidden.profileImageUrl, isNull);
      expect(hidden.rank, rank);
      expect(hidden.points, 12);
      expect(hidden.isCurrentUser, isTrue);

      final visible = entry
          .withProfile(
            name: 'Kyosin_Yu',
            publicProfile: true,
            imageUrl: 'https://example.com/photo.png',
          )
          .toEntity();
      expect(visible.name, 'Kyosin_Yu');
      expect(visible.profileImageUrl, 'https://example.com/photo.png');
    });
  }
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
