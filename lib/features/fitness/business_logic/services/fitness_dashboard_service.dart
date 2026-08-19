import '../entities/completed_fitness_journey.dart';
import '../entities/fitness_dashboard.dart';

class FitnessDashboardService {
  const FitnessDashboardService();

  FitnessDashboard build({
    required String userName,
    required List<CompletedFitnessJourney> journeys,
    DateTime? now,
  }) {
    final localNow = now ?? DateTime.now();
    final today = _dateOnly(localNow);
    final sevenDayStart = today.subtract(const Duration(days: 6));
    final previousSevenDayStart = sevenDayStart.subtract(
      const Duration(days: 7),
    );
    final monthStart = DateTime(today.year, today.month);

    final todayJourneys = journeys.where(
      (journey) => _dateOnly(journey.completedAt) == today,
    );
    final sevenDayJourneys = journeys.where((journey) {
      final date = _dateOnly(journey.completedAt);
      return !date.isBefore(sevenDayStart) && !date.isAfter(today);
    }).toList();
    final previousSevenDayJourneys = journeys.where((journey) {
      final date = _dateOnly(journey.completedAt);
      return !date.isBefore(previousSevenDayStart) &&
          date.isBefore(sevenDayStart);
    });
    final monthlyJourneys = journeys.where((journey) {
      final date = _dateOnly(journey.completedAt);
      return !date.isBefore(monthStart) && !date.isAfter(today);
    });

    final dailySummaries = List.generate(7, (index) {
      final date = sevenDayStart.add(Duration(days: index));
      final daily = journeys
          .where((journey) => _dateOnly(journey.completedAt) == date)
          .toList();
      return FitnessDaySummary(
        date: date,
        walkingDistanceKm: _distanceKm(daily),
        caloriesKcal: _calories(daily),
        carbonSavedKg: _carbon(daily),
        completedJourneys: daily.length,
      );
    });

    return FitnessDashboard(
      userName: userName,
      streakDays: _streakDays(journeys, today),
      stepsToday: null,
      walkingDistanceTodayKm: _distanceKm(todayJourneys),
      caloriesTodayKcal: _calories(todayJourneys),
      carbonSavedTodayKg: _carbon(todayJourneys),
      ecoPoints: null,
      weeklyWalkingDistanceKm: _distanceKm(sevenDayJourneys),
      previousWeekWalkingDistanceKm: _distanceKm(previousSevenDayJourneys),
      monthlyWalkingDistanceKm: _distanceKm(monthlyJourneys),
      weeklyCaloriesKcal: _calories(sevenDayJourneys),
      weeklyCarbonSavedKg: _carbon(sevenDayJourneys),
      monthlyCaloriesKcal: _calories(monthlyJourneys),
      monthlyCarbonSavedKg: _carbon(monthlyJourneys),
      completedJourneysThisWeek: sevenDayJourneys.length,
      totalCompletedJourneys: journeys.length,
      dailySummaries: dailySummaries,
    );
  }

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

  int _streakDays(List<CompletedFitnessJourney> journeys, DateTime today) {
    final activeDates = journeys
        .map((journey) => _dateOnly(journey.completedAt))
        .toSet();
    if (activeDates.isEmpty) return 0;

    var cursor = activeDates.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    if (!activeDates.contains(cursor)) return 0;

    var streak = 0;
    while (activeDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  DateTime _dateOnly(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
