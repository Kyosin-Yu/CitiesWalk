import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/fitness_cubit.dart';
import '../widgets/carbon_savings_chart.dart';
import '../widgets/fitness_goals_section.dart';
import '../widgets/fitness_header.dart';
import '../widgets/metrics_grid.dart';
import '../widgets/recent_badges_section.dart';
import '../widgets/weekly_insight_card.dart';
import '../widgets/weekly_walking_chart.dart';

class FitnessPage extends StatelessWidget {
  const FitnessPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => FitnessCubit(),
        child: const _FitnessView(),
      );
}

class _FitnessView extends StatelessWidget {
  const _FitnessView();

  static const _background = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const FitnessHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 104),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0),
                    MetricsGrid(),
                    SizedBox(height: 12),
                    WeeklyWalkingChart(),
                    SizedBox(height: 12),
                    CarbonSavingsChart(),
                    SizedBox(height: 12),
                    FitnessGoalsSection(),
                    SizedBox(height: 12),
                    RecentBadgesSection(),
                    SizedBox(height: 16),
                    WeeklyInsightCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _FitnessNavigation(),
    );
  }
}

class _FitnessNavigation extends StatelessWidget {
  const _FitnessNavigation();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.location_on_rounded, 'Explore'),
      (Icons.directions_walk_rounded, 'Fitness'),
      (Icons.emoji_events_rounded, 'Rewards'),
      (Icons.person_rounded, 'Profile'),
    ];
    return Container(
      height: 72,
      color: Colors.white.withValues(alpha: .94),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final active = item.$2 == 'Fitness';
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFE5F4E7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(item.$1, size: 21, color: active ? const Color(0xFF2E7D32) : const Color(0xFFADADAD)),
              ),
              const SizedBox(height: 2),
              Text(item.$2, style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? const Color(0xFF2E7D32) : const Color(0xFF8D8D8D))),
            ],
          );
        }).toList(),
      ),
    );
  }
}
