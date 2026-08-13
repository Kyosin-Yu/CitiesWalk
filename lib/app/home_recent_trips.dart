import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/eco_route/business_logic/entities/eco_journey_history_item.dart';
import '../features/eco_route/business_logic/repositories/journey_history_repository.dart';
import 'theme/app_colors.dart';

class RecentTrips extends StatelessWidget {
  const RecentTrips({
    super.key,
    required this.userId,
    required this.repository,
    required this.onPlanAgain,
  });

  final String userId;
  final JourneyHistoryRepository repository;
  final VoidCallback onPlanAgain;

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<EcoJourneyHistoryItem>>(
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
              message: 'Finish an eco journey to see it here.',
            );
          }
          return Column(
            children: [
              for (final trip in trips) ...[
                _TripHistoryCard(trip: trip, onPlanAgain: onPlanAgain),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      );
}

class _TripHistoryCard extends StatelessWidget {
  const _TripHistoryCard({required this.trip, required this.onPlanAgain});

  final EcoJourneyHistoryItem trip;
  final VoidCallback onPlanAgain;

  @override
  Widget build(BuildContext context) => Container(
    height: 128,
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
        SizedBox(
          width: 108,
          height: double.infinity,
          child: Image.network(
            _imageFor(trip.destinationName),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: AppColors.primary,
              child: Icon(Icons.landscape_rounded, color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.destinationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  trip.destinationCategory ?? 'Eco journey',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${trip.durationMinutes} min · ${(trip.walkingDistanceMeters / 1000).toStringAsFixed(1)} km walked',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
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

  String _imageFor(String name) {
    final lowerCaseName = name.toLowerCase();
    if (lowerCaseName.contains('batu')) {
      return 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&w=700&q=80';
    }
    if (lowerCaseName.contains('market') || lowerCaseName.contains('pasar')) {
      return 'https://image.mom-mom.net/eyJrZXkiOiJwbGFjZXMvNjczNmE3ZDYyN2Y3Mjg1NDEwMjE5YTRhLkpQRyIsImVkaXRzIjp7InJlc2l6ZSI6eyJ3aWR0aCI6MTA4MCwid2l0aG91dEVubGFyZ2VtZW50Ijp0cnVlfX19';
    }
    return 'https://images.trvl-media.com/place/6152226/e4914450-59a7-4d6c-ab5f-d4a70bbcfe80.jpg';
  }
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
