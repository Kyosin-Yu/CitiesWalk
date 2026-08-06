import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentBadgesSection extends StatelessWidget {
  const RecentBadgesSection({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              'Recent Badges',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'See all',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 108,
        child: ListView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          children: const [
            _Badge('🌱', 'First\nWalker', Color(0xFF81C784)),
            _Badge('🔥', '7-Day\nStreak', Color(0xFFFFB74D)),
            _Badge('🌍', 'Earth\nSaver', Color(0xFF64B5F6)),
            _Badge('🚶', '50km Club', Color(0xFFCE93D8)),
          ],
        ),
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.emoji, this.label, this.border);
  final String emoji, label;
  final Color border;
  @override
  Widget build(BuildContext context) => Container(
    width: 84,
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border.withValues(alpha: .8)),
    ),
    child: Column(
      children: [
        Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: border.withValues(alpha: .16),
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 19)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: border.computeLuminance() < .55
                ? border
                : const Color(0xFF2E7D32),
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(width: 20, height: 2, color: border),
      ],
    ),
  );
}
