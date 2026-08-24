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
  Widget build(BuildContext context) {
    final values = days.map((day) => day.carbonSavedKg).toList();
    final dates = days.map((day) => day.date).toList();
    final hasCarbonData = values.any((value) => value > 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
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
            'Estimated Carbon Savings',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            hasCarbonData
                ? '${totalKg.toStringAsFixed(2)} kg CO₂ saved this week'
                : 'No carbon savings recorded this week',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: const Color(0xFF8C8C8C),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 104,
            child: hasCarbonData
                ? CustomPaint(painter: _CarbonPainter(values, dates))
                : const _CarbonEmptyState(),
          ),
        ],
      ),
    );
  }
}

class _CarbonEmptyState extends StatelessWidget {
  const _CarbonEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.eco_outlined, color: Color(0xFF9BBE9E)),
        SizedBox(height: 6),
        Text(
          'Choose rail and walking routes to see savings here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Color(0xFF8C8C8C)),
        ),
      ],
    ),
  );
}

class _CarbonPainter extends CustomPainter {
  const _CarbonPainter(this.values, this.dates);
  final List<double> values;
  final List<DateTime> dates;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const bottom = 18.0;
    const left = 30.0;
    const right = 4.0;
    final chartHeight = size.height - bottom - 4;
    final maxValue = math.max(.1, values.reduce(math.max));
    final chartWidth = size.width - left - right;
    final slot = chartWidth / values.length;
    final barWidth = math.min(22.0, slot * .55);
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF1EB)
      ..strokeWidth = 1;
    for (var index = 0; index < 3; index++) {
      final y = 4 + chartHeight * index / 2;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }
    _drawVerticalLabels(canvas, maxValue, chartHeight);

    for (var index = 0; index < values.length; index++) {
      final height = values[index] == 0
          ? 2.0
          : chartHeight * values[index] / maxValue;
      final x = left + index * slot + (slot - barWidth) / 2;
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
      final date = dates[index];
      final label =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
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
          left + index * slot + (slot - text.width) / 2,
          size.height - text.height,
        ),
      );
    }
  }

  void _drawVerticalLabels(Canvas canvas, double maxValue, double chartHeight) {
    for (var index = 0; index < 3; index++) {
      final value = maxValue * (1 - index / 2);
      final painter = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(value < 10 ? 1 : 0)} kg',
          style: const TextStyle(fontSize: 7, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 28);
      final y = 4 + chartHeight * index / 2 - painter.height / 2;
      painter.paint(canvas, Offset(0, y.clamp(0, chartHeight)));
    }
  }

  @override
  bool shouldRepaint(covariant _CarbonPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.dates != dates;
}
