import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/badge_model.dart';
import '../../services/rewards_service.dart';
import '../widgets/badge_detail_modal.dart';
import '../widgets/badge_item_card.dart';

enum _BadgeFilter { all, unlocked, locked }

class AchievementLockerScreen extends StatefulWidget {
  const AchievementLockerScreen({
    super.key,
    this.service = const RewardsService(),
  });
  final RewardsService service;

  @override
  State<AchievementLockerScreen> createState() =>
      _AchievementLockerScreenState();
}

class _AchievementLockerScreenState extends State<AchievementLockerScreen> {
  _BadgeFilter _filter = _BadgeFilter.all;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: Scaffold(
        body: FutureBuilder<List<BadgeModel>>(
          future: widget.service.fetchBadges(),
          builder:
              (BuildContext context, AsyncSnapshot<List<BadgeModel>> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('We could not load your achievements.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final badges = snapshot.data!;
                final unlocked = badges
                    .where((badge) => badge.isUnlocked)
                    .length;
                final filtered = switch (_filter) {
                  _BadgeFilter.all => badges,
                  _BadgeFilter.unlocked =>
                    badges.where((badge) => badge.isUnlocked).toList(),
                  _BadgeFilter.locked =>
                    badges.where((badge) => !badge.isUnlocked).toList(),
                };
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _LockerHeader(
                        unlocked: unlocked,
                        total: badges.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        child: _FilterTabs(
                          selected: _filter,
                          allCount: badges.length,
                          unlockedCount: unlocked,
                          onSelected: (filter) =>
                              setState(() => _filter = filter),
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text('No badges in this filter yet.'),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.84,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            BuildContext context,
                            int index,
                          ) {
                            final badge = filtered[index];
                            return BadgeItemCard(
                              badge: badge,
                              onTap: () {
                                BadgeDetailModal.show(
                                  context,
                                  badge,
                                  onStartJourney: _showJourneyMessage,
                                );
                              },
                            );
                          }, childCount: filtered.length),
                        ),
                      ),
                  ],
                );
              },
        ),
      ),
    );
  }

  void _showJourneyMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eco-journey start will be connected to navigation.'),
      ),
    );
  }
}

class _LockerHeader extends StatelessWidget {
  const _LockerHeader({required this.unlocked, required this.total});
  final int unlocked;
  final int total;
  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 22),
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
                      'Achievement Locker',
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Badges Unlocked',
                            style: TextStyle(
                              color: Color(0xFFDDF2DF),
                              fontSize: 12,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: '$unlocked',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 27,
                                  ),
                                ),
                                TextSpan(
                                  text: ' of $total',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 7,
                            color: AppColors.secondary,
                            backgroundColor: Colors.white24,
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: const Color(0xFF5BDA95),
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Text(
                      '$unlocked earned',
                      style: const TextStyle(
                        color: Color(0xFFDDF2DF),
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${total - unlocked} remaining',
                      style: const TextStyle(
                        color: Color(0xFFDDF2DF),
                        fontSize: 11,
                      ),
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
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selected,
    required this.allCount,
    required this.unlockedCount,
    required this.onSelected,
  });
  final _BadgeFilter selected;
  final int allCount;
  final int unlockedCount;
  final ValueChanged<_BadgeFilter> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: <Widget>[
        _FilterTab(
          label: 'All ($allCount)',
          selected: selected == _BadgeFilter.all,
          onTap: () => onSelected(_BadgeFilter.all),
        ),
        const SizedBox(width: 8),
        _FilterTab(
          label: 'Unlocked ($unlockedCount)',
          selected: selected == _BadgeFilter.unlocked,
          onTap: () => onSelected(_BadgeFilter.unlocked),
        ),
        const SizedBox(width: 8),
        _FilterTab(
          label: 'Locked (${allCount - unlockedCount})',
          selected: selected == _BadgeFilter.locked,
          onTap: () => onSelected(_BadgeFilter.locked),
        ),
      ],
    ),
  );
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primary : Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: selected ? null : Border.all(color: const Color(0xFFE0E2E2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}
