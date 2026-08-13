import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/fitness_controller.dart';
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
  Widget build(BuildContext context) {
    final controller = context.watch<FitnessController>();
    if (controller.status == FitnessStatus.initial ||
        controller.status == FitnessStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (controller.status == FitnessStatus.failure) {
      return Scaffold(
        body: Center(
          child: Text(
            controller.errorMessage ?? 'Unable to load fitness data.',
          ),
        ),
      );
    }
    final dashboard = controller.dashboard!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FitnessHeader(
              userName: dashboard.userName,
              streakDays: dashboard.streakDays,
              notificationsEnabled: controller.notificationsEnabled,
              onNotificationsTapped: controller.toggleNotifications,
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
    );
  }
}
