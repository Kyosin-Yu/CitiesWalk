import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/di/service_locator.dart';
import '../core/services/eco_points_service.dart';
import '../core/models/destination_review_summary.dart';
import '../core/services/destination_review_summary_service.dart';
import '../features/authentication/business_logic/providers/auth_controller.dart';
import '../features/authentication/presentation/pages/profile_page.dart';
import '../features/eco_route/business_logic/entities/eco_destination.dart';
import '../features/eco_route/business_logic/providers/eco_route_controller.dart';
import '../features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import '../features/eco_route/data/data_sources/device_location_data_source.dart';
import '../features/eco_route/data/data_sources/google_eco_route_data_source.dart';
import '../features/eco_route/data/repositories/google_eco_route_repository.dart';
import '../features/eco_route/data/repositories/supabase_journey_repository.dart';
import '../features/eco_route/data/data_sources/supabase_journey_data_source.dart';
import '../features/eco_route/presentation/pages/eco_route_page.dart';
import '../features/fitness/business_logic/providers/fitness_controller.dart';
import '../features/fitness/business_logic/entities/fitness_dashboard.dart';
import '../features/fitness/business_logic/repositories/fitness_repository.dart';
import '../features/fitness/business_logic/repositories/health_activity_repository.dart';
import '../features/fitness/presentation/pages/fitness_page.dart';
import '../features/rewards/presentation/screens/rewards_hub_screen.dart';
import '../features/rewards/presentation/screens/achievement_locker_screen.dart';
import '../features/rewards/business_logic/providers/rewards_controller.dart';
import '../features/rewards/business_logic/repositories/rewards_repository.dart';
import '../features/reviews/business_logic/providers/reviews_provider.dart';
import '../features/reviews/business_logic/entities/review_destination.dart';
import '../features/reviews/data/data_sources/review_image_data_source.dart';
import '../features/reviews/data/repositories/review_image_repository_impl.dart';
import '../features/reviews/data/repositories/supabase_review_repository.dart';
import '../features/reviews/data/data_sources/supabase_review_data_source.dart';
import '../features/reviews/presentation/reviews_screen.dart';
import '../features/reviews/presentation/my_reviews_screen.dart';
import 'home_dashboard.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final ValueNotifier<int> _journeyHistoryVersion = ValueNotifier(0);
  final ValueNotifier<EcoJourneyHistoryItem?> _tripToReplan = ValueNotifier(
    null,
  );
  final ValueNotifier<EcoDestination?> _destinationToPlan = ValueNotifier(null);
  final ValueNotifier<FitnessDashboard?> _homeFitnessDashboard = ValueNotifier(
    null,
  );
  late final FitnessController _fitnessController = FitnessController(
    userId: sl<AuthController>().currentUser!.id,
    userName:
        sl<AuthController>().currentUser!.fullName ??
        sl<AuthController>().currentUser!.email,
    repository: sl<FitnessRepository>(),
    healthActivityRepository: sl<HealthActivityRepository>(),
    ecoPointsService: sl<EcoPointsService>(),
  );
  final ValueNotifier<int> _reviewSummaryVersion = ValueNotifier(0);
  final ValueNotifier<Map<String, DestinationReviewSummary>>
  _homeReviewSummaries = ValueNotifier(const {});
  late final SupabaseReviewRepository _reviewRepository =
      SupabaseReviewRepository(SupabaseReviewDataSource(sl<SupabaseClient>()));
  late final ReviewImageRepositoryImpl _reviewImageRepository =
      ReviewImageRepositoryImpl(ReviewImageDataSource());
  final Map<String, ReviewsProvider> _reviewProviders = {};
  ReviewDestination? _activeReviewDestination;
  ReviewsProvider? _activeReviewsProvider;

  late final List<Widget> _pages = [
    HomeDashboard(
      userId: sl<AuthController>().currentUser!.id,
      journeyHistoryRepository: SupabaseJourneyRepository(
        SupabaseJourneyDataSource(sl<SupabaseClient>()),
      ),
      historyRefreshSignal: _journeyHistoryVersion,
      onRefresh: _refreshHomeDashboard,
      onNavigate: _selectDestination,
      onPlanAgain: _planSavedTripAgain,
      onPlanDestination: _planHomeDestination,
      reviewSummaries: _homeReviewSummaries,
      fitnessDashboard: _homeFitnessDashboard,
    ),
    _EcoRouteEntryPage(
      onJourneyCompleted: _refreshJourneyHistory,
      tripToReplan: _tripToReplan,
      destinationToPlan: _destinationToPlan,
      reviewSummaryRefreshSignal: _reviewSummaryVersion,
      reviewSummaryService: _reviewRepository,
      onOpenReviews: _openReviews,
      onViewFitness: () => _selectDestination(2),
    ),
    ChangeNotifierProvider.value(
      value: _fitnessController,
      child: FitnessPage(onViewRewards: () => _selectDestination(3)),
    ),
    const RewardsHubScreen(),
    ProfilePage(onOpenMyReviews: _openMyReviews, onOpenMyBadges: _openMyBadges),
  ];

  @override
  void initState() {
    super.initState();
    _fitnessController.addListener(_syncHomeFitnessDashboard);
    unawaited(_fitnessController.loadDashboard());
    unawaited(_refreshHomeReviewSummaries());
  }

  void _syncHomeFitnessDashboard() {
    _homeFitnessDashboard.value = _fitnessController.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _activeReviewsProvider == null
          ? IndexedStack(index: _selectedIndex, children: _pages)
          : ReviewsScreen(
              destination: _activeReviewDestination!,
              reviewsProvider: _activeReviewsProvider!,
              onClose: _closeReviews,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk_rounded),
            label: 'Fitness',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _selectDestination(int index) {
    if (_activeReviewsProvider != null) {
      _activeReviewDestination = null;
      _activeReviewsProvider = null;
      _reviewSummaryVersion.value++;
    }
    if (index == 2) {
      unawaited(_fitnessController.refresh());
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshJourneyHistory() {
    _journeyHistoryVersion.value++;
    unawaited(_fitnessController.refresh());
  }

  Future<void> _refreshHomeDashboard() async {
    _journeyHistoryVersion.value++;
    await Future.wait([
      _fitnessController.refresh(),
      _refreshHomeReviewSummaries(),
    ]);
  }

  void _planHomeDestination(EcoDestination destination) {
    _destinationToPlan.value = destination;
    _selectDestination(1);
  }

  Future<void> _refreshHomeReviewSummaries() async {
    const destinationIds = ['klcc-park', 'central-market', 'batu-caves'];
    try {
      final entries = await Future.wait(
        destinationIds.map(
          (id) async => MapEntry(
            id,
            await _reviewRepository.getDestinationReviewSummary(id),
          ),
        ),
      );
      if (!mounted) {
        return;
      }
      _homeReviewSummaries.value = Map.unmodifiable(Map.fromEntries(entries));
    } catch (_) {
      // The Home dashboard remains usable when community reviews are offline.
      if (!mounted) {
        return;
      }
      _homeReviewSummaries.value = const {};
    }
  }

  void _planSavedTripAgain(EcoJourneyHistoryItem journey) {
    _tripToReplan.value = journey;
    _selectDestination(1);
  }

  void _openReviews(EcoDestination destination) {
    final reviewDestination = ReviewDestination(
      id: destination.id,
      name: destination.name,
      category: destination.category,
    );
    final reviewsProvider = _reviewProviders.putIfAbsent(
      destination.id,
      () => ReviewsProvider(
        _reviewRepository,
        _reviewImageRepository,
        reviewDestination,
        currentUserId: sl<AuthController>().currentUser!.id,
        currentUserName:
            sl<AuthController>().currentUser!.fullName ?? 'CitiesWalk User',
      ),
    );

    setState(() {
      _selectedIndex = 1;
      _activeReviewDestination = reviewDestination;
      _activeReviewsProvider = reviewsProvider;
    });
  }

  void _closeReviews() {
    setState(() {
      _activeReviewDestination = null;
      _activeReviewsProvider = null;
    });
    _reviewSummaryVersion.value++;
    unawaited(_refreshHomeReviewSummaries());
  }

  void _openMyReviews() {
    final user = sl<AuthController>().currentUser;
    if (user == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MyReviewsScreen(
          repository: _reviewRepository,
          imageRepository: _reviewImageRepository,
          userId: user.id,
          userName: user.fullName ?? 'CitiesWalk User',
        ),
      ),
    );
  }

  void _openMyBadges() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RewardsController(sl<RewardsRepository>())..load(),
          child: const AchievementLockerScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _journeyHistoryVersion.dispose();
    _tripToReplan.dispose();
    _destinationToPlan.dispose();
    _fitnessController.removeListener(_syncHomeFitnessDashboard);
    _fitnessController.dispose();
    _homeFitnessDashboard.dispose();
    _reviewSummaryVersion.dispose();
    _homeReviewSummaries.dispose();
    for (final provider in _reviewProviders.values) {
      provider.dispose();
    }
    super.dispose();
  }
}

class _EcoRouteEntryPage extends StatelessWidget {
  const _EcoRouteEntryPage({
    this.onJourneyCompleted,
    this.tripToReplan,
    this.destinationToPlan,
    this.reviewSummaryRefreshSignal,
    this.reviewSummaryService,
    this.onOpenReviews,
    this.onViewFitness,
  });

  final VoidCallback? onJourneyCompleted;
  final ValueListenable<EcoJourneyHistoryItem?>? tripToReplan;
  final ValueNotifier<EcoDestination?>? destinationToPlan;
  final ValueListenable<int>? reviewSummaryRefreshSignal;
  final DestinationReviewSummaryService? reviewSummaryService;
  final ValueChanged<EcoDestination>? onOpenReviews;
  final VoidCallback? onViewFitness;

  @override
  Widget build(BuildContext context) {
    final authController = sl<AuthController>();

    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final user = authController.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ChangeNotifierProvider(
          create: (_) => EcoRouteController(
            userId: user.id,
            repository: GoogleEcoRouteRepository(
              GoogleEcoRouteDataSource(sl<SupabaseClient>()),
            ),
            journeyRepository: SupabaseJourneyRepository(
              SupabaseJourneyDataSource(sl<SupabaseClient>()),
            ),
            locationService: const DeviceLocationDataSource(),
            reviewSummaryService: reviewSummaryService,
          ),
          child: EcoRoutePage(
            onJourneyCompleted: onJourneyCompleted,
            tripToReplan: tripToReplan,
            destinationToPlan: destinationToPlan,
            reviewSummaryRefreshSignal: reviewSummaryRefreshSignal,
            onOpenReviews: onOpenReviews,
            onViewFitness: onViewFitness,
          ),
        );
      },
    );
  }
}
