import 'package:flutter/foundation.dart';
import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import '../features/eco_route/business_logic/repositories/journey_history_repository.dart';
import 'theme/app_colors.dart';

class RecentTrips extends StatelessWidget {
  const RecentTrips({
    super.key,
    required this.userId,
    required this.repository,
    required this.refreshSignal,
    required this.onPlanAgain,
  });

  final String userId;
  final JourneyHistoryRepository repository;
  final ValueListenable<int> refreshSignal;
  final ValueChanged<EcoJourneyHistoryItem> onPlanAgain;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: refreshSignal,
    builder: (context, _, _) => FutureBuilder<List<EcoJourneyHistoryItem>>(
      future: repository.fetchCompletedJourneys(userId: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 108,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const _HistoryNotice(
            icon: Icons.cloud_off_rounded,
            message: 'Your trip history is unavailable right now.',
          );
        }
        final trips = snapshot.data ?? const [];
        if (trips.isEmpty) {
          return const _HistoryNotice(
            icon: Icons.route_outlined,
            message: 'Finish or end an eco journey to see it here.',
          );
        }
        return Column(
          children: [
            for (final trip in trips) ...[
              _TripHistoryCard(
                trip: trip,
                onPlanAgain: () => onPlanAgain(trip),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    ),
  );
}

class _TripHistoryCard extends StatelessWidget {
  const _TripHistoryCard({required this.trip, required this.onPlanAgain});

  final EcoJourneyHistoryItem trip;
  final VoidCallback onPlanAgain;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 146),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F4E7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        trip.destinationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.isCompleted ? 'Completed' : 'Ended early',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: trip.isCompleted
                            ? AppColors.primary
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  trip.destinationCategory ?? 'Eco journey',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${trip.durationMinutes} min · ${(trip.walkingDistanceMeters / 1000).toStringAsFixed(1)} km walked · ${trip.stepCount} steps',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.estimatedCalories} kcal · ${trip.estimatedCarbonSavedKg.toStringAsFixed(2)} kg CO₂ saved',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onPlanAgain,
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('Plan again'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _HistoryNotice extends StatelessWidget {
  const _HistoryNotice({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
