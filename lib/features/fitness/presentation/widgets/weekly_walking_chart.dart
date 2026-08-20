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
  Widget build(BuildContext context) => _ChartCard(
    title: 'Walking Distance',
    subtitle: '${totalKm.toStringAsFixed(2)} km from completed routes',
    child: SizedBox(
      height: 110,
      child: CustomPaint(
        painter: _WalkingPainter(
          days.map((day) => day.walkingDistanceKm).toList(),
        ),
      ),
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
  const _WalkingPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const top = 8.0;
    const bottom = 22.0;
    final chartHeight = size.height - top - bottom;
    final maxValue = math.max(1.0, values.reduce(math.max));
    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final points = List.generate(values.length, (index) {
      final y = top + chartHeight * (1 - values[index] / maxValue);
      return Offset(index * stepX, y);
    });

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
    _drawLabels(canvas, size, stepX);
  }

  void _drawLabels(Canvas canvas, Size size, double stepX) {
    const labels = ['D-6', 'D-5', 'D-4', 'D-3', 'D-2', 'Yesterday', 'Today'];
    for (var index = 0; index < values.length; index++) {
      final painter = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: const TextStyle(fontSize: 7, color: Color(0xFF888888)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (index * stepX - painter.width / 2).clamp(
        0.0,
        size.width - painter.width,
      );
      painter.paint(canvas, Offset(x, size.height - painter.height));
    }
  }

  @override
  bool shouldRepaint(covariant _WalkingPainter oldDelegate) =>
      oldDelegate.values != values;
}
