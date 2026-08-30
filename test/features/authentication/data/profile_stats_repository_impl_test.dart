import 'package:citieswalk/features/authentication/data/repositories/profile_stats_repository_impl.dart';
import 'package:citieswalk/features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import 'package:citieswalk/features/eco_route/business_logic/repositories/journey_history_repository.dart';
import 'package:citieswalk/features/rewards/business_logic/entities/badge.dart';
import 'package:citieswalk/features/rewards/business_logic/entities/leaderboard_entry.dart';
import 'package:citieswalk/features/rewards/business_logic/entities/point_transaction.dart';
import 'package:citieswalk/features/rewards/business_logic/repositories/rewards_repository.dart';
import 'package:citieswalk/features/reviews/business_logic/entities/place_review.dart';
import 'package:citieswalk/features/reviews/business_logic/entities/review_destination.dart';
import 'package:citieswalk/features/reviews/business_logic/entities/user_review.dart';
import 'package:citieswalk/features/reviews/business_logic/repositories/review_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aggregates only completed journeys and unlocked badges', () async {
    final repository = ProfileStatsRepositoryImpl(
      _JourneysRepository(),
      _ReviewsRepository(),
      _RewardsRepository(),
    );

    final stats = await repository.fetchStats(userId: 'user-1');

    expect(stats.journeyCount, 1);
    expect(stats.reviewCount, 1);
    expect(stats.badgeCount, 1);
    expect(stats.points, 3200);
  });
}

class _JourneysRepository implements JourneyHistoryRepository {
  @override
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  }) async => [
    _journey('completed', isCompleted: true),
    _journey('ended-early', isCompleted: false),
  ];

  EcoJourneyHistoryItem _journey(String id, {required bool isCompleted}) =>
      EcoJourneyHistoryItem(
        id: id,
        destinationName: 'KLCC',
        destinationCategory: 'Park',
        destinationLatitude: 3.15,
        destinationLongitude: 101.71,
        durationMinutes: 10,
        walkingDistanceMeters: 500,
        transitDistanceMeters: 0,
        stepCount: 700,
        estimatedCalories: 30,
        estimatedCarbonSavedKg: 0.1,
        completedAt: DateTime.utc(2026),
        isCompleted: isCompleted,
      );
}

class _ReviewsRepository implements ReviewRepository {
  @override
  Future<List<UserReview>> fetchUserReviews(String userId) async => [
    UserReview(
      destination: const ReviewDestination(
        id: 'klcc',
        name: 'KLCC',
        category: 'Park',
      ),
      review: PlaceReview(
        id: 'review-1',
        userId: userId,
        authorName: 'Walker',
        rating: 5,
        comment: 'Great walk',
        createdAt: DateTime.utc(2026),
      ),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RewardsRepository implements RewardsRepository {
  @override
  Future<List<RewardBadge>> getBadges() async => const [
    RewardBadge(
      id: 'earned',
      title: 'Earned',
      description: 'Earned badge',
      status: BadgeStatus.unlocked,
      icon: BadgeIcon.leaf,
      progress: 1,
      goal: 1,
    ),
    RewardBadge(
      id: 'locked',
      title: 'Locked',
      description: 'Locked badge',
      status: BadgeStatus.locked,
      icon: BadgeIcon.city,
      progress: 0,
      goal: 1,
    ),
  ];

  @override
  Future<int> getCurrentUserPoints() async => 3200;

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async => const [];

  @override
  Future<List<PointTransaction>> getPointHistory() async => const [];
}
