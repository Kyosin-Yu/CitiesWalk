import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/leaderboard_entry.dart';

class PodiumWidget extends StatelessWidget {
  const PodiumWidget({super.key, required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();
    final first = entries.firstWhere((entry) => entry.rank == 1);
    final second = entries.firstWhere((entry) => entry.rank == 2);
    final third = entries.firstWhere((entry) => entry.rank == 3);

    return SizedBox(
      height: 212,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: _PodiumPlace(
              entry: second,
              height: 66,
              medalColor: const Color(0xFFC8D1D7),
            ),
          ),
          Expanded(
            child: _PodiumPlace(
              entry: first,
              height: 104,
              medalColor: const Color(0xFFFFD600),
              isWinner: true,
            ),
          ),
          Expanded(
            child: _PodiumPlace(
              entry: third,
              height: 50,
              medalColor: const Color(0xFFD2A679),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.entry,
    required this.height,
    required this.medalColor,
    this.isWinner = false,
  });

  final LeaderboardEntry entry;
  final double height;
  final Color medalColor;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CircleAvatar(
              radius: isWinner ? 28 : 25,
              backgroundColor: medalColor,
              child: CircleAvatar(
                radius: isWinner ? 24 : 21,
                backgroundColor: AppColors.accent.withValues(alpha: 0.35),
                child: Text(
                  entry.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -5,
              bottom: -3,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Text(
                  '${entry.rank}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${_formatPoints(entry.points)} pts',
          style: const TextStyle(
            color: Color(0xFFE1F4E2),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: height,
          width: double.infinity,
          alignment: const Alignment(0, -0.55),
          decoration: BoxDecoration(
            color: medalColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(
            '${entry.rank}',
            style: const TextStyle(fontSize: 22, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

String _formatPoints(int value) {
  final text = value.toString();
  return text.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => ',');
}
