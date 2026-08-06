import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FitnessGoalsSection extends StatelessWidget {
  const FitnessGoalsSection({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitness Goals',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _Goal(
                '84%',
                'Daily Goal',
                '8,452',
                '10,000 steps',
                Color(0xFF2E7D32),
                .84,
              ),
            ),
            Expanded(
              child: _Goal(
                '72%',
                'Weekly Goal',
                '41.8 km',
                '58 km goal',
                Color(0xFF1565C0),
                .72,
              ),
            ),
            Expanded(
              child: _Goal(
                '58%',
                'Monthly Goal',
                '148 km',
                '258 km goal',
                Color(0xFF6A1B9A),
                .58,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Goal extends StatelessWidget {
  const _Goal(
    this.percent,
    this.title,
    this.value,
    this.caption,
    this.color,
    this.progress,
  );
  final String percent, title, value, caption;
  final Color color;
  final double progress;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: 61,
        height: 61,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFF0F1F1),
              color: color,
              strokeCap: StrokeCap.round,
            ),
            Text(
              percent,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 7),
      Text(
        title,
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xFF888888)),
      ),
      Text(
        caption,
        style: GoogleFonts.poppins(fontSize: 7, color: const Color(0xFFAAAAAA)),
      ),
    ],
  );
}
