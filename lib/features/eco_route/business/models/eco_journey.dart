import 'eco_route.dart';

/// Local journey state only. Database status values remain pending team approval.
enum EcoJourneyStatus { preview, inProgress, completed }

class EcoJourney {
  const EcoJourney({
    required this.userId,
    required this.route,
    required this.status,
    required this.startedAt,
  });

  final String userId;
  final EcoRoute route;
  final EcoJourneyStatus status;
  final DateTime? startedAt;
}
