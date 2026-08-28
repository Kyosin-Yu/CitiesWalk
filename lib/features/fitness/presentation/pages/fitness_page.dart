import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../authentication/business_logic/providers/auth_controller.dart';
import '../../business_logic/providers/fitness_controller.dart';
import '../widgets/carbon_savings_chart.dart';
import '../widgets/fitness_goals_section.dart';
import '../widgets/fitness_header.dart';
import '../widgets/health_connect_card.dart';
import '../widgets/metrics_grid.dart';
import '../widgets/recent_activity_section.dart';
import '../widgets/recent_badges_section.dart';
import '../widgets/weekly_insight_card.dart';
import '../widgets/weekly_walking_chart.dart';
import 'fitness_history_page.dart';

class FitnessPage extends StatelessWidget {
  const FitnessPage({super.key, this.onViewRewards});

  final VoidCallback? onViewRewards;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FitnessController>();
    final currentUser = context.watch<AuthController>().currentUser;
    final dashboard = controller.dashboard;

    if ((controller.status == FitnessStatus.initial ||
            controller.status == FitnessStatus.loading) &&
        dashboard == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (dashboard == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage ??
                        'Your completed routes are not available yet.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.loadDashboard,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FitnessHeader(
              userName: currentUser?.fullName?.trim().isNotEmpty == true
                  ? currentUser!.fullName!.trim()
                  : dashboard.userName,
              streakDays: dashboard.streakDays,
              profileImageUrl: currentUser?.profileImage,
              onHistoryTapped: () => _openHistory(context, controller),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  children: [
                    if (controller.errorMessage != null) ...[
                      _SyncWarning(message: controller.errorMessage!),
                      const SizedBox(height: 12),
                    ],
                    if (!dashboard.hasRecordedActivity) ...[
                      const _EmptyRouteBanner(),
                      const SizedBox(height: 12),
                    ],
                    MetricsGrid(dashboard: dashboard),
                    const SizedBox(height: 12),
                    const HealthConnectCard(),
                    const SizedBox(height: 12),
                    WeeklyWalkingChart(
                      days: dashboard.dailySummaries,
                      totalKm: dashboard.weeklyWalkingDistanceKm,
                    ),
                    const SizedBox(height: 12),
                    CarbonSavingsChart(
                      days: dashboard.dailySummaries,
                      totalKg: dashboard.weeklyCarbonSavedKg,
                    ),
                    const SizedBox(height: 12),
                    RecentActivitySection(
                      activities: controller.recentActivities,
                      onViewAll: () => _openHistory(context, controller),
                    ),
                    const SizedBox(height: 12),
                    FitnessGoalsSection(
                      goals: controller.visibleGoals,
                      progressFor: controller.progressFor,
                      onCreate: controller.createGoal,
                      onCancel: controller.cancelGoal,
                      isBusy: controller.isGoalMutationInProgress,
                      selectedFilter: controller.goalFilter,
                      onFilterChanged: controller.selectGoalFilter,
                      countFor: controller.goalCount,
                      errorMessage: controller.goalErrorMessage,
                    ),
                    const SizedBox(height: 12),
                    RecentBadgesSection(
                      badges: controller.recentBadges,
                      onSeeAll: onViewRewards,
                    ),
                    const SizedBox(height: 16),
                    WeeklyInsightCard(dashboard: dashboard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHistory(BuildContext context, FitnessController controller) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const FitnessHistoryPage(),
        ),
      ),
    );
  }
}

class _EmptyRouteBanner extends StatelessWidget {
  const _EmptyRouteBanner();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.directions_walk_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Complete an Eco Route to add real walking, calorie and CO₂ data here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SyncWarning extends StatelessWidget {
  const _SyncWarning({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.warning.withValues(alpha: .12),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
