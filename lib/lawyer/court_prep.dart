import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourtPrepScreen extends StatelessWidget {
  const CourtPrepScreen({super.key});

  Widget prepCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(0xFF0B132B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Color(0xFF0B132B),
          ),
        ],
      ),
    );
  }

  Widget topTag(
      IconData icon,
      String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFEAF0FF),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                const Color(0xFF0B132B),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: const Color(
                  0xFF0B132B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(
                    Icons.gavel,
                    color:
                        Color(0xFF0B132B),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "LexisAI",
                    style:
                        GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                      color: const Color(
                          0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.account_balance,
                    color:
                        Color(0xFF0B132B),
                  ),
                ],
              ),
            ),

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                        20),
                child: Column(
                  children: [
                    Text(
                      "Court Preparation",
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            const Color(
                                0xFF0B132B),
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    Text(
                      "Prepare arguments, evidence, documents and hearing notes before court appearance.",
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors
                            .black54,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        topTag(
                            Icons.description,
                            "Documents"),
                        topTag(
                            Icons.gavel,
                            "Arguments"),
                        topTag(
                            Icons.event,
                            "Hearings"),
                      ],
                    ),

                    const SizedBox(
                        height: 24),

                    prepCard(
                      icon: Icons.fact_check,
                      title:
                          "Case Summary",
                      subtitle:
                          "Review facts, previous orders and timeline of events.",
                      color: Colors.blue,
                    ),

                    prepCard(
                      icon:
                          Icons.folder_copy,
                      title:
                          "Evidence Bundle",
                      subtitle:
                          "Organize evidence files, witness proof and exhibits.",
                      color: Colors.green,
                    ),

                    prepCard(
                      icon:
                          Icons.record_voice_over,
                      title:
                          "Arguments Notes",
                      subtitle:
                          "Prepare opening statements and counter points.",
                      color: Colors.orange,
                    ),

                    prepCard(
                      icon:
                          Icons.schedule,
                      title:
                          "Hearing Checklist",
                      subtitle:
                          "Track hearing date, judge notes and pending tasks.",
                      color: Colors.purple,
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