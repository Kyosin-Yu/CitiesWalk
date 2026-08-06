enum EcoRouteSegmentType { walk, transit }

class EcoRouteStep {
  const EcoRouteStep({
    required this.instruction,
    required this.distanceKm,
    required this.durationMinutes,
  });

  final String instruction;
  final double distanceKm;
  final int durationMinutes;
}

class EcoRouteSegment {
  const EcoRouteSegment({
    required this.type,
    required this.title,
    required this.detail,
    required this.distanceKm,
    required this.durationMinutes,
    required this.steps,
    this.platform,
  });

  final EcoRouteSegmentType type;
  final String title;
  final String detail;
  final double distanceKm;
  final int durationMinutes;
  final String? platform;
  final List<EcoRouteStep> steps;
}
