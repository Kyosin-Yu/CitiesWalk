import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/point_transaction.dart';
import '../../services/rewards_service.dart';
import '../widgets/rewards_bottom_navigation.dart';

class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key, this.service = const RewardsService()});
  final RewardsService service;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins')),
      child: Scaffold(
        bottomNavigationBar: const RewardsBottomNavigation(),
        body: FutureBuilder<List<PointTransaction>>(
        future: service.fetchPointHistory(),
        builder: (BuildContext context, AsyncSnapshot<List<PointTransaction>> snapshot) {
          if (snapshot.hasError) return const Center(child: Text('We could not load your points history.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final transactions = snapshot.data!;
          final total = transactions.fold<int>(0, (sum, transaction) => sum + transaction.points);
          final carbon = transactions.fold<double>(0, (sum, transaction) => sum + transaction.carbonSavedKg);
          return CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(child: _HistoryHeader(total: total, journeys: transactions.length, carbon: carbon)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList(delegate: SliverChildListDelegate(<Widget>[
                Row(children: <Widget>[
                  const Text('Activity Log', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_month_outlined, size: 17),
                    label: const Text('This Month'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFE0E3E2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                if (transactions.isEmpty) const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: Text('No points have been earned this month yet.'))),
                ...transactions.map((transaction) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _TransactionCard(transaction: transaction))),
              ])),
            ),
          ]);
        },
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.total, required this.journeys, required this.carbon});
  final int total;
  final int journeys;
  final double carbon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: <Color>[Color(0xFF2E7D32), Color(0xFF176D23)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[IconButton(tooltip: 'Back', onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)), const SizedBox(width: 6), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('CITIESWALK', style: TextStyle(color: Color(0xFFBCE4BF), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)), Text('Points History', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))])]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withValues(alpha: 0.13), border: Border.all(color: Colors.white.withValues(alpha: 0.22))),
            child: Column(children: <Widget>[
              Row(children: <Widget>[
                _HeaderMetric(label: 'Total Earned', value: '+${_formatPoints(total)}', unit: 'pts'),
                _HeaderMetric(label: 'Journeys', value: '$journeys', unit: 'completed'),
                _HeaderMetric(label: 'CO₂ Saved', value: carbon.toStringAsFixed(1), unit: 'kg'),
              ]),
              const SizedBox(height: 14),
              Row(children: const <Widget>[Text('Monthly Goal', style: TextStyle(color: Color(0xFFDDF2DF), fontSize: 11)), Spacer(), Text('3,240 / 4,000 pts', style: TextStyle(color: Color(0xFFDDF2DF), fontSize: 11, fontWeight: FontWeight.w600))]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: 0.81, minHeight: 8, color: Color(0xFF53D071), backgroundColor: Colors.white24)),
            ]),
          ),
        ]),
      );
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: const TextStyle(color: Color(0xFFDDF2DF), fontSize: 10)), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)), Text(unit, style: const TextStyle(color: Color(0xFF9BE5A0), fontWeight: FontWeight.w600, fontSize: 10))]));
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});
  final PointTransaction transaction;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        CircleAvatar(radius: 23, backgroundColor: const Color(0xFFE1F3E3), child: Icon(_iconForTransaction(transaction.icon), color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Expanded(child: Text(transaction.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.15))), Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE3F4E5), border: Border.all(color: const Color(0xFFA8D9AC)), borderRadius: BorderRadius.circular(9)), child: Text('+${transaction.points} pts', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 7),
          Text('◷  ${_dateTimeLabel(transaction.completedAt)}  •  ${transaction.type == JourneyType.walk ? 'Walk' : 'Transit'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 9),
          Wrap(spacing: 6, runSpacing: 5, children: <Widget>[_MetricChip(label: '🌿 ${transaction.carbonSavedKg.toStringAsFixed(1)} kg CO₂', color: const Color(0xFFE8F5E9)), _MetricChip(label: '🔥 ${transaction.calories} kcal', color: const Color(0xFFFFF3E0)), _MetricChip(label: '📍 ${transaction.distanceKm.toStringAsFixed(1)} km', color: const Color(0xFFF4E9F8))]),
        ])),
      ]),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)), child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.w600)));
}

IconData _iconForTransaction(String icon) => switch (icon) { 'city' => Icons.location_city_rounded, 'accountBalance' => Icons.account_balance_rounded, 'storefront' => Icons.storefront_rounded, _ => Icons.eco_rounded };

String _formatPoints(int value) => value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => ',');

String _dateTimeLabel(DateTime date) {
  const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = date.hour == 0 ? 12 : date.hour > 12 ? date.hour - 12 : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
}
