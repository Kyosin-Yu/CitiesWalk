import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/entities/fitness_dashboard.dart';

class WeeklyWalkingChart extends StatelessWidget {
  const WeeklyWalkingChart({
    super.key,
    required this.days,
    required this.totalKm,
  });

  final List<FitnessDaySummary> days;
  final double totalKm;

  @override
  Widget build(BuildContext context) {
    final values = days.map((day) => day.walkingDistanceKm).toList();
    final dates = days.map((day) => day.date).toList();
    final hasWalkingData = values.any((value) => value > 0);

    return _ChartCard(
      title: 'Walking Distance',
      subtitle: hasWalkingData
          ? '${totalKm.toStringAsFixed(2)} km recorded this week'
          : 'No walking recorded this week',
      child: SizedBox(
        width: double.infinity,
        height: 118,
        child: hasWalkingData
            ? CustomPaint(painter: _WalkingPainter(values, dates))
            : const _WalkingEmptyState(),
      ),
    );
  }
}

class _WalkingEmptyState extends StatelessWidget {
  const _WalkingEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.directions_walk_outlined, color: Color(0xFF9BBE9E)),
        SizedBox(height: 6),
        Text(
          'Start an eco journey to build your weekly walking chart.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Color(0xFF8C8C8C)),
        ),
      ],
    ),
  );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
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
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: const Color(0xFF8C8C8C),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _WalkingPainter extends CustomPainter {
  const _WalkingPainter(this.values, this.dates);
  final List<double> values;
  final List<DateTime> dates;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const top = 8.0;
    const bottom = 22.0;
    const left = 30.0;
    const right = 4.0;
    final chartHeight = size.height - top - bottom;
    final maxValue = math.max(.1, values.reduce(math.max));
    final chartWidth = size.width - left - right;
    final stepX = values.length == 1 ? 0.0 : chartWidth / (values.length - 1);
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF1EB)
      ..strokeWidth = 1;
    for (var index = 0; index < 3; index++) {
      final y = top + chartHeight * index / 2;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }
    final points = List.generate(values.length, (index) {
      final y = top + chartHeight * (1 - values[index] / maxValue);
      return Offset(left + index * stepX, y);
    });

    _drawVerticalLabels(canvas, maxValue, top, chartHeight);

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      line.lineTo(points[index].dx, points[index].dy);
    }
    final fill = Path.from(line)
      ..lineTo(points.last.dx, top + chartHeight)
      ..lineTo(points.first.dx, top + chartHeight)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x664CAF50), Color(0x004CAF50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xFF388E3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (final point in points) {
      canvas.drawCircle(point, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 2.3, Paint()..color = const Color(0xFF388E3C));
    }
    _drawLabels(canvas, size, left, stepX);
  }

  void _drawVerticalLabels(
    Canvas canvas,
    double maxValue,
    double top,
    double chartHeight,
  ) {
    for (var index = 0; index < 3; index++) {
      final value = maxValue * (1 - index / 2);
      final painter = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(value < 10 ? 1 : 0)} km',
          style: const TextStyle(fontSize: 7, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 28);
      final y = top + chartHeight * index / 2 - painter.height / 2;
      painter.paint(canvas, Offset(0, y.clamp(0, top + chartHeight)));
    }
  }

  void _drawLabels(Canvas canvas, Size size, double left, double stepX) {
    for (var index = 0; index < values.length; index++) {
      final date = dates[index];
      final painter = TextPainter(
        text: TextSpan(
          text:
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 7, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (left + index * stepX - painter.width / 2).clamp(
        left,
        size.width - painter.width,
      );
      painter.paint(canvas, Offset(x, size.height - painter.height));
    }
  }

  @override
  bool shouldRepaint(covariant _WalkingPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.dates != dates;
}
