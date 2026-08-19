import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/di/service_locator.dart';
import '../features/authentication/business_logic/providers/auth_controller.dart';
import '../features/authentication/presentation/pages/profile_page.dart';
import '../features/eco_route/business_logic/providers/eco_route_controller.dart';
import '../features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import '../features/eco_route/data/data_sources/device_location_data_source.dart';
import '../features/eco_route/data/data_sources/google_eco_route_data_source.dart';
import '../features/eco_route/data/repositories/google_eco_route_repository.dart';
import '../features/eco_route/data/repositories/supabase_journey_repository.dart';
import '../features/eco_route/data/data_sources/supabase_journey_data_source.dart';
import '../features/eco_route/presentation/pages/eco_route_page.dart';
import '../features/fitness/business_logic/providers/fitness_controller.dart';
import '../features/fitness/presentation/pages/fitness_page.dart';
import '../features/rewards/presentation/screens/rewards_hub_screen.dart';
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

  late final List<Widget> _pages = [
    HomeDashboard(
      userId: sl<AuthController>().currentUser!.id,
      journeyHistoryRepository: SupabaseJourneyRepository(
        SupabaseJourneyDataSource(sl<SupabaseClient>()),
      ),
      historyRefreshSignal: _journeyHistoryVersion,
      onNavigate: _selectDestination,
      onPlanAgain: _planSavedTripAgain,
    ),
    _EcoRouteEntryPage(
      onJourneyCompleted: _refreshJourneyHistory,
      tripToReplan: _tripToReplan,
    ),
    ChangeNotifierProvider(
      create: (_) => sl<FitnessController>()..loadDashboard(),
      child: const FitnessPage(),
    ),
    const RewardsHubScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshJourneyHistory() {
    _journeyHistoryVersion.value++;
  }

  void _planSavedTripAgain(EcoJourneyHistoryItem journey) {
    _tripToReplan.value = journey;
    _selectDestination(1);
  }

  @override
  void dispose() {
    _journeyHistoryVersion.dispose();
    _tripToReplan.dispose();
    super.dispose();
  }
}

class _EcoRouteEntryPage extends StatelessWidget {
  const _EcoRouteEntryPage({this.onJourneyCompleted, this.tripToReplan});

  final VoidCallback? onJourneyCompleted;
  final ValueListenable<EcoJourneyHistoryItem?>? tripToReplan;

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
          ),
          child: EcoRoutePage(
            onJourneyCompleted: onJourneyCompleted,
            tripToReplan: tripToReplan,
          ),
        );
      },
    );
  }
}
