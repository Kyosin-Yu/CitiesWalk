import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/point_transaction.dart';
import '../../business_logic/providers/rewards_controller.dart';

const _monthlyPointsGoal = 4000;

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  DateTime? _selectedMonth;
  bool _showAllActivity = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        body: Builder(
          builder: (context) {
            final controller = context.watch<RewardsController>();
            if (controller.status == RewardsStatus.failure) {
              return const Center(
                child: Text('We could not load your points history.'),
              );
            }
            if (controller.status == RewardsStatus.initial ||
                controller.status == RewardsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = controller.pointHistory;
            final months = _availableMonths(transactions);
            final activeMonth =
                _selectedMonth ?? (months.isEmpty ? null : months.first);
            final visibleTransactions = _showAllActivity || activeMonth == null
                ? transactions
                : transactions
                      .where(
                        (item) => _isInMonth(item.completedAt, activeMonth),
                      )
                      .toList(growable: false);
            final total = visibleTransactions.fold<int>(
              0,
              (sum, item) => sum + item.points,
            );
            final carbon = visibleTransactions.fold<double>(
              0,
              (sum, item) => sum + item.carbonSavedKg,
            );
            final periodLabel = _showAllActivity
                ? 'All activity'
                : activeMonth == null
                ? 'This month'
                : _monthLabel(activeMonth);

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _HistoryHeader(
                    total: total,
                    journeys: visibleTransactions.length,
                    carbon: carbon,
                    periodLabel: periodLabel,
                    showsAllActivity: _showAllActivity,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      Row(
                        children: <Widget>[
                          const Text(
                            'Activity Log',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<int>(
                            tooltip: 'Filter activity period',
                            position: PopupMenuPosition.under,
                            onSelected: (index) => setState(() {
                              _showAllActivity = index == -1;
                              if (index >= 0) _selectedMonth = months[index];
                            }),
                            itemBuilder: (context) => <PopupMenuEntry<int>>[
                              CheckedPopupMenuItem<int>(
                                value: -1,
                                checked: _showAllActivity,
                                child: const Text('All activity'),
                              ),
                              if (months.isNotEmpty) const PopupMenuDivider(),
                              ...List<PopupMenuEntry<int>>.generate(
                                months.length,
                                (index) => CheckedPopupMenuItem<int>(
                                  value: index,
                                  checked:
                                      !_showAllActivity &&
                                      _isSameMonth(activeMonth, months[index]),
                                  child: Text(_monthLabel(months[index])),
                                ),
                              ),
                            ],
                            child: _PeriodButton(label: periodLabel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (visibleTransactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(
                            child: Text(
                              'No points have been earned in this period yet.',
                            ),
                          ),
                        ),
                      ...visibleTransactions.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransactionCard(transaction: item),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.total,
    required this.journeys,
    required this.carbon,
    required this.periodLabel,
    required this.showsAllActivity,
  });

  final int total;
  final int journeys;
  final double carbon;
  final String periodLabel;
  final bool showsAllActivity;

  @override
  Widget build(BuildContext context) {
    final progress = (total / _monthlyPointsGoal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF2E7D32), Color(0xFF176D23)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'CITIESWALK',
                      style: TextStyle(
                        color: Color(0xFFBCE4BF),
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Points History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _Metric(
                      label: 'Total Earned',
                      value: '+${_formatPoints(total)}',
                      unit: 'pts',
                    ),
                    _Metric(
                      label: 'Journeys',
                      value: '$journeys',
                      unit: 'completed',
                    ),
                    _Metric(
                      label: 'CO₂ Saved',
                      value: carbon.toStringAsFixed(1),
                      unit: 'kg',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Text(
                      showsAllActivity
                          ? 'All-time activity'
                          : 'Monthly Goal ($periodLabel)',
                      style: const TextStyle(
                        color: Color(0xFFDDF2DF),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      showsAllActivity
                          ? '$periodLabel records'
                          : '${_formatPoints(total)} / ${_formatPoints(_monthlyPointsGoal)} pts',
                      style: const TextStyle(
                        color: Color(0xFFDDF2DF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (!showsAllActivity) ...<Widget>[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: const Color(0xFF53D071),
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Color(0xFFDDF2DF), fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: Color(0xFF9BE5A0),
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE0E3E2)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.calendar_month_outlined,
          size: 17,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
      ],
    ),
  );
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});
  final PointTransaction transaction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 23,
          backgroundColor: const Color(0xFFE1F3E3),
          child: Icon(
            _iconForTransaction(transaction.icon),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      transaction.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                  _PointsChip(points: transaction.points),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${_dateTimeLabel(transaction.completedAt)}  •  ${transaction.type == JourneyType.walk ? 'Walk' : 'Transit'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: <Widget>[
                  _Chip(
                    label:
                        '🌿 ${transaction.carbonSavedKg.toStringAsFixed(1)} kg CO₂',
                    color: const Color(0xFFE8F5E9),
                  ),
                  _Chip(
                    label: '🔥 ${transaction.calories} kcal',
                    color: const Color(0xFFFFF3E0),
                  ),
                  _Chip(
                    label: '📍 ${transaction.distanceKm.toStringAsFixed(1)} km',
                    color: const Color(0xFFF4E9F8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.points});
  final int points;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F4E5),
      border: Border.all(color: const Color(0xFFA8D9AC)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      '+$points pts',
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

List<DateTime> _availableMonths(List<PointTransaction> transactions) {
  final months = <String, DateTime>{};
  for (final transaction in transactions) {
    final month = DateTime(
      transaction.completedAt.year,
      transaction.completedAt.month,
    );
    months.putIfAbsent('${month.year}-${month.month}', () => month);
  }
  final result = months.values.toList(growable: false);
  result.sort((first, second) => second.compareTo(first));
  return result;
}

bool _isInMonth(DateTime date, DateTime month) =>
    date.year == month.year && date.month == month.month;
bool _isSameMonth(DateTime? first, DateTime second) =>
    first != null && _isInMonth(first, second);

IconData _iconForTransaction(String icon) => switch (icon) {
  'city' => Icons.location_city_rounded,
  'accountBalance' => Icons.account_balance_rounded,
  'storefront' => Icons.storefront_rounded,
  _ => Icons.eco_rounded,
};

String _formatPoints(int value) {
  final sign = value < 0 ? '-' : '';
  final digits = value.abs().toString();
  final buffer = StringBuffer(sign);
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index).remainder(3) == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _monthLabel(DateTime month) {
  const names = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${names[month.month - 1]} ${month.year}';
}

String _dateTimeLabel(DateTime date) {
  const names = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  return '${names[date.month - 1]} ${date.day}, ${date.year} • $hour:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
}
