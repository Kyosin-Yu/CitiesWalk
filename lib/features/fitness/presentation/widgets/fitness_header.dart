import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class FitnessHeader extends StatelessWidget {
  const FitnessHeader({
    super.key,
    required this.userName,
    required this.streakDays,
    required this.onHistoryTapped,
    this.profileImageUrl,
  });
  final String userName;
  final int streakDays;
  final String? profileImageUrl;
  final VoidCallback onHistoryTapped;

  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: Stack(
      children: [
        Positioned(right: -34, top: -66, child: _ring(156)),
        Positioned(right: 22, top: -34, child: _ring(100)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8F5E9),
              backgroundImage:
                  profileImageUrl != null && profileImageUrl!.trim().isNotEmpty
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl == null || profileImageUrl!.trim().isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      size: 26,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    userName.trim().isEmpty ? 'CitiesWalk User' : userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$streakDays-day streak',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Open Fitness history',
              onPressed: onHistoryTapped,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .14),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.calendar_month_rounded),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _ring(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
  );
}
