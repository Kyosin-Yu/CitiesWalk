import '../entities/completed_fitness_journey.dart';

abstract interface class FitnessRepository {
  Future<List<CompletedFitnessJourney>> fetchCompletedJourneys({
    required String userId,
  });
}
