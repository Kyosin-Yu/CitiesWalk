import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../cubit/fitness_cubit.dart';
import '../../cubit/fitness_state.dart';

class FitnessHeader extends StatelessWidget {
  const FitnessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -60, child: _ring(146)),
          Positioned(right: 14, top: -27, child: _ring(94)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              const SizedBox(width: 12),
              Expanded(child: _greeting()),
              BlocBuilder<FitnessCubit, FitnessState>(
                builder: (context, state) {
                  return Row(
                    children: [
                    _headerButton(
                      state.notificationsEnabled
                          ? Icons.notifications_rounded
                          : Icons.notifications_off_rounded,
                      () => context.read<FitnessCubit>().toggleNotifications(),
                    ),
                    const SizedBox(width: 8),
                    _headerButton(Icons.priority_high_rounded, null),
                    ],
                  );
                },
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '12-day streak',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() => Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF66BB6A), border: Border.all(color: const Color(0xFFBDE5BF), width: 2)), child: Text('A', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)));
  Widget _greeting() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good Morning,', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)), Text('Alex Rahman', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)), const SizedBox(height: 10), Text('Tuesday, 29 July 2026', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10))]);
  Widget _headerButton(IconData icon, VoidCallback? onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 18)));
  Widget _ring(double size) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .08))));
}
