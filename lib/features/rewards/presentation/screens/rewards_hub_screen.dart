import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../business_logic/providers/rewards_controller.dart';
import '../../business_logic/repositories/rewards_repository.dart';
import 'leaderboard_screen.dart';

/// Backwards-compatible entry point for the Rewards tab and `/rewards` route.
///
/// The original temporary selection screen has intentionally been removed.
/// AppShell renders this widget inside its body, while the named route renders
/// it as a standalone page. The leaderboard adapts its navigation accordingly.
class RewardsHubScreen extends StatelessWidget {
  const RewardsHubScreen({super.key, this.isEmbedded, this.repository});

  final bool? isEmbedded;
  final RewardsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final embedded = isEmbedded ?? Scaffold.maybeOf(context) != null;
    return ChangeNotifierProvider<RewardsController>(
      create: (_) =>
          RewardsController(repository ?? sl<RewardsRepository>())..load(),
      child: LeaderboardScreen(isEmbedded: embedded),
    );
  }
}
