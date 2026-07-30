import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key});
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.55, mainAxisSpacing: 10, crossAxisSpacing: 10,
        children: const [
          _MetricCard('Steps Today', '8,452', 'steps', '👟', Color(0xFF2E7D32), .72, Color(0xFFE7DCF8)),
          _MetricCard('Calories', '486', 'kcal', '🔥', Color(0xFFFF6D00), .58, Color(0xFFFFDDCF)),
          _MetricCard('CO₂ Saved', '12.6', 'kg', '🌿', Color(0xFF1565C0), .72, Color(0xFFD9EFFF)),
          _MetricCard('Eco Points', '2,340', 'pts', '⭐', Color(0xFFFF6D00), .63, Color(0xFFFFF3C6)),
        ],
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.unit, this.emoji, this.color, this.progress, this.iconColor);
  final String label, value, unit, emoji; final Color color, iconColor; final double progress;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF777777))), Container(width: 29, height: 29, alignment: Alignment.center, decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(9)), child: Text(emoji, style: const TextStyle(fontSize: 15)))]),
    const Spacer(), RichText(text: TextSpan(children: [TextSpan(text: value, style: GoogleFonts.poppins(color: color, fontSize: 18, fontWeight: FontWeight.w700)), TextSpan(text: ' $unit', style: GoogleFonts.poppins(color: const Color(0xFF9B9B9B), fontSize: 8))])), const SizedBox(height: 7),
    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 3, color: color.withValues(alpha: .55), backgroundColor: const Color(0xFFF0F0F0))),
  ]));
}
