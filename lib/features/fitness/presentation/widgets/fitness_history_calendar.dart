import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class FitnessHistoryCalendar extends StatelessWidget {
  const FitnessHistoryCalendar({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.isSelectable,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool Function(DateTime date) isSelectable;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Activity calendar',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Recorded day',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        CalendarDatePicker(
          key: ValueKey(selectedDate),
          initialDate: selectedDate,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: DateTime.now(),
          selectableDayPredicate: isSelectable,
          onDateChanged: onDateSelected,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            'Dates without a saved Fitness record are disabled.',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
