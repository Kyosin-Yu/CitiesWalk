import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_destination.dart';
import '../../business_logic/entities/eco_location.dart';

/// Local sample map for nearby-place discovery. It has no external tiles or
/// network calls, so it renders reliably in Edge and on low-memory devices.
class NearbyPlacesMap extends StatelessWidget {
  const NearbyPlacesMap({
    super.key,
    required this.origin,
    required this.destinations,
  });

  final EcoLocation origin;
  final List<EcoDestination> destinations;

  @override
  Widget build(BuildContext context) => Container(
    height: 225,
    decoration: BoxDecoration(
      color: const Color(0xFFEAF2EA),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _NearbyMapPainter(origin, destinations.take(4).toList()),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _Pill(icon: Icons.my_location_rounded, label: origin.label),
          ),
          const Positioned(
            right: 12,
            bottom: 12,
            child: _Pill(
              icon: Icons.explore_rounded,
              label: 'Sample nearby map',
            ),
          ),
        ],
      ),
    ),
  );
}

class _NearbyMapPainter extends CustomPainter {
  const _NearbyMapPainter(this.origin, this.destinations);

  final EcoLocation origin;
  final List<EcoDestination> destinations;

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = const Color(0xFFD7E1D8)
      ..strokeWidth = 2;
    for (var index = 0; index < 6; index++) {
      final y = 26 + index * 34.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 14), road);
    }
    for (var index = 0; index < 7; index++) {
      final x = 16 + index * (size.width - 32) / 6;
      canvas.drawLine(Offset(x, 0), Offset(x - 18, size.height), road);
    }
    canvas.drawCircle(
      Offset(size.width * .2, size.height * .72),
      28,
      Paint()..color = const Color(0xFFCDE7CD),
    );
    canvas.drawCircle(
      Offset(size.width * .75, size.height * .26),
      23,
      Paint()..color = const Color(0xFFCDE7CD),
    );

    final originPoint = Offset(size.width * .5, size.height * .54);
    _dot(canvas, originPoint, AppColors.primary, radius: 12);
    for (var index = 0; index < destinations.length; index++) {
      final point = Offset(
        size.width * (.18 + (index % 2) * .62),
        size.height * (.30 + (index ~/ 2) * .46),
      );
      _dot(canvas, point, AppColors.error, radius: 9);
    }
  }

  void _dot(
    Canvas canvas,
    Offset point,
    Color color, {
    required double radius,
  }) {
    canvas.drawCircle(point, radius + 3, Paint()..color = Colors.white);
    canvas.drawCircle(point, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NearbyMapPainter oldDelegate) => false;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 190),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}
