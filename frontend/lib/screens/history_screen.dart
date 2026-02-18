import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/triage_history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> historyData = [
      {
        "visit_id": "V-1023",
        "timestamp": "2023-10-12T10:30:00Z",
        "summary": { "condition": "Potential Cardiac Arrhythmia", "risk_level": "High", "score": 85 },
        "inputs": { 
          "transcription": "I felt a sudden sharp pain in my chest while jogging.", 
          "symptoms": ["Chest Pain", "Shortness of Breath"], 
          "heart_rate": 115 
        },
        "ai_logic": { "history_flag": "Hypertension", "override_triggered": false },
        "outcome": { "facility": "General Hospital", "wait_time": 15 }
      },
      {
        "visit_id": "V-0988",
        "timestamp": "2023-09-28T08:15:00Z",
        "summary": { "condition": "Mild Dehydration", "risk_level": "Low", "score": 30 },
        "inputs": { 
          "transcription": "Feeling dizzy after working in the sun.", 
          "symptoms": ["Dizziness", "Thirst"], 
          "heart_rate": 90 
        },
        "ai_logic": { "history_flag": null, "override_triggered": false },
        "outcome": { "facility": "Home Care", "wait_time": 0 }
      }
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Triage History",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    return TriageHistoryCard(data: historyData[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
