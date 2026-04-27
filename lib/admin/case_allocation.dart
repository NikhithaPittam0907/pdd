import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseAllocationScreen extends StatelessWidget {
  const CaseAllocationScreen({super.key});

  Widget allocationCard({
    required String caseTitle,
    required String caseId,
    required String client,
    required String lawyer,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caseTitle,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 22,
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
          const SizedBox(height: 12),
          infoRow(
              Icons.confirmation_number,
              "Case ID",
              caseId),
          const SizedBox(height: 8),
          infoRow(Icons.person,
              "Client", client),
          const SizedBox(height: 8),
          infoRow(Icons.gavel,
              "Lawyer", lawyer),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
              ),
              label: Text(
                "REALLOCATE",
                style:
                    GoogleFonts.inter(
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
        Icon(icon,
            size: 18,
            color: const Color(
                0xFF0B132B)),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
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
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Case Allocation",
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
            allocationCard(
              caseTitle:
                  "Property Dispute",
              caseId:
                  "LX2026PD104",
              client:
                  "Nikhitha",
              lawyer:
                  "Adv. Rahul",
              status:
                  "Assigned",
              color: Colors.green,
            ),
            allocationCard(
              caseTitle:
                  "Consumer Complaint",
              caseId:
                  "LX2026CC212",
              client:
                  "Ravi Kumar",
              lawyer:
                  "Pending",
              status:
                  "Unassigned",
              color: Colors.orange,
            ),
            allocationCard(
              caseTitle:
                  "Family Settlement",
              caseId:
                  "LX2026FS078",
              client:
                  "Sneha",
              lawyer:
                  "Adv. Priya",
              status:
                  "Assigned",
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}