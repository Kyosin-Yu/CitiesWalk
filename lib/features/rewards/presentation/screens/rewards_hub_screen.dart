import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/rewards_controller.dart';
import '../../data/data_sources/rewards_mock_data_source.dart';
import '../../data/repositories/rewards_repository_impl.dart';
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
    return ChangeNotifierProvider<RewardsController>(
      create: (_) => RewardsController(
        const RewardsRepositoryImpl(RewardsMockDataSource()),
      )..load(),
      child: LeaderboardScreen(isEmbedded: embedded),
    );
  }
}
