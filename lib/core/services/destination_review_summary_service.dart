import '../models/destination_review_summary.dart';

/// Read-only contract used by features that display destination ratings.
abstract interface class DestinationReviewSummaryService {
  Future<DestinationReviewSummary> getDestinationReviewSummary(
    String destinationId,
  );
}
