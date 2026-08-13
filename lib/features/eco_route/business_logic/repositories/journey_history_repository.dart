import '../entities/eco_journey_history_item.dart';

abstract interface class JourneyHistoryRepository {
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  });
}
