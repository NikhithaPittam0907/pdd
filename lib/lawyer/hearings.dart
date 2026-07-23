import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HearingsScreen extends StatelessWidget {
  const HearingsScreen({super.key});

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

  Widget hearingCard({
    required String caseName,
    required String court,
    required String judge,
    required String date,
    required String time,
    required String status,
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caseName,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(0xFF0B132B),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          infoRow(
              Icons.account_balance,
              "Court",
              court),
          const SizedBox(height: 10),
          infoRow(Icons.person,
              "Judge", judge),
          const SizedBox(height: 10),
          infoRow(Icons.event,
              "Date", date),
          const SizedBox(height: 10),
          infoRow(Icons.access_time,
              "Time", time),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.visibility,
                color: Colors.white,
              ),
              label: Text(
                "VIEW DETAILS",
                style:
                    GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                        0xFF001A3A),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(
      IconData icon,
      String title,
      String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF0B132B),
        ),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
            color:
                const Color(0xFF0B132B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0B132B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
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
                    Icons.event,
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
                      "Hearings",
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
                      "Track upcoming hearings, schedules and court updates.",
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
                        topTag(Icons.event,
                            "Schedules"),
                        topTag(Icons.gavel,
                            "Court"),
                        topTag(Icons.alarm,
                            "Reminders"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    hearingCard(
                      caseName:
                          "Property Dispute",
                      court:
                          "Chennai High Court",
                      judge:
                          "Justice Kumar",
                      date:
                          "24 Apr 2026",
                      time: "10:30 AM",
                      status:
                          "Today",
                      color: Colors.red,
                    ),
                    hearingCard(
                      caseName:
                          "Corporate Fraud",
                      court:
                          "City Civil Court",
                      judge:
                          "Justice Meena",
                      date:
                          "28 Apr 2026",
                      time: "11:15 AM",
                      status:
                          "Upcoming",
                      color:
                          Colors.orange,
                    ),
                    hearingCard(
                      caseName:
                          "Family Settlement",
                      court:
                          "Family Court",
                      judge:
                          "Justice Priya",
                      date:
                          "03 May 2026",
                      time: "09:45 AM",
                      status:
                          "Scheduled",
                      color:
                          Colors.green,
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