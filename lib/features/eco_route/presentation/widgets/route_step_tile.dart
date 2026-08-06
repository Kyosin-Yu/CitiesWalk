import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../business/models/eco_route_segment.dart';

class RouteStepTile extends StatelessWidget {
  const RouteStepTile({super.key, required this.segment, required this.index});

  final EcoRouteSegment segment;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isTransit = segment.type == EcoRouteSegmentType.transit;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent.withValues(alpha: 0.25),
              foregroundColor: AppColors.primary,
              child: Icon(
                isTransit ? Icons.train_rounded : Icons.directions_walk_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${segment.title}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    segment.detail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text('${segment.distanceKm.toStringAsFixed(1)} km'),
                      Text('${segment.durationMinutes} min'),
                      if (segment.platform != null)
                        Text(
                          segment.platform!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
