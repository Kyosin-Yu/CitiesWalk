import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class RewardsBottomNavigation extends StatelessWidget {
  const RewardsBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 3,
      height: 72,
      backgroundColor: AppColors.surface,
      indicatorColor: const Color(0xFFE3F4E5),
      onDestinationSelected: (int index) {
        if (index != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This module is coming soon.')),
          );
        }
      },
      destinations: const <NavigationDestination>[
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
          icon: Icon(Icons.location_on_outlined),
          selectedIcon: Icon(Icons.location_on_rounded),
          label: 'Journey',
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
    );
  }
}
