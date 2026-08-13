import 'eco_route.dart';

enum EcoJourneyStatus { preview, inProgress, completed }

class EcoJourney {
  const EcoJourney({
    this.id,
    required this.userId,
    required this.route,
    required this.status,
    required this.startedAt,
    this.endedAt,
  });

  final String? id;
  final String userId;
  final EcoRoute route;
  final EcoJourneyStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
}
