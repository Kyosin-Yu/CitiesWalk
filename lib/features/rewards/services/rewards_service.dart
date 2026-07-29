import '../models/badge_model.dart';
import '../models/leaderboard_entry.dart';
import '../models/point_transaction.dart';

/// Data access boundary for rewards.
///
/// This MVP intentionally returns local sample data. Once the shared Supabase
/// client and schema are confirmed, replace the private mock lists with client
/// queries and map the result using the model `fromSupabaseRow` constructors.
class RewardsService {
  const RewardsService();

  Future<List<LeaderboardEntry>> fetchLeaderboard() async => _leaderboard;

  Future<List<BadgeModel>> fetchBadges() async => _badges;

  Future<List<PointTransaction>> fetchPointHistory() async => _transactions;

  Future<int> fetchCurrentUserPoints() async => 3240;

  static const List<LeaderboardEntry> _leaderboard = <LeaderboardEntry>[
    LeaderboardEntry(
      rank: 1,
      name: 'Sofia',
      points: 5820,
      achievement: 'City Champion',
      initials: 'SE',
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Luca',
      points: 4970,
      achievement: 'Eco Walker',
      initials: 'LR',
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Amir',
      points: 4310,
      achievement: 'Trail Blazer',
      initials: 'AD',
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Alex Park',
      points: 3240,
      achievement: 'Top 5 Eco Walker',
      initials: 'AP',
      isCurrentUser: true,
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Mei Lin',
      points: 3080,
      achievement: 'Top 5 Eco Walker',
      initials: 'ML',
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'Carlos Vega',
      points: 2890,
      achievement: 'Eco Explorer',
      initials: 'CV',
    ),
    LeaderboardEntry(
      rank: 7,
      name: 'Aisha Rahman',
      points: 2640,
      achievement: 'Green Commuter',
      initials: 'AR',
    ),
  ];

  static final List<BadgeModel> _badges = <BadgeModel>[
    BadgeModel(
      id: 'klcc',
      title: 'KLCC Explorer',
      description: 'Visit KLCC Park using a CitiesWalk eco-route.',
      status: BadgeStatus.unlocked,
      icon: BadgeIcon.city,
      progress: 1,
      goal: 1,
      earnedOn: DateTime(2026, 7, 20, 16, 15),
      completionLocation: 'KLCC Park, Kuala Lumpur',
    ),
    const BadgeModel(
      id: 'warrior',
      title: 'Eco Warrior',
      description:
          'Complete 10 eco-friendly city trips using CitiesWalk routes.',
      status: BadgeStatus.locked,
      icon: BadgeIcon.recycle,
      progress: 7,
      goal: 10,
    ),
    BadgeModel(
      id: 'sunrise',
      title: 'Sunrise Strider',
      description: 'Finish a walk before 8:00 AM.',
      status: BadgeStatus.unlocked,
      icon: BadgeIcon.sunrise,
      progress: 1,
      goal: 1,
      earnedOn: DateTime(2026, 6, 15, 7, 32),
      completionLocation: 'Titiwangsa Lake Gardens',
    ),
    const BadgeModel(
      id: 'carbon',
      title: 'Carbon Saver',
      description: 'Save 5 kg of estimated CO₂ emissions.',
      status: BadgeStatus.locked,
      icon: BadgeIcon.globe,
      progress: 3,
      goal: 5,
    ),
    BadgeModel(
      id: 'heritage',
      title: 'Heritage Hunter',
      description: 'Visit three cultural landmarks.',
      status: BadgeStatus.unlocked,
      icon: BadgeIcon.accountBalance,
      progress: 3,
      goal: 3,
      earnedOn: DateTime(2026, 7, 1, 10, 20),
      completionLocation: 'Merdeka Square, Kuala Lumpur',
    ),
    const BadgeModel(
      id: 'owl',
      title: 'Night Owl',
      description: 'Complete five evening walks after 7:00 PM.',
      status: BadgeStatus.locked,
      icon: BadgeIcon.owl,
      progress: 2,
      goal: 5,
    ),
    BadgeModel(
      id: 'leaf',
      title: 'Leaf Lover',
      description: 'Save 10 kg of estimated CO₂ emissions.',
      status: BadgeStatus.unlocked,
      icon: BadgeIcon.leaf,
      progress: 10,
      goal: 10,
      earnedOn: DateTime(2026, 5, 30, 18, 5),
      completionLocation: 'Perdana Botanical Garden',
    ),
    const BadgeModel(
      id: 'walker',
      title: 'City Strider',
      description: 'Walk a total of 25 km on eco-journeys.',
      status: BadgeStatus.locked,
      icon: BadgeIcon.directionsWalk,
      progress: 18,
      goal: 25,
    ),
  ];

  static final List<PointTransaction> _transactions = <PointTransaction>[
    PointTransaction(
      id: '1',
      title: 'KLCC Park → Petronas Twin Towers',
      completedAt: DateTime(2026, 7, 28, 16, 15),
      points: 120,
      carbonSavedKg: 0.8,
      calories: 320,
      distanceKm: 2.4,
      type: JourneyType.walk,
      icon: 'city',
    ),
    PointTransaction(
      id: '2',
      title: 'Batu Caves Transit Route',
      completedAt: DateTime(2026, 7, 25, 10, 30),
      points: 210,
      carbonSavedKg: 1.4,
      calories: 510,
      distanceKm: 4.1,
      type: JourneyType.transit,
      icon: 'accountBalance',
    ),
    PointTransaction(
      id: '3',
      title: 'Central Market Walk',
      completedAt: DateTime(2026, 7, 22, 14, 15),
      points: 80,
      carbonSavedKg: 0.5,
      calories: 180,
      distanceKm: 1.6,
      type: JourneyType.walk,
      icon: 'storefront',
    ),
    PointTransaction(
      id: '4',
      title: 'Perdana Botanical Garden Loop',
      completedAt: DateTime(2026, 7, 19, 8, 45),
      points: 175,
      carbonSavedKg: 1.1,
      calories: 410,
      distanceKm: 3.7,
      type: JourneyType.walk,
      icon: 'leaf',
    ),
  ];
}
