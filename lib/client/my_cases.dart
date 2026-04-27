import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCasesScreen extends StatelessWidget {
  const MyCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: Color(0xFF0B132B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "LexAssist",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.menu, color: Color(0xFF0B132B)),
                  ],
                ),
              ),

              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Cases",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage your active legal proceedings, track key deadlines, and oversee case documentation from a centralized dashboard.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Open New Case Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07142A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text(
                          "Open New Case",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search and Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search, size: 20, color: Colors.black45),
                            hintText: "Search by case name, number, or client...",
                            hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          filterChip(Icons.filter_list, "Type: All"),
                          const SizedBox(width: 8),
                          filterChip(Icons.priority_high, "Urgency: All"),
                          const SizedBox(width: 8),
                          filterChip(Icons.calendar_today, "Date Range"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Case Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    caseCard(
                      urgency: "HIGH URGENCY",
                      urgencyColor: const Color(0xFFFFEBEA),
                      urgencyTextColor: Colors.red,
                      caseId: "NY-2024-0012",
                      title: "Anderson vs. TechFlow Ltd.",
                      subtitle: "Intellectual Property Dispute - Patent Infringement",
                      nextHearing: "Oct 24, 2024 - 10:00 AM",
                      leadCounsel: "Elena Rodriguez, Esq.",
                      isLocked: true,
                    ),
                    const SizedBox(height: 16),
                    caseCard(
                      urgency: "MEDIUM",
                      urgencyColor: const Color(0xFFFFF4E5),
                      urgencyTextColor: Colors.orange,
                      caseId: "TX-2023-8842",
                      title: "Estate of Harold Jenkins",
                      subtitle: "Probate & Trust Administration",
                      status: "Discovery Phase",
                      progress: 0.6,
                      files: "14 Files",
                    ),
                    const SizedBox(height: 16),
                    caseCard(
                      urgency: "LOW",
                      urgencyColor: const Color(0xFFEef2ff),
                      urgencyTextColor: Colors.blue,
                      caseId: "CA-2024-5512",
                      title: "GreenWay Logistics v. City",
                      subtitle: "Commercial Real Estate / Zoning",
                      deadline: "In 2 Days",
                      alert: "Awaiting Client Signature",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Urgent Timeline Overview
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF14243B),
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=2070"),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Urgent Timeline Overview",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Cross-referencing active deadlines with courtroom availability and lead counsel schedules.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    timelineItem("Mediation - Smith v. General Motors", "Tomorrow, 09:00 AM • Courtroom 4B"),
                    timelineItem("Filing Deadline - Apex Acquisitions", "Oct 26, 2024 • Awaiting Draft"),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statBox("08", "CASES IN REVIEW"),
                        const SizedBox(width: 40),
                        statBox("03", "CRITICAL ALERTS", isAlert: true),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recent Case Documents
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Case Documents",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    documentTile("Affidavit_Revision_Final.pdf", "Anderson vs. TechFlow • Added by Elena R.", Icons.description),
                    documentTile("Court_Summons_CA-5512.pdf", "GreenWay Logistics • System Generated", Icons.gavel),
                    documentTile("Exhibit_A_Digital_Evidence.docx", "Alpha Corp Compliance • Added by Client", Icons.description),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.black54),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget caseCard({
    required String urgency,
    required Color urgencyColor,
    required Color urgencyTextColor,
    required String caseId,
    required String title,
    required String subtitle,
    String? nextHearing,
    String? leadCounsel,
    String? status,
    double? progress,
    String? files,
    String? deadline,
    String? alert,
    bool isLocked = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: urgencyTextColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: urgencyColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(urgency, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: urgencyTextColor)),
                        ),
                        const SizedBox(width: 8),
                        Text(caseId, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                        const Spacer(),
                        if (isLocked) const Icon(Icons.lock, size: 14, color: Color(0xFF8A6A00)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 16),
                    if (nextHearing != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(4)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("NEXT HEARING", style: GoogleFonts.inter(fontSize: 8, color: Colors.black45)),
                                  const SizedBox(height: 4),
                                  Text(nextHearing, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(4)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("LEAD COUNSEL", style: GoogleFonts.inter(fontSize: 8, color: Colors.black45)),
                                  const SizedBox(height: 4),
                                  Text(leadCounsel!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (status != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status", style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                          Text(status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, color: const Color(0xFF8A6A00), minHeight: 4),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        if (files != null) ...[
                          const Icon(Icons.forum_outlined, size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(files, style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                        ],
                        if (deadline != null) ...[
                          Text("Deadline", style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                          const Spacer(),
                          Text(deadline, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                        const Spacer(),
                        if (files != null) const Icon(Icons.more_vert, size: 18, color: Colors.black26),
                        if (nextHearing != null) ...[
                          const CircleAvatar(radius: 12, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 12, color: Colors.white)),
                          const SizedBox(width: -8),
                          const CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 12, color: Colors.white)),
                          const SizedBox(width: 12),
                          Text("View Documents ›", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF8A6A00))),
                        ],
                      ],
                    ),
                    if (alert != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFFEBEA), borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: [
                            const Icon(Icons.error, size: 14, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(alert, style: GoogleFonts.inter(fontSize: 10, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timelineItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statBox(String value, String label, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.orange : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget documentTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF3B5998), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, color: Colors.black26, size: 20),
        ],
      ),
    );
  }
}