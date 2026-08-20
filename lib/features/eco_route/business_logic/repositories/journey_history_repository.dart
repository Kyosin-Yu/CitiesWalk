import '../entities/eco_journey_history_item.dart';

abstract interface class JourneyHistoryRepository {
  /// Returns saved outcomes, including completed journeys and journeys ended
  /// early. Consumers must use [EcoJourneyHistoryItem.isCompleted] before
  /// counting an item in completion-based metrics.
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  });
}
