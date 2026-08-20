import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FitnessHeader extends StatelessWidget {
  const FitnessHeader({
    super.key,
    required this.userName,
    required this.streakDays,
    required this.notificationsEnabled,
    required this.onNotificationsTapped,
  });
  final String userName;
  final int streakDays;
  final bool notificationsEnabled;
  final VoidCallback onNotificationsTapped;

  @override
  Widget build(BuildContext context) => Container(
    height: 118,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    decoration: const BoxDecoration(
      color: Color(0xFF2E7D32),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF66BB6A),
            border: Border.all(color: const Color(0xFFBDE5BF), width: 2),
          ),
          child: Text(
            userName.trim().isEmpty ? '?' : userName.trim().characters.first,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
              ),
              Text(
                userName.trim().isEmpty ? 'CitiesWalk User' : userName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$streakDays-day streak',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: notificationsEnabled
              ? 'Disable notifications'
              : 'Enable notifications',
          onPressed: onNotificationsTapped,
          icon: Icon(
            notificationsEnabled
                ? Icons.notifications_rounded
                : Icons.notifications_off_rounded,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
