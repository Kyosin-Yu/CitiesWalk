import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'achievement_locker_screen.dart';
import 'leaderboard_screen.dart';
import 'points_history_screen.dart';

/// A simple hub screen that provides navigation entry points into each
/// Rewards sub-screen.  Used as a temporary home while other features are
/// still under development.
class RewardsHubScreen extends StatelessWidget {
  const RewardsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF2E7D32), Color(0xFF176D23)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 48),
                // ── Branding ──
                const Text(
                  'CITIESWALK',
                  style: TextStyle(
                    color: Color(0xFFBCE4BF),
                    fontSize: 12,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rewards Centre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a section to explore',
                  style: TextStyle(color: Color(0xFFBCE4BF), fontSize: 14),
                ),
                const SizedBox(height: 48),

                // ── Navigation Cards ──
                _NavCard(
                  icon: Icons.leaderboard_rounded,
                  title: 'Leaderboard',
                  subtitle: 'See how you rank among eco-walkers',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _NavCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Achievement Locker',
                  subtitle: 'View and unlock eco-badges',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AchievementLockerScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _NavCard(
                  icon: Icons.history_rounded,
                  title: 'Points History',
                  subtitle: 'Track your earned points and journeys',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PointsHistoryScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widget
// ─────────────────────────────────────────────────────────────────────────────

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white24,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.25),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFBCE4BF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
