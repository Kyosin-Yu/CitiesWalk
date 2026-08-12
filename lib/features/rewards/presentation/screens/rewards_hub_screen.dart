import 'package:flutter/material.dart';

import 'leaderboard_screen.dart';

/// Backwards-compatible entry point for the Rewards tab and `/rewards` route.
///
/// The original temporary selection screen has intentionally been removed.
/// AppShell renders this widget inside its body, while the named route renders
/// it as a standalone page. The leaderboard adapts its navigation accordingly.
class RewardsHubScreen extends StatelessWidget {
  const RewardsHubScreen({super.key, this.isEmbedded});

  final bool? isEmbedded;

  @override
  Widget build(BuildContext context) {
    final embedded = isEmbedded ?? Scaffold.maybeOf(context) != null;
    return LeaderboardScreen(isEmbedded: embedded);
  }
}
