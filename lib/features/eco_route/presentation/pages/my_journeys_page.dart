import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_journey_history_item.dart';
import '../../business_logic/repositories/journey_history_repository.dart';

class MyJourneysPage extends StatefulWidget {
  const MyJourneysPage({
    super.key,
    required this.userId,
    required this.repository,
  });

  final String userId;
  final JourneyHistoryRepository repository;

  @override
  State<MyJourneysPage> createState() => _MyJourneysPageState();
}

class _MyJourneysPageState extends State<MyJourneysPage> {
  late Future<List<EcoJourneyHistoryItem>> _journeysFuture;

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  void _loadJourneys() {
    _journeysFuture = widget.repository.fetchCompletedJourneys(
      userId: widget.userId,
    );
  }

  Future<void> _refresh() async {
    setState(_loadJourneys);
    await _journeysFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text(
          'My Journey',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<EcoJourneyHistoryItem>>(
        future: _journeysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: () {
                setState(_loadJourneys);
              },
            );
          }

          final journeys = snapshot.data ?? const [];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: journeys.isEmpty
                ? const _EmptyJourneyState()
                : _JourneyContent(journeys: journeys),
          );
        },
      ),
    );
  }
}

class _JourneyContent extends StatelessWidget {
  const _JourneyContent({required this.journeys});

  final List<EcoJourneyHistoryItem> journeys;

  @override
  Widget build(BuildContext context) {
    final totalJourneys = journeys.length;

    final totalSteps = journeys.fold<int>(
      0,
      (sum, journey) => sum + _estimateSteps(journey.walkingDistanceMeters),
    );

    final totalCarbonSaved = journeys.fold<double>(
      0,
      (sum, journey) => sum + journey.estimatedCarbonSavedKg,
    );

    final totalCalories = journeys.fold<int>(
      0,
      (sum, journey) => sum + journey.estimatedCalories,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
      children: [
        const Text(
          'Your eco-fitness stats',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),

        _SummaryCard(
          journeys: totalJourneys,
          steps: totalSteps,
          carbonSaved: totalCarbonSaved,
          calories: totalCalories,
        ),

        const SizedBox(height: 22),

        const Text(
          'Recent Journeys',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        for (final journey in journeys) ...[
          _JourneyCard(journey: journey),
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 12),

        _AllTimeStats(
          journeys: totalJourneys,
          steps: totalSteps,
          carbonSaved: totalCarbonSaved,
        ),
      ],
    );
  }

  static int _estimateSteps(int walkingDistanceMeters) {
    // Temporary estimate until Fitness provides actual step history.
    return (walkingDistanceMeters / 0.75).round();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.journeys,
    required this.steps,
    required this.carbonSaved,
    required this.calories,
  });

  final int journeys;
  final int steps;
  final double carbonSaved;
  final int calories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Journey Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.directions_walk_rounded,
                  value: _compactNumber(steps),
                  label: 'Steps',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.eco_outlined,
                  value: '${carbonSaved.toStringAsFixed(1)} kg',
                  label: 'CO₂ saved',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.local_fire_department_outlined,
                  value: '$calories',
                  label: 'kcal',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _compactNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return value.toString();
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.journey});

  final EcoJourneyHistoryItem journey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.near_me_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.destinationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_dateLabel(journey.completedAt)} · '
                  '${_estimateSteps(journey.walkingDistanceMeters)} steps',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${journey.estimatedCarbonSavedKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${journey.estimatedCalories} kcal',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static int _estimateSteps(int walkingDistanceMeters) {
    return (walkingDistanceMeters / 0.75).round();
  }

  static String _dateLabel(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]}';
  }
}

class _AllTimeStats extends StatelessWidget {
  const _AllTimeStats({
    required this.journeys,
    required this.steps,
    required this.carbonSaved,
  });

  final int journeys;
  final int steps;
  final double carbonSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All-Time Stats',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AllTimeMetric(
                  icon: Icons.near_me_outlined,
                  value: journeys.toString(),
                  label: 'Journeys',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AllTimeMetric(
                  icon: Icons.directions_walk_rounded,
                  value: _compactNumber(steps),
                  label: 'Total steps',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AllTimeMetric(
                  icon: Icons.eco_outlined,
                  value: '${carbonSaved.toStringAsFixed(1)} kg',
                  label: 'CO₂ saved',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _compactNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return value.toString();
  }
}

class _AllTimeMetric extends StatelessWidget {
  const _AllTimeMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EB),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyJourneyState extends StatelessWidget {
  const _EmptyJourneyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: const [
        SizedBox(height: 130),
        Icon(Icons.route_outlined, size: 64, color: AppColors.primary),
        SizedBox(height: 18),
        Text(
          'No journeys yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text(
          'Complete an eco journey and it will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load your journeys.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
