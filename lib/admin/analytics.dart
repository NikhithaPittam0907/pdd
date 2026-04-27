import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Widget statCard(
      String title,
      String value,
      IconData icon,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style:
                GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
              color:
                  const Color(0xFF0B132B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget reportTile(
      String title,
      String subtitle,
      IconData icon) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                const Color(0xFFEAF0FF),
            child: Icon(icon,
                color: const Color(
                    0xFF0B132B)),
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
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 16),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Analytics",
          style:
              GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight:
                FontWeight.bold,
            color:
                const Color(0xFF0B132B),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF0B132B),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                statCard(
                    "Users",
                    "250",
                    Icons.people,
                    Colors.blue),
                statCard(
                    "Cases",
                    "148",
                    Icons.folder,
                    Colors.green),
                statCard(
                    "Revenue",
                    "₹1.2L",
                    Icons.payment,
                    Colors.orange),
                statCard(
                    "Lawyers",
                    "38",
                    Icons.gavel,
                    Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            reportTile(
              "Monthly Growth",
              "User registrations increased this month.",
              Icons.trending_up,
            ),
            reportTile(
              "Case Resolution",
              "82% cases resolved successfully.",
              Icons.check_circle,
            ),
            reportTile(
              "Payment Report",
              "Track invoices and revenue stats.",
              Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }
}