import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/completed_fitness_journey.dart';
import '../../business_logic/entities/fitness_history.dart';
import '../../business_logic/providers/fitness_controller.dart';
import '../widgets/fitness_history_calendar.dart';
import '../widgets/fitness_history_overview.dart';
import 'fitness_route_detail_page.dart';

class FitnessHistoryPage extends StatelessWidget {
  const FitnessHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FitnessController>();
    final selectedDate = controller.selectedHistoryDate;
    final firstDate = controller.firstHistoryDate;
    final lastDate = controller.lastHistoryDate;
    final summary = controller.historySummary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Fitness History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _PeriodSelector(
              selected: controller.historyPeriod,
              onSelected: controller.selectHistoryPeriod,
            ),
            const SizedBox(height: 16),
            if (selectedDate == null ||
                firstDate == null ||
                lastDate == null ||
                summary == null)
              const _EmptyHistory()
            else ...[
              FitnessHistoryCalendar(
                selectedDate: selectedDate,
                firstDate: firstDate,
                lastDate: lastDate,
                isSelectable: controller.isHistoryDateSelectable,
                onDateSelected: controller.selectHistoryDate,
              ),
              const SizedBox(height: 16),
              FitnessHistoryOverview(
                summary: summary,
                onViewRoute: (journey) =>
                    _openRoute(context, controller, journey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openRoute(
    BuildContext context,
    FitnessController controller,
    CompletedFitnessJourney journey,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: FitnessRouteDetailPage(journey: journey),
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onSelected});

  final FitnessHistoryPeriod selected;
  final ValueChanged<FitnessHistoryPeriod> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SegmentedButton<FitnessHistoryPeriod>(
      showSelectedIcon: false,
      segments: [
        for (final period in FitnessHistoryPeriod.values)
          ButtonSegment(value: period, label: Text(period.label)),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.single),
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 64),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: .18),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No Fitness history yet',
          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete or record an Eco Route to add activity to your calendar.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
