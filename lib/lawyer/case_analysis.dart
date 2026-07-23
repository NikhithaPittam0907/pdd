import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseAnalysisScreen extends StatelessWidget {
  const CaseAnalysisScreen({super.key});

  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEAF0FF),
            child: Icon(icon, color: const Color(0xFF0B132B)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B132B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget insightCard(String title, String desc, String percent, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.12),
            child: Text(
              percent,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B132B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget topTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0B132B)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B132B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0B132B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.gavel, color: Color(0xFF0B132B)),
                  const SizedBox(width: 10),
                  Text(
                    "LexisAI",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.analytics, color: Color(0xFF0B132B)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Case Analysis",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "AI-powered legal insights to evaluate performance, win probability and progress.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        topTag(Icons.bar_chart, "Analytics"),
                        topTag(Icons.psychology, "AI Insights"),
                        topTag(Icons.trending_up, "Growth"),
                      ],
                    ),

                    const SizedBox(height: 24),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: [
                        statCard("Total Cases", "28", Icons.folder),
                        statCard("Won Cases", "19", Icons.emoji_events),
                        statCard("Pending", "6", Icons.schedule),
                        statCard("Success Rate", "68%", Icons.trending_up),
                      ],
                    ),

                    const SizedBox(height: 24),

                    insightCard(
                      "Property Dispute",
                      "Strong documentation and witness support improve outcome probability.",
                      "82%",
                      Colors.green,
                    ),

                    insightCard(
                      "Corporate Fraud",
                      "Needs additional evidence collection before next hearing.",
                      "64%",
                      Colors.orange,
                    ),

                    insightCard(
                      "Family Settlement",
                      "High chance of mutual settlement through mediation.",
                      "91%",
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
