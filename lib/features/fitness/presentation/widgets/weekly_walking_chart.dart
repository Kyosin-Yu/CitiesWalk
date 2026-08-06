import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyWalkingChart extends StatelessWidget {
  const WeeklyWalkingChart({super.key});
  @override
  Widget build(BuildContext context) => _ChartCard(
    title: 'Weekly Walking Distance',
    subtitle: 'Total: 41.8 km this week',
    badge: '132%',
    child: const SizedBox(
      height: 93,
      child: CustomPaint(painter: _WalkingPainter()),
    ),
  );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.child,
  });
  final String title, subtitle, badge;
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
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: const Color(0xFF8C8C8C),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F4E7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                badge,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        child,
      ],
    ),
  );
}

class _WalkingPainter extends CustomPainter {
  const _WalkingPainter();
  @override
  void paint(Canvas canvas, Size s) {
    final points = [
      Offset(8, 56),
      Offset(50, 39),
      Offset(92, 51),
      Offset(134, 29),
      Offset(176, 39),
      Offset(218, 19),
      Offset(260, 37),
    ];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      line.cubicTo(a.dx + 18, a.dy, b.dx - 18, b.dy, b.dx, b.dy);
    }
    final fill = Path.from(line)
      ..lineTo(points.last.dx, 76)
      ..lineTo(points.first.dx, 76)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x884CAF50), Color(0x004CAF50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & s),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = const Color(0xFF388E3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (final p in points) {
      canvas.drawCircle(p, 3.3, Paint()..color = Colors.white);
      canvas.drawCircle(p, 2.2, Paint()..color = const Color(0xFF388E3C));
    }
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var i = 0; i < labels.length; i++) {
      _text(
        canvas,
        labels[i],
        points[i].dx,
        89,
        i == 6 ? const Color(0xFF2E7D32) : const Color(0xFF888888),
      );
    }
    _text(
      canvas,
      '8.2 km',
      260,
      26,
      Colors.white,
      background: const Color(0xFF2E7D32),
    );
  }

  void _text(
    Canvas c,
    String text,
    double x,
    double y,
    Color color, {
    Color? background,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (background != null) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: p.width + 8,
            height: p.height + 5,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = background,
      );
    }
    p.paint(c, Offset(x - p.width / 2, y - p.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
