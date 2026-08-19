import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/entities/fitness_dashboard.dart';

class CarbonSavingsChart extends StatelessWidget {
  const CarbonSavingsChart({
    super.key,
    required this.days,
    required this.totalKg,
  });

  final List<FitnessDaySummary> days;
  final double totalKg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Carbon Savings',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          '${totalKg.toStringAsFixed(2)} kg CO₂ from completed routes',
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: const Color(0xFF8C8C8C),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: CustomPaint(
            painter: _CarbonPainter(
              days.map((day) => day.carbonSavedKg).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CarbonPainter extends CustomPainter {
  const _CarbonPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const bottom = 18.0;
    final chartHeight = size.height - bottom - 4;
    final maxValue = math.max(1.0, values.reduce(math.max));
    final slot = size.width / values.length;
    final barWidth = math.min(22.0, slot * .55);

    for (var index = 0; index < values.length; index++) {
      final height = values[index] == 0
          ? 2.0
          : chartHeight * values[index] / maxValue;
      final x = index * slot + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartHeight - height + 4, barWidth, height),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = index == values.length - 1
              ? const Color(0xFF2E7D32)
              : const Color(0xFF81C784),
      );
      final label = index == values.length - 1 ? 'Today' : 'D-${6 - index}';
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 7, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        Offset(
          index * slot + (slot - text.width) / 2,
          size.height - text.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarbonPainter oldDelegate) =>
      oldDelegate.values != values;
}
