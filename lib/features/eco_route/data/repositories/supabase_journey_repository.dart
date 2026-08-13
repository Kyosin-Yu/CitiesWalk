import '../../business_logic/entities/eco_route.dart';
import '../../business_logic/repositories/journey_repository.dart';
import '../../business_logic/repositories/journey_history_repository.dart';
import '../../business_logic/entities/eco_journey_history_item.dart';
import '../data_sources/supabase_journey_data_source.dart';

class SupabaseJourneyRepository
    implements JourneyRepository, JourneyHistoryRepository {
  SupabaseJourneyRepository(this._dataSource);

  final SupabaseJourneyDataSource _dataSource;

  @override
  Future<List<EcoJourneyHistoryItem>> fetchCompletedJourneys({
    required String userId,
  }) => _dataSource.fetchCompletedJourneys(userId: userId);

  @override
  Future<String> createStartedJourney({
    required String userId,
    required EcoRoute route,
    required DateTime startedAt,
  }) => _dataSource.createStartedJourney(
    userId: userId,
    route: route,
    startedAt: startedAt,
  );

  @override
  Future<void> completeJourney({
    required String journeyId,
    required DateTime endedAt,
  }) => _dataSource.completeJourney(journeyId: journeyId, endedAt: endedAt);
}
