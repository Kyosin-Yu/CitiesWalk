enum FitnessMetricSource {
  recorded('Recorded'),
  estimated('Estimated'),
  mixed('Mixed'),
  unavailable('Not recorded');

  const FitnessMetricSource(this.label);

  final String label;
}

class CompletedFitnessJourney {
  const CompletedFitnessJourney({
    required this.id,
    required this.walkingDistanceMeters,
    required this.estimatedCalories,
    required this.estimatedCarbonSavedKg,
    required this.startedAt,
    required this.completedAt,
    this.stepCount = 0,
    this.countsAsCompletedRoute = true,
    this.originName,
    this.destinationName,
    this.originLatitude,
    this.originLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.distanceSource = FitnessMetricSource.estimated,
    this.caloriesSource = FitnessMetricSource.estimated,
    this.carbonSource = FitnessMetricSource.estimated,
    this.stepsSource = FitnessMetricSource.unavailable,
  });

  final String id;
  final int walkingDistanceMeters;
  final int estimatedCalories;
  final double estimatedCarbonSavedKg;
  final DateTime? startedAt;
  final DateTime completedAt;
  final int stepCount;
  final bool countsAsCompletedRoute;
  final String? originName;
  final String? destinationName;
  final double? originLatitude;
  final double? originLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final FitnessMetricSource distanceSource;
  final FitnessMetricSource caloriesSource;
  final FitnessMetricSource carbonSource;
  final FitnessMetricSource stepsSource;

  bool get hasRouteCoordinates =>
      originLatitude != null &&
      originLongitude != null &&
      destinationLatitude != null &&
      destinationLongitude != null;

  String get routeLabel {
    final origin = originName?.trim();
    final destination = destinationName?.trim();
    if (origin != null &&
        origin.isNotEmpty &&
        destination != null &&
        destination.isNotEmpty) {
      return '$origin → $destination';
    }
    if (destination != null && destination.isNotEmpty) return destination;
    if (origin != null && origin.isNotEmpty) return origin;
    return 'Eco Route activity';
  }

  FitnessMetricSource get overallSource {
    final sources = {distanceSource, caloriesSource, carbonSource};
    if (sources.length == 1) return sources.single;
    return FitnessMetricSource.mixed;
  }
}
