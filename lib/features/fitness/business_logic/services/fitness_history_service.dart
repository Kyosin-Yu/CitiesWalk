import '../entities/completed_fitness_journey.dart';
import '../entities/fitness_history.dart';

class FitnessHistoryService {
  const FitnessHistoryService();

  List<DateTime> availableDates(List<CompletedFitnessJourney> journeys) {
    final dates = journeys
        .map((journey) => _dateOnly(journey.completedAt))
        .toSet();
    return dates.toList()..sort();
  }

  bool hasActivityOnDate(List<DateTime> availableDates, DateTime candidate) =>
      availableDates.contains(_dateOnly(candidate));

  FitnessHistorySummary build({
    required List<CompletedFitnessJourney> journeys,
    required FitnessHistoryPeriod period,
    required DateTime anchorDate,
  }) {
    final anchor = _dateOnly(anchorDate);
    final range = _rangeFor(period, anchor);
    final selected =
        journeys.where((journey) {
          final completedAt = journey.completedAt.toLocal();
          return !completedAt.isBefore(range.$1) &&
              completedAt.isBefore(range.$2);
        }).toList()..sort(
          (first, second) => second.completedAt.compareTo(first.completedAt),
        );

    final buckets = _buildBuckets(selected, period);
    final activeDays = selected
        .map((journey) => _dateOnly(journey.completedAt))
        .toSet()
        .length;

    return FitnessHistorySummary(
      period: period,
      anchorDate: anchor,
      rangeStart: range.$1,
      rangeEnd: range.$2.subtract(const Duration(microseconds: 1)),
      journeyCount: selected.length,
      completedRouteCount: selected
          .where((journey) => journey.countsAsCompletedRoute)
          .length,
      activeDays: activeDays,
      steps: _steps(selected),
      walkingDistanceKm: _distanceKm(selected),
      caloriesKcal: _calories(selected),
      carbonSavedKg: _carbon(selected),
      buckets: buckets,
      journeys: List.unmodifiable(selected),
    );
  }

  (DateTime, DateTime) _rangeFor(
    FitnessHistoryPeriod period,
    DateTime anchor,
  ) => switch (period) {
    FitnessHistoryPeriod.daily => (anchor, anchor.add(const Duration(days: 1))),
    FitnessHistoryPeriod.weekly => (
      anchor.subtract(Duration(days: anchor.weekday - DateTime.monday)),
      anchor
          .subtract(Duration(days: anchor.weekday - DateTime.monday))
          .add(const Duration(days: 7)),
    ),
    FitnessHistoryPeriod.monthly => (
      DateTime(anchor.year, anchor.month),
      DateTime(anchor.year, anchor.month + 1),
    ),
    FitnessHistoryPeriod.yearly => (
      DateTime(anchor.year),
      DateTime(anchor.year + 1),
    ),
  };

  List<FitnessHistoryBucket> _buildBuckets(
    List<CompletedFitnessJourney> journeys,
    FitnessHistoryPeriod period,
  ) {
    if (period == FitnessHistoryPeriod.daily) {
      return [
        for (final journey in journeys) _bucket(journey.completedAt, [journey]),
      ];
    }

    final grouped = <DateTime, List<CompletedFitnessJourney>>{};
    for (final journey in journeys) {
      final completedAt = journey.completedAt.toLocal();
      final key = period == FitnessHistoryPeriod.yearly
          ? DateTime(completedAt.year, completedAt.month)
          : _dateOnly(completedAt);
      grouped.putIfAbsent(key, () => []).add(journey);
    }

    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final key in keys) _bucket(key, grouped[key]!)];
  }

  FitnessHistoryBucket _bucket(
    DateTime startedAt,
    List<CompletedFitnessJourney> journeys,
  ) => FitnessHistoryBucket(
    startedAt: startedAt,
    journeyCount: journeys.length,
    completedRouteCount: journeys
        .where((journey) => journey.countsAsCompletedRoute)
        .length,
    steps: _steps(journeys),
    walkingDistanceKm: _distanceKm(journeys),
    caloriesKcal: _calories(journeys),
    carbonSavedKg: _carbon(journeys),
  );

  int _steps(Iterable<CompletedFitnessJourney> journeys) =>
      journeys.fold(0, (sum, journey) => sum + journey.stepCount);

  double _distanceKm(Iterable<CompletedFitnessJourney> journeys) =>
      journeys.fold<int>(
        0,
        (sum, journey) => sum + journey.walkingDistanceMeters,
      ) /
      1000;

  int _calories(Iterable<CompletedFitnessJourney> journeys) =>
      journeys.fold(0, (sum, journey) => sum + journey.estimatedCalories);

  double _carbon(Iterable<CompletedFitnessJourney> journeys) =>
      journeys.fold(0, (sum, journey) => sum + journey.estimatedCarbonSavedKg);

  DateTime _dateOnly(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
