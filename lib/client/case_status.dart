import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseStatusScreen extends StatelessWidget {
  const CaseStatusScreen({super.key});

  Widget topTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF0B132B),
          ),
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

  Widget progressStep(
    String title,
    String date,
    bool done,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: done
                  ? Colors.green
                  : Colors.grey.shade300,
              child: Icon(
                done
                    ? Icons.check
                    : Icons.circle,
                size: 14,
                color: done
                    ? Colors.white
                    : Colors.grey,
              ),
            ),
            Container(
              width: 2,
              height: 42,
              color:
                  Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
                    top: 2),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color: const Color(
                        0xFF0B132B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style:
                      GoogleFonts.inter(
                    fontSize: 12,
                    color:
                        Colors.black54,
                  ),
                ),
                const SizedBox(
                    height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget caseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Property Dispute Case",
            style:
                GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
              color:
                  const Color(0xFF0B132B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Case ID: LX2026PD104",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          progressStep(
            "Case Submitted",
            "12 Apr 2026",
            true,
          ),
          progressStep(
            "Lawyer Assigned",
            "14 Apr 2026",
            true,
          ),
          progressStep(
            "Documents Reviewed",
            "18 Apr 2026",
            true,
          ),
          progressStep(
            "Hearing Scheduled",
            "24 Apr 2026",
            false,
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
                    Icons.track_changes,
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
                      "Case Status",
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
                      "Track each step of your case progress in real time.",
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
                        topTag(Icons.folder,
                            "Case"),
                        topTag(Icons.timeline,
                            "Progress"),
                        topTag(Icons.update,
                            "Live"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    caseCard(),
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