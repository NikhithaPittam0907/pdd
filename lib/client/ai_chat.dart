import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance, color: Color(0xFF0B132B), size: 18),
            const SizedBox(width: 8),
            Text(
              "LexisCore AI",
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B132B),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF4F6FB),
        elevation: 0,
        actions: [
          const Icon(Icons.shield, color: Color(0xFF0B132B), size: 20),
          const SizedBox(width: 20),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF0B132B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B132B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "CASE #2249-B",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    const Icon(Icons.lock, size: 12, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      "Attorney-Client\nPrivileged",
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.black54, height: 1.2),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Strategy Recommendation",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Agentic AI analysis of the newly discovery-phase depositions suggests a critical tactical shift for the upcoming evidentiary hearing.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF0B132B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Container 1: AI Recommendation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDE9B6),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 12, color: Color(0xFFB37400)),
                          const SizedBox(width: 4),
                          Text(
                            "AI RECOMMENDATION",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB37400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Based on the transcript from the Smith deposition (Timestamp 14:02), LexisCore AI detected an admission of periodic maintenance logs that were previously undisclosed. This shifts our strategy from "Lack of Knowledge" to "Negligent Supervision."',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEef2ff),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.trending_up, size: 14, color: Color(0xFF3B5998)),
                              const SizedBox(width: 8),
                              Text("Win Probability: +22%", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF3B5998))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEef2ff),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.gavel, size: 14, color: Color(0xFF3B5998)),
                              const SizedBox(width: 8),
                              Text("Legal Precedent: Strong", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF3B5998))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B132B),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Update Case Strategy", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Circular indicator
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: 0.78,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.grey.shade200,
                                      color: const Color(0xFF0B132B),
                                    ),
                                  ),
                                  Text("78%", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text("Strategic Viability", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Container 2: Current strategy
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CURRENT STRATEGY", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black54)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Defense of Ignorance", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0B132B))),
                        const SizedBox(height: 4),
                        Text("Maintaining that the entity had no prior knowledge of structural defects.", style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Comparative Fault", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0B132B))),
                        const SizedBox(height: 4),
                        Text("Shifting 30% liability to subcontractors based on initial contracts.", style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.warning, size: 14, color: Colors.red),
                      const SizedBox(width: 8),
                      Text("Low efficacy detected", style: GoogleFonts.inter(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Container 3: Risk Analysis
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Risk Analysis", style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                      const Icon(Icons.info, size: 16, color: Colors.black87),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Heatmap simulation
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.5,
                    children: [
                      Container(color: const Color(0xFFFFEBEA)),
                      Container(color: const Color(0xFFFFD1D1)),
                      Container(color: const Color(0xFFFFB3B3)),
                      Container(color: const Color(0xFFF44336)),

                      Container(color: const Color(0xFFFFF7E6)),
                      Container(color: const Color(0xFFFFEAB3)),
                      Container(color: const Color(0xFFFFD166)),
                      Container(color: const Color(0xFFFFB3B3)),

                      Container(color: const Color(0xFFFFFBEA)),
                      Container(color: const Color(0xFFFFF2B3)),
                      Container(color: const Color(0xFFFFEAB3)),
                      Container(color: const Color(0xFFFFD166)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("LOW PROBABILITY", style: GoogleFonts.inter(fontSize: 8, color: Colors.black45)),
                      Text("HIGH IMPACT", style: GoogleFonts.inter(fontSize: 8, color: Colors.black45)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.black87, height: 1.5),
                      children: const [
                        TextSpan(text: "The highlighted risk factor is the "),
                        TextSpan(text: "Inadmissibility of Maintenance Logs", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " due to chain-of-custody gaps."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Container 4: Settlement Outlook
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Settlement Outlook", style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(
                    "AI-modeled negotiation range based on 46 comparable state-level verdicts.",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  
                  // Graph area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("\$450K", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text("\$1.2M", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFFEef2ff), borderRadius: BorderRadius.circular(12)),
                      ),
                      Positioned(
                        left: 60,
                        right: 80,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "OPTIMAL ZONE",
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Suggested\nOpening", style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
                              const SizedBox(height: 8),
                              Text("\$725,000", style: GoogleFonts.inter(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE9B6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Walk-away\nPoint", style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8A6A00))),
                              const SizedBox(height: 8),
                              Text("\$1,450,000", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8A6A00))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Container 5: Strategic Execution Plan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Strategic Execution Plan", style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 24),
                  
                  // Step 1
                  stepTile(
                    number: "1", 
                    isActive: true, 
                    title: "File Motion in Limine", 
                    desc: "Prevent opposing counsel from introducing hearsay regarding the maintenance log origins.", 
                    badgeText: "READY",
                    badgeColor: const Color(0xFFD4EDDA),
                    badgeTextColor: const Color(0xFF155724)
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: SizedBox(height: 24, child: VerticalDivider(color: Colors.grey, thickness: 1)),
                  ),
                  
                  // Step 2
                  stepTile(
                    number: "2", 
                    isActive: true, 
                    title: "Supplemental Discovery", 
                    desc: "Request metadata for maintenance spreadsheets to verify entry dates.", 
                    badgeText: "PENDING COURT",
                    badgeColor: const Color(0xFFEef2ff),
                    badgeTextColor: const Color(0xFF3B5998)
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: SizedBox(height: 24, child: VerticalDivider(color: Colors.grey, thickness: 1)),
                  ),

                  // Step 3
                  stepTile(
                    number: "3", 
                    isActive: true, 
                    title: "Expert Deposition", 
                    desc: "Re-interview structural engineer Dr. Aris based on the \"Constructive Notice\" theory.", 
                    badgeText: "SCHEDULING",
                    badgeColor: const Color(0xFFEef2ff),
                    badgeTextColor: const Color(0xFF5A6679)
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: SizedBox(height: 24, child: VerticalDivider(color: Colors.grey, thickness: 1)),
                  ),

                  // Step 4
                  stepTile(
                    number: "4", 
                    isActive: false, 
                    title: "Mediation Brief", 
                    desc: "Finalize settlement position with the updated risk/benefit ratio from AI analysis.", 
                    badgeText: "UPCOMING",
                    badgeColor: const Color(0xFFF4F6FB),
                    badgeTextColor: const Color(0xFF5A6679)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget stepTile({required String number, required bool isActive, required String title, required String desc, required String badgeText, required Color badgeColor, required Color badgeTextColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0B132B) : Colors.white,
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 6),
              Text(desc, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54, height: 1.4)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      badgeText,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}