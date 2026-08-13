import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business_logic/entities/eco_route_segment.dart';

class RouteStepTile extends StatelessWidget {
  const RouteStepTile({super.key, required this.segment, required this.index});

  final EcoRouteSegment segment;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isTransit = segment.type == EcoRouteSegmentType.transit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isTransit
                        ? AppColors.primary
                        : AppColors.accent.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTransit
                        ? Icons.train_rounded
                        : Icons.directions_walk_rounded,
                    size: 18,
                    color: isTransit ? Colors.white : AppColors.primary,
                  ),
                ),
                if (index < 2)
                  Container(
                    width: 2,
                    height: 52,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: AppColors.accent.withValues(alpha: 0.55),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP ${index + 1}',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    segment.title,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.titleLarge,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    segment.detail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoPill(
                        icon: Icons.directions_walk_rounded,
                        label: '${segment.distanceKm.toStringAsFixed(1)} km',
                      ),
                      _InfoPill(
                        icon: Icons.schedule_rounded,
                        label: '${segment.durationMinutes} min',
                      ),
                      if (segment.platform != null)
                        _InfoPill(
                          icon: Icons.door_front_door_outlined,
                          label: segment.platform!,
                          emphasized: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: emphasized
            ? AppColors.accent.withValues(alpha: 0.22)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: emphasized ? AppColors.primary : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
