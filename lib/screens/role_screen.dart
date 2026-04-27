import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../client/client_dashboard.dart';
import '../lawyer/lawyer_dashboard.dart';
import '../admin/admin_dashboard.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  Widget roleCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFEAF0FF),
              child: Icon(icon, color: const Color(0xFF0B132B), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
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
                  const Icon(Icons.verified_user, color: Color(0xFF0B132B)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Text(
                      "Choose Your Portal",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Select your secure access portal to continue into the legal platform.",
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
                      alignment: WrapAlignment.center,
                      children: [
                        topTag(Icons.security, "Secure"),
                        topTag(Icons.smart_toy, "AI Enabled"),
                        topTag(Icons.workspace_premium, "Premium"),
                      ],
                    ),

                    const SizedBox(height: 28),

                    roleCard(
                      context,
                      Icons.people,
                      "Client",
                      "Track cases, upload documents and book consultations.",
                      const ClientDashboard(),
                    ),

                    const SizedBox(height: 14),

                    roleCard(
                      context,
                      Icons.gavel,
                      "Lawyer",
                      "Research, strategy, hearings and legal drafting tools.",
                      const LawyerDashboard(),
                    ),

                    const SizedBox(height: 14),

                    roleCard(
                      context,
                      Icons.admin_panel_settings,
                      "Admin",
                      "Manage lawyers, analytics and operational workflow.",
                      const AdminDashboard(),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: const Color(0xFFF1F3F8),
              child: Column(
                children: [
                  Text(
                    "© 2024 LEXISAI. ATTORNEY-CLIENT PRIVILEGED.",
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "PRIVACY\nPOLICY",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 11),
                      ),
                      Text(
                        "TERMS OF\nSERVICE",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 11),
                      ),
                      Text(
                        "SECURITY\nARCHITECTURE",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
