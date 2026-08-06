import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/service_locator.dart';
import '../features/authentication/presentation/controllers/auth_controller.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/eco_route/presentation/pages/eco_route_module.dart';
import '../features/fitness/cubit/fitness_cubit.dart';
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

  late final List<Widget> _pages = [
    HomeDashboard(onNavigate: _selectDestination),
    const _EcoRouteEntryPage(),
    BlocProvider(create: (_) => FitnessCubit(), child: const FitnessPage()),
    const RewardsHubScreen(),
    const _ProfilePage(),
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
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final authController = sl<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListenableBuilder(
        listenable: authController,
        builder: (context, _) {
          final user = authController.currentUser;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 42,
                    child: Icon(Icons.person, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'CitiesWalk User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(user?.email ?? ''),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () async {
                      await authController.signOut();

                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EcoRouteEntryPage extends StatelessWidget {
  const _EcoRouteEntryPage();

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

        return EcoRouteModule(userId: user.id);
      },
    );
  }
}
