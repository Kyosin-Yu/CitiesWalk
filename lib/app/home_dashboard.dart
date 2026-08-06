import 'package:flutter/material.dart';

import 'theme/app_colors.dart';

/// App-level dashboard that routes users to feature modules through AppShell.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CitiesWalk'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Explore Kuala Lumpur sustainably',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Plan a journey that combines walking and public transport.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _RouteHero(onPlanRoute: () => onNavigate(1)),
          const SizedBox(height: 24),
          Text(
            'Today’s eco impact',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const _ImpactCard(),
          const SizedBox(height: 24),
          Text(
            'Continue your journey',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _QuickActions(onNavigate: onNavigate),
          const SizedBox(height: 24),
          Text(
            'Recommended for you',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _Recommendations(onNavigate: onNavigate),
          const SizedBox(height: 24),
          const _ExploreTip(),
        ],
      ),
    );
  }
}

class _RouteHero extends StatelessWidget {
  const _RouteHero({required this.onPlanRoute});

  final VoidCallback onPlanRoute;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          const Positioned.fill(
            child: _DestinationImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&w=1400&q=85',
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF123D18).withValues(alpha: 0.94),
                    AppColors.primary.withValues(alpha: 0.70),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 20),
                Text(
                  'Where do you want to go?',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find walking and rail routes with a lower environmental impact.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: onPlanRoute,
                  icon: const Icon(Icons.route_rounded),
                  label: const Text('Plan an eco route'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Row(
          children: const [
            Expanded(
              child: _ImpactMetric(
                icon: Icons.directions_walk_rounded,
                value: '0 km',
                label: 'Walked',
              ),
            ),
            _MetricDivider(),
            Expanded(
              child: _ImpactMetric(
                icon: Icons.local_fire_department_outlined,
                value: '0 kcal',
                label: 'Burned',
              ),
            ),
            _MetricDivider(),
            Expanded(
              child: _ImpactMetric(
                icon: Icons.eco_outlined,
                value: '0 kg',
                label: 'CO₂ saved',
              ),
            ),
          ],
        ),
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: VerticalDivider(color: Color(0xFFE0E0E0)),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickAction(
          icon: Icons.explore_outlined,
          label: 'Explore',
          onTap: () => onNavigate(1),
        ),
        _QuickAction(
          icon: Icons.directions_walk_outlined,
          label: 'Fitness',
          onTap: () => onNavigate(2),
        ),
        _QuickAction(
          icon: Icons.star_outline_rounded,
          label: 'Rewards',
          onTap: () => onNavigate(3),
        ),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 10),
                Text(label, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  const _Recommendations({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  static const _items = [
    _Recommendation(
      title: 'KLCC Park',
      category: 'Park · Walk + rail',
      imageUrl:
          'https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=900&q=85',
    ),
    _Recommendation(
      title: 'Central Market',
      category: 'Culture · Walk + rail',
      imageUrl:
          'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=900&q=85',
    ),
    _Recommendation(
      title: 'Perdana Botanical Garden',
      category: 'Nature · Walk + rail',
      imageUrl:
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=900&q=85',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final recommendation = _items[index];
          return _RecommendationCard(
            recommendation: recommendation,
            onTap: () => onNavigate(1),
          );
        },
      ),
    );
  }
}

class _Recommendation {
  const _Recommendation({
    required this.title,
    required this.category,
    required this.imageUrl,
  });

  final String title;
  final String category;
  final String imageUrl;
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
  });

  final _Recommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 244,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _DestinationImage(imageUrl: recommendation.imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xD9212121)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      recommendation.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.category,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationImage extends StatelessWidget {
  const _DestinationImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const ColoredBox(
          color: Color(0xFF46734A),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.primary,
        child: Center(
          child: Icon(Icons.landscape_outlined, color: Colors.white, size: 42),
        ),
      ),
    );
  }
}

class _ExploreTip extends StatelessWidget {
  const _ExploreTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: choose the Explore tab to plan a walking and rail route from your current location.',
            ),
          ),
        ],
      ),
    );
  }
}
