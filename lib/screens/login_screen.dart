import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Widget topFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0B132B)),
          const SizedBox(width: 8),
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

  Widget actionButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
    Color color,
    Color textColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        icon: Icon(icon, color: textColor),
        label: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget infoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B132B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
              height: 1.5,
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
                      "Secure Legal Access",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Professional AI-powered legal platform for clients, lawyers and administrators.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        topFeature(Icons.shield, "Secure Access"),
                        topFeature(Icons.smart_toy, "AI Assistant"),
                        topFeature(Icons.folder, "Case Tracking"),
                        topFeature(Icons.analytics, "Insights"),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        children: [
                          actionButton(
                            context,
                            "SIGN IN",
                            Icons.login,
                            const SignInScreen(),
                            const Color(0xFF001A3A),
                            Colors.white,
                          ),

                          const SizedBox(height: 14),

                          actionButton(
                            context,
                            "CREATE ACCOUNT",
                            Icons.person_add_alt_1,
                            const SignUpScreen(),
                            const Color(0xFFEAF0FF),
                            const Color(0xFF0B132B),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: [
                        infoCard(
                          Icons.gavel,
                          "For Lawyers",
                          "Research, case strategy, drafting and analytics tools.",
                        ),
                        infoCard(
                          Icons.people,
                          "For Clients",
                          "Track cases, upload documents and book consultations.",
                        ),
                        infoCard(
                          Icons.admin_panel_settings,
                          "For Admins",
                          "Manage operations, lawyers and performance.",
                        ),
                        infoCard(
                          Icons.auto_awesome,
                          "AI Powered",
                          "Smart recommendations and automation workflows.",
                        ),
                      ],
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
