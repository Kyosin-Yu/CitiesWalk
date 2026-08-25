enum EcoNearbyDistance {
  oneKm(1),
  twoKm(2),
  fiveKm(5);

  const EcoNearbyDistance(this.kilometres);

  final double kilometres;

  /// The inner edge is exclusive so a place is offered in one distance band
  /// only: 0–1 km, >1–2 km, or >2–5 km.
  double get minimumKilometres => switch (this) {
    EcoNearbyDistance.oneKm => 0,
    EcoNearbyDistance.twoKm => 1,
    EcoNearbyDistance.fiveKm => 2,
  };

  String get label => switch (this) {
    EcoNearbyDistance.oneKm => 'Within 1 km',
    EcoNearbyDistance.twoKm => '1–2 km',
    EcoNearbyDistance.fiveKm => '2–5 km',
  };

  String get nearbyDescription => switch (this) {
    EcoNearbyDistance.oneKm => 'within 1 km',
    EcoNearbyDistance.twoKm => 'between 1 and 2 km',
    EcoNearbyDistance.fiveKm => 'between 2 and 5 km',
  };

  bool includes(double distanceKm) =>
      distanceKm > minimumKilometres && distanceKm <= kilometres;
}
