import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/destination_review_summary.dart';
import '../../business_logic/entities/eco_destination.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.nearbyDistanceKm,
    required this.reviewSummary,
    required this.onTap,
  });

  final EcoDestination destination;
  final double nearbyDistanceKm;
  final DestinationReviewSummary reviewSummary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _categoryStyle(destination.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(style.icon, size: 32, color: style.color),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.category.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: style.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.titleLarge,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        destination.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me_outlined,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${nearbyDistanceKm.toStringAsFixed(1)} km away',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (reviewSummary.hasReviews) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59A00),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${reviewSummary.averageRating.toStringAsFixed(1)} '
                              '(${reviewSummary.reviewCount})',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _DestinationStyle _categoryStyle(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('park')) {
      return const _DestinationStyle(Icons.park_rounded, AppColors.primary);
    }
    if (normalized.contains('food')) {
      return const _DestinationStyle(
        Icons.restaurant_rounded,
        Color(0xFFF57C00),
      );
    }
    if (normalized.contains('mall')) {
      return const _DestinationStyle(
        Icons.local_mall_rounded,
        Color(0xFF7E57C2),
      );
    }
    if (normalized.contains('transit') || normalized.contains('station')) {
      return const _DestinationStyle(
        Icons.train_rounded,
        Color(0xFF1565C0),
      );
    }
    return const _DestinationStyle(
      Icons.account_balance_rounded,
      Color(0xFF5C6BC0),
    );
  }
}

class _DestinationStyle {
  const _DestinationStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}
