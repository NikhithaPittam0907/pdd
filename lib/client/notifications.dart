import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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

  Widget notifyCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
            radius: 24,
            backgroundColor:
                color.withOpacity(0.12),
            child: Icon(icon, color: color),
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
                  subtitle,
                  style:
                      GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey,
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
                    Icons.notifications,
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
                      "Notifications",
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
                      "Stay updated with hearings, payments, messages and case progress.",
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
                        topTag(Icons.update,
                            "Updates"),
                        topTag(Icons.event,
                            "Hearings"),
                        topTag(Icons.payment,
                            "Billing"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    notifyCard(
                      icon: Icons.event,
                      color: Colors.blue,
                      title:
                          "Hearing Scheduled",
                      subtitle:
                          "Your hearing is fixed for 24 Apr 2026 at 10:30 AM.",
                      time: "2m ago",
                    ),
                    notifyCard(
                      icon: Icons.payment,
                      color: Colors.green,
                      title:
                          "Payment Received",
                      subtitle:
                          "Invoice payment of ₹2,000 completed successfully.",
                      time: "1h ago",
                    ),
                    notifyCard(
                      icon: Icons.chat,
                      color: Colors.orange,
                      title:
                          "Lawyer Message",
                      subtitle:
                          "Please upload ownership proof documents.",
                      time: "3h ago",
                    ),
                    notifyCard(
                      icon: Icons.folder,
                      color: Colors.red,
                      title:
                          "Case Updated",
                      subtitle:
                          "Your case moved to document review stage.",
                      time: "Yesterday",
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