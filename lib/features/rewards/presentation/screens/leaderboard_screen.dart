import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/leaderboard_entry.dart';
import '../../services/rewards_service.dart';
import '../widgets/podium_widget.dart';
import 'achievement_locker_screen.dart';
import 'points_history_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    super.key,
    this.service = const RewardsService(),
    this.isEmbedded = false,
  });

  final RewardsService service;
  final bool isEmbedded;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final Future<List<LeaderboardEntry>> _leaderboardFuture;
  bool _showsAllRankings = false;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = widget.service.fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final rewardsTheme = Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
    );

    return Theme(
      data: rewardsTheme,
      child: FutureBuilder<List<LeaderboardEntry>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LeaderboardStatusScaffold(
              showBackButton: !widget.isEmbedded,
              child: const _ErrorState(
                message: 'We could not load the leaderboard.',
              ),
            );
          }
          if (!snapshot.hasData) {
            return _LeaderboardStatusScaffold(
              showBackButton: !widget.isEmbedded,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'CitiesWalk',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          }

          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return _LeaderboardStatusScaffold(
              showBackButton: !widget.isEmbedded,
              child: const _EmptyState(),
            );
          }
          final currentUser = entries.firstWhere(
            (entry) => entry.isCurrentUser,
            orElse: () => entries.first,
          );
          final rankedEntries = entries
              .where((entry) => entry.rank > 3)
              .toList(growable: false);
          final visibleRankedEntries = _showsAllRankings
              ? rankedEntries
              : rankedEntries.take(3).toList(growable: false);

          return Scaffold(
            bottomNavigationBar: _CurrentUserBar(entry: currentUser),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _LeaderboardHero(
                    entries: entries,
                    currentUser: currentUser,
                    showBackButton: !widget.isEmbedded,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      Row(
                        children: <Widget>[
                          const Text(
                            'Rankings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (rankedEntries.length > 3)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showsAllRankings = !_showsAllRankings;
                                });
                              },
                              child: Text(
                                _showsAllRankings
                                    ? 'Show less'
                                    : 'View all (${rankedEntries.length})',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...visibleRankedEntries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RankRow(entry: entry),
                            ),
                          ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardHero extends StatelessWidget {
  const _LeaderboardHero({
    required this.entries,
    required this.currentUser,
    required this.showBackButton,
  });

  final List<LeaderboardEntry> entries;
  final LeaderboardEntry currentUser;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF2E7D32), Color(0xFF176D23)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              if (showBackButton)
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'CitiesWalk',
                      style: TextStyle(
                        color: Color(0xFFD9F0DB),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Achievements',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AchievementLockerScreen(),
                  ),
                ),
                icon: const Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Points history',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const PointsHistoryScreen(),
                  ),
                ),
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ScoreCard(entry: currentUser),
          const SizedBox(height: 18),
          PodiumWidget(entries: entries),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Your Score',
                  style: TextStyle(color: Color(0xFFE2F3E3), fontSize: 12),
                ),
                Text(
                  '${_formatPoints(entry.points)} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  '+120 pts this week',
                  style: TextStyle(
                    color: Color(0xFF9BE5A0),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF78C47C), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Your Rank',
                  style: TextStyle(color: Color(0xFFE2F3E3), fontSize: 8),
                ),
                Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isCurrent = entry.isCurrentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: AppColors.secondary, width: 1.5)
            : null,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.secondary : const Color(0xFFF1F2F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                color: isCurrent ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent.withValues(alpha: 0.3),
            child: Text(
              entry.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: _YouLabel(),
                      ),
                  ],
                ),
                Text(
                  entry.achievement,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatPoints(entry.points)}\npts',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentUserBar extends StatelessWidget {
  const _CurrentUserBar({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.rank}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF86CB8A),
            child: Text(
              entry.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  '168 pts to reach #3',
                  style: TextStyle(color: Color(0xFFD8F1DA), fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${_formatPoints(entry.points)}\npoints',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _YouLabel extends StatelessWidget {
  const _YouLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'YOU',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No rankings yet. Complete an eco-journey to get started!'),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _LeaderboardStatusScaffold extends StatelessWidget {
  const _LeaderboardStatusScaffold({
    required this.showBackButton,
    required this.child,
  });

  final bool showBackButton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBackButton
          ? AppBar(
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: const Text('Leaderboard'),
            )
          : null,
      body: child,
    );
  }
}

String _formatPoints(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}
