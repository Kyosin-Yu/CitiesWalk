import 'eco_destination.dart';
import 'eco_location.dart';
import 'eco_route_segment.dart';

class EcoRoute {
  const EcoRoute({
    required this.origin,
    required this.destination,
    required this.segments,
    required this.estimatedCalories,
    required this.estimatedCarbonSavedKg,
    this.isLiveRoute = false,
  });

  final EcoLocation origin;
  final EcoDestination destination;
  final List<EcoRouteSegment> segments;
  final int estimatedCalories;
  final double estimatedCarbonSavedKg;
  final bool isLiveRoute;

  double get totalDistanceKm =>
      segments.fold<double>(0, (total, segment) => total + segment.distanceKm);

  double get walkingDistanceKm => segments
      .where((segment) => segment.type == EcoRouteSegmentType.walk)
      .fold<double>(0, (total, segment) => total + segment.distanceKm);

  int get durationMinutes =>
      segments.fold(0, (total, segment) => total + segment.durationMinutes);

  bool get hasTransit =>
      segments.any((segment) => segment.type == EcoRouteSegmentType.transit);

  String? get recommendedPlatform {
    for (final segment in segments) {
      if (segment.platform != null) return segment.platform;
    }
    return null;
  }
}
