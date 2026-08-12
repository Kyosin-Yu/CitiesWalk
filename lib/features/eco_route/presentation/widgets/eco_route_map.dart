import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_location.dart';
import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/entities/eco_route_segment.dart';

/// A reliable local route visual for the prototype.
///
/// This deliberately uses only Flutter painting and the repository's sample
/// points. It keeps the route screen usable on web without map tiles, external
/// routing calls, or browser pointer-event issues.
class EcoRouteMap extends StatelessWidget {
  const EcoRouteMap({super.key, required this.route});

  final EcoRoute route;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sample route preview to ${route.destination.name}',
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2EA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _RouteMapPainter(route)),
              ),
              const Positioned(
                left: 12,
                top: 12,
                child: _MapPill(
                  icon: Icons.route_rounded,
                  label: 'Sample route map',
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: _MapPill(
                  icon: Icons.schedule_rounded,
                  label: '${route.durationMinutes} min',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  const _RouteMapPainter(this.route);

  final EcoRoute route;

  @override
  void paint(Canvas canvas, Size size) {
    _drawStreetGrid(canvas, size);
    final transform = _MapTransform(_allLocations(route), size);

    for (final segment in route.segments) {
      if (segment.mapPath.length < 2) continue;
      final path = Path();
      for (var index = 0; index < segment.mapPath.length; index++) {
        final point = transform.pointFor(segment.mapPath[index]);
        if (index == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      final color = segment.type == EcoRouteSegmentType.transit
          ? AppColors.primary
          : AppColors.secondary;
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..strokeWidth = segment.type == EcoRouteSegmentType.transit ? 10 : 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = segment.type == EcoRouteSegmentType.transit ? 6 : 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    _drawMarker(
      canvas,
      transform.pointFor(route.origin),
      AppColors.primary,
      'A',
    );
    _drawMarker(
      canvas,
      transform.pointFor(route.destination.location),
      AppColors.error,
      'B',
    );

    for (final segment in route.segments.where(
      (segment) => segment.type == EcoRouteSegmentType.transit,
    )) {
      for (final stop
          in segment.mapPath.skip(1).take(segment.mapPath.length - 2)) {
        _drawStop(canvas, transform.pointFor(stop));
      }
    }

    _drawLabel(
      canvas,
      'Start',
      transform.pointFor(route.origin) + const Offset(0, 24),
    );
    _drawLabel(
      canvas,
      route.destination.name,
      transform.pointFor(route.destination.location) + const Offset(0, 24),
    );
  }

  void _drawStreetGrid(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = const Color(0xFFD7E1D8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var index = 0; index < 8; index++) {
      final y = 34 + index * (size.height - 68) / 7;
      final curve = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * .48, y - 24, size.width, y + 8);
      canvas.drawPath(curve, streetPaint);
    }
    for (var index = 0; index < 6; index++) {
      final x = 24 + index * (size.width - 48) / 5;
      final curve = Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + 20, size.height * .52, x - 10, size.height);
      canvas.drawPath(curve, streetPaint);
    }
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .73),
      34,
      Paint()..color = const Color(0xFFCDE7CD),
    );
    canvas.drawCircle(
      Offset(size.width * .8, size.height * .22),
      27,
      Paint()..color = const Color(0xFFCDE7CD),
    );
  }

  void _drawMarker(Canvas canvas, Offset point, Color color, String letter) {
    canvas.drawCircle(point, 15, Paint()..color = Colors.white);
    canvas.drawCircle(point, 11, Paint()..color = color);
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      point - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawStop(Canvas canvas, Offset point) {
    canvas.drawCircle(point, 6, Paint()..color = Colors.white);
    canvas.drawCircle(point, 4, Paint()..color = AppColors.primary);
  }

  void _drawLabel(Canvas canvas, String text, Offset point) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 120);
    textPainter.paint(canvas, point - Offset(textPainter.width / 2, 0));
  }

  List<EcoLocation> _allLocations(EcoRoute value) => [
    value.origin,
    for (final segment in value.segments) ...segment.mapPath,
    value.destination.location,
  ];

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) =>
      oldDelegate.route != route;
}

class _MapTransform {
  _MapTransform(List<EcoLocation> locations, Size size)
    : _size = size,
      _minimumLatitude = locations
          .map((location) => location.latitude)
          .reduce((first, second) => first < second ? first : second),
      _maximumLatitude = locations
          .map((location) => location.latitude)
          .reduce((first, second) => first > second ? first : second),
      _minimumLongitude = locations
          .map((location) => location.longitude)
          .reduce((first, second) => first < second ? first : second),
      _maximumLongitude = locations
          .map((location) => location.longitude)
          .reduce((first, second) => first > second ? first : second);

  final Size _size;
  final double _minimumLatitude;
  final double _maximumLatitude;
  final double _minimumLongitude;
  final double _maximumLongitude;

  Offset pointFor(EcoLocation location) {
    final longitudeSpan = (_maximumLongitude - _minimumLongitude).abs();
    final latitudeSpan = (_maximumLatitude - _minimumLatitude).abs();
    final normalizedX = longitudeSpan == 0
        ? .5
        : (location.longitude - _minimumLongitude) / longitudeSpan;
    final normalizedY = latitudeSpan == 0
        ? .5
        : (location.latitude - _minimumLatitude) / latitudeSpan;
    return Offset(
      24 + normalizedX * (_size.width - 48),
      _size.height - 28 - normalizedY * (_size.height - 56),
    );
  }
}

class _MapPill extends StatelessWidget {
  const _MapPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
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
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
