import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';

class TriageHistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TriageHistoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = data['summary'];
    final inputs = data['inputs'];
    final ai = data['ai_logic'];
    final outcome = data['outcome'];
    
    final int score = summary['score'];
    Color riskColor = AppColors.neonGreen;
    if (score >= 90) riskColor = AppColors.critical;
    else if (score >= 70) riskColor = AppColors.neonRed;
    else if (score >= 40) riskColor = AppColors.neonYellow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Oct 12, 10:30 AM", // Should be formatted from data['timestamp']
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: riskColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  summary['risk_level'].toString().toUpperCase(),
                  style: GoogleFonts.inter(
                    color: riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Condition
          Text(
            summary['condition'],
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // Inputs
          _buildsection("Voice Note", "\"${inputs['transcription']}\"", isItalic: true),
          const SizedBox(height: 8),
          _buildsection("Vitals", "Heart Rate: ${inputs['heart_rate']} BPM"),

          const SizedBox(height: 12),
          
          // AI Logic
          Row(
            children: [
              Text(
                "Triage Score: $score/100",
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (ai['history_flag'] != null) ...[
                const SizedBox(width: 12),
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neonYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "⚠️ ${ai['history_flag']}",
                    style: GoogleFonts.inter(color: AppColors.neonYellow, fontSize: 10),
                  ),
                ),
              ]
            ],
          ),

          const SizedBox(height: 12),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Assigned: ${outcome['facility']}",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
                Text(
                  "Wait: ${outcome['wait_time']} min",
                  style: GoogleFonts.inter(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildsection(String label, String value, {bool isItalic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 13,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
