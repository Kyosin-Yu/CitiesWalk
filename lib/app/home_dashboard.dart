import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/models/destination_review_summary.dart';
import '../features/eco_route/business_logic/repositories/journey_history_repository.dart';
import '../features/eco_route/business_logic/entities/eco_destination.dart';
import '../features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import '../features/eco_route/business_logic/entities/eco_location.dart';
import '../features/fitness/business_logic/entities/fitness_dashboard.dart';
import 'home_recent_trips.dart';

import 'theme/app_colors.dart';

/// App-level dashboard that routes users to feature modules through AppShell.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.userId,
    required this.journeyHistoryRepository,
    required this.historyRefreshSignal,
    required this.onRefresh,
    required this.onNavigate,
    required this.onPlanAgain,
    this.onPlanDestination,
    this.reviewSummaries,
    this.fitnessDashboard,
  });

  final String userId;
  final JourneyHistoryRepository journeyHistoryRepository;
  final ValueListenable<int> historyRefreshSignal;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onNavigate;
  final ValueChanged<EcoJourneyHistoryItem> onPlanAgain;
  final ValueChanged<EcoDestination>? onPlanDestination;
  final ValueListenable<Map<String, DestinationReviewSummary>>? reviewSummaries;
  final ValueListenable<FitnessDashboard?>? fitnessDashboard;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 112),
                children: [
                _WelcomeCard(onPlanRoute: () => onNavigate(1)),
                const SizedBox(height: 24),
                const _SectionTitle('Today’s eco impact'),
                const SizedBox(height: 10),
                _ImpactCard(fitnessDashboard: fitnessDashboard),
                const SizedBox(height: 24),
                const _SectionTitle('Continue your journey'),
                const SizedBox(height: 10),
                _QuickActions(onNavigate: onNavigate),
                const SizedBox(height: 24),
                const _SectionTitle('Popular city escapes'),
                const SizedBox(height: 10),
                _Recommendations(
                  onNavigate: onNavigate,
                  onPlanDestination: onPlanDestination,
                  reviewSummaries: reviewSummaries,
                ),
                const SizedBox(height: 24),
                const _ExploreTip(),
                const SizedBox(height: 24),
                const _SectionTitle('Your recent trips'),
                const SizedBox(height: 4),
                Text(
                  'Completed and early-ended journeys are saved for your next visit.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                RecentTrips(
                  userId: userId,
                  repository: journeyHistoryRepository,
                  refreshSignal: historyRefreshSignal,
                  onPlanAgain: onPlanAgain,
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: Stack(
      children: [
        Positioned(right: -34, top: -66, child: _ring(156)),
        Positioned(right: 22, top: -34, child: _ring(100)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    'CitiesWalk',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Explore Kuala Lumpur sustainably',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          child: Text(
            'Small steps. Cleaner city.',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onPlanRoute});

  final VoidCallback onPlanRoute;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFE5F4E7),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(Icons.route_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where will you explore?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Plan a rail-and-walk route with a lower impact.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 11),
              FilledButton.icon(
                onPressed: onPlanRoute,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                ),
                icon: const Icon(Icons.explore_rounded, size: 17),
                label: const Text('Plan eco route'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.value);

  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value,
    style: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({this.fitnessDashboard});

  final ValueListenable<FitnessDashboard?>? fitnessDashboard;

  @override
  Widget build(BuildContext context) {
    final dashboard = fitnessDashboard;
    if (dashboard == null) return const _ImpactCardContent();

    return ValueListenableBuilder<FitnessDashboard?>(
      valueListenable: dashboard,
      builder: (_, value, _) => _ImpactCardContent(dashboard: value),
    );
  }
}

class _ImpactCardContent extends StatelessWidget {
  const _ImpactCardContent({this.dashboard});

  final FitnessDashboard? dashboard;

  @override
  Widget build(BuildContext context) {
    final walkingDistance = dashboard?.walkingDistanceTodayKm ?? 0;
    final calories = dashboard?.caloriesTodayKcal ?? 0;
    final carbonSaved = dashboard?.carbonSavedTodayKg ?? 0;
    final steps = dashboard?.stepsToday ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ImpactMetric(
                  icon: Icons.directions_walk_rounded,
                  value: '${walkingDistance.toStringAsFixed(2)} km',
                  label: 'Walked',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _ImpactMetric(
                  icon: Icons.local_fire_department_outlined,
                  value: '$calories kcal',
                  label: 'Burned',
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _ImpactMetric(
                  icon: Icons.eco_outlined,
                  value: '${carbonSaved.toStringAsFixed(2)} kg',
                  label: 'CO₂ saved',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_walk_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$steps steps recorded today',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  const _ImpactMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppColors.primary),
      const SizedBox(height: 8),
      Text(
        value,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 48,
    child: VerticalDivider(color: Color(0xFFE4EAE5)),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _QuickAction(
          icon: Icons.explore_outlined,
          label: 'Explore',
          onTap: () => onNavigate(1),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _QuickAction(
          icon: Icons.directions_walk_outlined,
          label: 'Fitness',
          onTap: () => onNavigate(2),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _QuickAction(
          icon: Icons.star_outline_rounded,
          label: 'Rewards',
          onTap: () => onNavigate(3),
        ),
      ),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Recommendations extends StatelessWidget {
  const _Recommendations({
    required this.onNavigate,
    this.onPlanDestination,
    this.reviewSummaries,
  });

  final ValueChanged<int> onNavigate;
  final ValueChanged<EcoDestination>? onPlanDestination;
  final ValueListenable<Map<String, DestinationReviewSummary>>? reviewSummaries;

  static const _items = [
    _HomeRecommendation(
      destination: EcoDestination(
        id: 'klcc-park',
        name: 'KLCC Park',
        category: 'Park',
        description: 'A green city park beside the Petronas Twin Towers.',
        location: EcoLocation(
          latitude: 3.1586,
          longitude: 101.7133,
          label: 'KLCC Park',
        ),
      ),
      subtitle: 'Park · Walk + rail',
      icon: Icons.park_rounded,
    ),
    _HomeRecommendation(
      destination: EcoDestination(
        id: 'central-market',
        name: 'Central Market',
        category: 'Cultural landmark',
        description: 'A heritage market for Malaysian crafts and local food.',
        location: EcoLocation(
          latitude: 3.1454,
          longitude: 101.6953,
          label: 'Central Market',
        ),
      ),
      subtitle: 'Culture · Walk + rail',
      icon: Icons.museum_rounded,
    ),
    _HomeRecommendation(
      destination: EcoDestination(
        id: 'batu-caves',
        name: 'Batu Caves',
        category: 'Heritage landmark',
        description: 'A limestone hill with caves and Hindu temples.',
        location: EcoLocation(
          latitude: 3.2379,
          longitude: 101.684,
          label: 'Batu Caves',
        ),
      ),
      subtitle: 'Heritage · Rail + walk',
      icon: Icons.temple_hindu_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const imageUrls = [
      'https://images.trvl-media.com/place/6152226/e4914450-59a7-4d6c-ab5f-d4a70bbcfe80.jpg',
      'https://image.mom-mom.net/eyJrZXkiOiJwbGFjZXMvNjczNmE3ZDYyN2Y3Mjg1NDEwMjE5YTRhLkpQRyIsImVkaXRzIjp7InJlc2l6ZSI6eyJ3aWR0aCI6MTA4MCwid2l0aG91dEVubGFyZ2VtZW50Ijp0cnVlfX19',
      'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&w=900&q=85',
    ];

    final summaries = reviewSummaries;
    if (summaries == null) return _buildList(context, imageUrls, const {});
    return ValueListenableBuilder<Map<String, DestinationReviewSummary>>(
      valueListenable: summaries,
      builder: (context, value, _) => _buildList(context, imageUrls, value),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<String> imageUrls,
    Map<String, DestinationReviewSummary> summaries,
  ) => SizedBox(
    height: 148,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        final summary = summaries[item.destination.id];
        return InkWell(
          onTap: () {
            final planDestination = onPlanDestination;
            if (planDestination != null) {
              planDestination(item.destination);
            } else {
              onNavigate(1);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 210,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.primary,
                    child: Center(
                      child: Icon(item.icon, color: Colors.white, size: 38),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xDE123D18)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _ReviewsShortcutLabel(summary: summary),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.destination.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _HomeRecommendation {
  const _HomeRecommendation({
    required this.destination,
    required this.subtitle,
    required this.icon,
  });

  final EcoDestination destination;
  final String subtitle;
  final IconData icon;
}

class _ReviewsShortcutLabel extends StatelessWidget {
  const _ReviewsShortcutLabel({this.summary});

  final DestinationReviewSummary? summary;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59A00)),
          const SizedBox(width: 4),
          Text(
            summary?.hasReviews == true
                ? '${summary!.averageRating.toStringAsFixed(1)} · ${summary!.reviewCount} reviews'
                : 'New place',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExploreTip extends StatelessWidget {
  const _ExploreTip();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tip: use Explore to choose your GPS location or a custom starting point, then plan a rail-and-walk route.',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
