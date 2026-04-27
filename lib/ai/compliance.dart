import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() =>
      _ComplianceScreenState();
}

class _ComplianceScreenState
    extends State<ComplianceScreen> {
  final TextEditingController textController =
      TextEditingController();

  Widget scoreCard(
      String title,
      String value,
      Color color,
      IconData icon) {
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
            radius: 22,
            backgroundColor:
                color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
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

  Widget issueTile(
      String title,
      String desc,
      Color color) {
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
                color.withOpacity(0.12),
            child: Icon(
              Icons.warning,
              color: color,
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
                      GoogleFonts.inter(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style:
                      GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        Colors.black54,
                  ),
                ),
              ],
            ),
          )
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
          "AI Compliance",
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
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    "Paste policy or legal text...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                scoreCard(
                    "Compliance",
                    "92%",
                    Colors.green,
                    Icons.check),
                scoreCard(
                    "Risks",
                    "3",
                    Colors.red,
                    Icons.warning),
                scoreCard(
                    "Clauses",
                    "18",
                    Colors.blue,
                    Icons.article),
                scoreCard(
                    "Updates",
                    "2",
                    Colors.orange,
                    Icons.update),
              ],
            ),
            const SizedBox(height: 24),
            issueTile(
              "Missing Clause",
              "Data retention clause not found.",
              Colors.red,
            ),
            issueTile(
              "GDPR Alert",
              "Review user consent wording.",
              Colors.orange,
            ),
            issueTile(
              "Strong Section",
              "Privacy policy looks compliant.",
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}