import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/fitness_goal.dart';
import '../../business_logic/services/fitness_goal_progress_service.dart';
import 'fitness_goal_dialog.dart';

typedef FitnessGoalProgressBuilder =
    FitnessGoalProgress Function(FitnessGoal goal);

class FitnessGoalsSection extends StatelessWidget {
  const FitnessGoalsSection({
    super.key,
    required this.goals,
    required this.progressFor,
    required this.onCreate,
    required this.onCancel,
    required this.isBusy,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.countFor,
    this.errorMessage,
  });

  final List<FitnessGoal> goals;
  final FitnessGoalProgressBuilder progressFor;
  final Future<bool> Function(FitnessGoalInput input) onCreate;
  final Future<bool> Function(FitnessGoal goal) onCancel;
  final bool isBusy;
  final FitnessGoalStatus selectedFilter;
  final ValueChanged<FitnessGoalStatus> onFilterChanged;
  final int Function(FitnessGoalStatus status) countFor;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Fitness Goals',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Goals lock after creation and reward completion points.',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Create fitness goal',
              onPressed: isBusy ? null : () => _createGoal(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _GoalError(message: errorMessage!),
        ],
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final status in FitnessGoalStatus.values) ...[
                ChoiceChip(
                  label: Text('${status.label} (${countFor(status)})'),
                  selected: selectedFilter == status,
                  onSelected: (_) => onFilterChanged(status),
                ),
                if (status != FitnessGoalStatus.values.last)
                  const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          _EmptyGoals(status: selectedFilter)
        else
          for (var index = 0; index < goals.length; index++) ...[
            _GoalCard(
              goal: goals[index],
              progress: progressFor(goals[index]),
              isBusy: isBusy,
              onCancel: () => _cancelGoal(context, goals[index]),
            ),
            if (index != goals.length - 1) const SizedBox(height: 10),
          ],
      ],
    ),
  );

  Future<void> _createGoal(BuildContext context) async {
    final input = await showDialog<FitnessGoalInput>(
      context: context,
      builder: (_) => const FitnessGoalDialog(),
    );
    if (input == null || !context.mounted) return;
    final saved = await onCreate(input);
    if (saved && context.mounted) {
      _showSuccess(context, 'Fitness goal created.');
    }
  }

  Future<void> _cancelGoal(BuildContext context, FitnessGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel fitness goal?'),
        content: Text(
          'This goal cannot be edited. Cancel your '
          '${goal.period.label.toLowerCase()} '
          '${goal.metric.label.toLowerCase()} goal and create a new one?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel goal'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final cancelled = await onCancel(goal);
    if (cancelled && context.mounted) {
      _showSuccess(context, 'Fitness goal cancelled.');
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.progress,
    required this.isBusy,
    required this.onCancel,
  });

  final FitnessGoal goal;
  final FitnessGoalProgress progress;
  final bool isBusy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final color = _metricColor(goal.metric);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: .14),
                  foregroundColor: color,
                  child: Icon(_metricIcon(goal.metric), size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${goal.period.label} ${goal.metric.label}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_formatValue(progress.currentValue)} / '
                        '${_formatValue(progress.targetValue)} ${goal.metric.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (goal.isActive)
                  IconButton(
                    tooltip: 'Cancel fitness goal',
                    onPressed: isBusy ? null : onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                  )
                else if (goal.isCompleted)
                  const Icon(Icons.verified_rounded, color: AppColors.primary)
                else
                  const Icon(
                    Icons.block_rounded,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            if (goal.isCancelled) ...[
              const SizedBox(height: 8),
              Text(
                'Goal cancelled. Create a new goal when you are ready.',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress.fraction,
                  backgroundColor: color.withValues(alpha: .12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                goal.isCompleted
                    ? 'Goal completed • +${goal.rewardPoints ?? 0} pts'
                    : '${progress.percentage}% completed',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _metricIcon(FitnessGoalMetric metric) => switch (metric) {
    FitnessGoalMetric.walkingDistance => Icons.directions_walk_rounded,
    FitnessGoalMetric.calories => Icons.local_fire_department_rounded,
    FitnessGoalMetric.carbonSaved => Icons.eco_rounded,
  };

  static Color _metricColor(FitnessGoalMetric metric) => switch (metric) {
    FitnessGoalMetric.walkingDistance => AppColors.primary,
    FitnessGoalMetric.calories => const Color(0xFFFF6D00),
    FitnessGoalMetric.carbonSaved => const Color(0xFF1565C0),
  };

  static String _formatValue(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.status});

  final FitnessGoalStatus status;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const Icon(Icons.flag_outlined, color: AppColors.primary, size: 30),
        const SizedBox(height: 8),
        Text(
          'No ${status.label.toLowerCase()} goals',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        Text(
          status == FitnessGoalStatus.active
              ? 'Tap + to create your first fitness goal.'
              : 'Your ${status.label.toLowerCase()} goals will appear here.',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _GoalError extends StatelessWidget {
  const _GoalError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}
