import '../../../eco_route/business_logic/repositories/journey_history_repository.dart';
import '../../../rewards/business_logic/repositories/rewards_repository.dart';
import '../../../reviews/business_logic/repositories/review_repository.dart';
import '../../business_logic/entities/profile_stats.dart';
import '../../business_logic/repositories/profile_stats_repository.dart';

class ProfileStatsRepositoryImpl implements ProfileStatsRepository {
  ProfileStatsRepositoryImpl(
    this._journeyRepository,
    this._reviewRepository,
    this._rewardsRepository,
  );

  final JourneyHistoryRepository _journeyRepository;
  final ReviewRepository _reviewRepository;
  final RewardsRepository _rewardsRepository;

  @override
  Future<ProfileStats> fetchStats({required String userId}) async {
    final journeysFuture = _journeyRepository.fetchCompletedJourneys(
      userId: userId,
    );
    final reviewsFuture = _reviewRepository.fetchUserReviews(userId);
    final badgesFuture = _rewardsRepository.getBadges();
    final pointsFuture = _rewardsRepository.getCurrentUserPoints();

    final journeys = await journeysFuture;
    final reviews = await reviewsFuture;
    final badges = await badgesFuture;
    final points = await pointsFuture;

    return ProfileStats(
      journeyCount: journeys.where((journey) => journey.isCompleted).length,
      reviewCount: reviews.length,
      badgeCount: badges.where((badge) => badge.isUnlocked).length,
      points: points,
    );
  }
}
