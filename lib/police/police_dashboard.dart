import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../screens/signin_screen.dart';

class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({super.key});

  @override
  State<PoliceDashboard> createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  List<dynamic> policeCases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPoliceCases();
  }

  Future<void> _fetchPoliceCases() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/police/cases'));
      if (response.statusCode == 200) {
        setState(() {
          policeCases = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget caseCard(Map<String, dynamic> c) {
    String title = c['type'] ?? "General Case";
    String client = c['email'] ?? "Unknown";
    String status = c['handling_status'] ?? c['status'] ?? "Pending";
    String date = c['created_at'] != null ? c['created_at'].toString().split('T')[0] : "Unknown Date";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B132B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Color(0xFF0B132B)),
              const SizedBox(width: 10),
              Text("Reported By: ", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0B132B))),
              Expanded(child: Text(client, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event, size: 18, color: Color(0xFF0B132B)),
              const SizedBox(width: 10),
              Text("Reported On: ", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0B132B))),
              Expanded(child: Text(date, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54))),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoliceCaseDetailsScreen(
                      caseData: c,
                      onAccept: _fetchPoliceCases,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, color: Colors.white),
              label: Text(
                "VIEW DETAILS",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001A3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                  const Icon(Icons.local_police, color: Color(0xFF0B132B)),
                  const SizedBox(width: 10),
                  Text(
                    "Police Portal",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'logout') {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Logout", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF0FF),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF0B132B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : policeCases.isEmpty
                      ? Center(
                          child: Text(
                            "No cases reported to police yet.",
                            style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchPoliceCases,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: policeCases.length,
                            itemBuilder: (context, index) {
                              return caseCard(policeCases[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class PoliceCaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;
  final VoidCallback onAccept;

  const PoliceCaseDetailsScreen({
    super.key,
    required this.caseData,
    required this.onAccept,
  });

  @override
  State<PoliceCaseDetailsScreen> createState() => _PoliceCaseDetailsScreenState();
}

class _PoliceCaseDetailsScreenState extends State<PoliceCaseDetailsScreen> {
  bool isAccepting = false;

  IconData _fileIcon(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) return Icons.image;
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi')) return Icons.videocam;
    return Icons.insert_drive_file;
  }

  Future<void> _acceptCase() async {
    setState(() => isAccepting = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/accept-case'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "case_id": widget.caseData['case_id'],
          "role": "police",
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Case officially accepted.")),
        );
        widget.onAccept();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        String errMsg = "Failed to accept case.";
        try { errMsg = jsonDecode(response.body)['message'] ?? errMsg; } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network Error")),
      );
    }
    setState(() => isAccepting = false);
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.caseData['analysis'] ?? {};
    final details = widget.caseData['details'] ?? {};
    final type = widget.caseData['type'] ?? 'General Case';
    final caseId = widget.caseData['case_id'] ?? 'N/A';
    final status = widget.caseData['handling_status'] ?? widget.caseData['status'];

    bool alreadyAccepted = status == "Police Accepted";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Case Details", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B132B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
            const SizedBox(height: 8),
            Text("Case ID: $caseId", style: GoogleFonts.inter(color: Colors.black54)),
            const SizedBox(height: 24),

            // Incident Details
            Text("INCIDENT DETAILS", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black45)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...details.entries.map((e) {
                    // Handle uploaded_files sub-map specially
                    if (e.key == 'uploaded_files' && e.value is Map) {
                      final files = e.value as Map;
                      if (files.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "UPLOADED FILES",
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black45),
                            ),
                            const SizedBox(height: 8),
                            ...files.entries.map((fe) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _fileIcon(fe.value.toString()),
                                    color: const Color(0xFF0B132B),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fe.key.toString().replaceAll('_', ' ').toUpperCase(),
                                          style: GoogleFonts.inter(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          fe.value.toString().isNotEmpty ? fe.value.toString() : 'Not uploaded',
                                          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.key.toString().replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black45),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.value.toString(),
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI Analysis
            Text("AI RISK ANALYSIS", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black45)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 20),
                      const SizedBox(width: 8),
                      Text("Risk Level: ${analysis['risk_level'] ?? 'UNKNOWN'}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFE65100))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    analysis['how_risk_analysis_calculated'] ?? analysis['case_summary'] ?? "No analysis available.",
                    style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: const Color(0xFF5D4037)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Action Button
            if (!alreadyAccepted)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isAccepting ? null : _acceptCase,
                  icon: isAccepting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    isAccepting ? "Accepting..." : "ACCEPT CASE",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text("Case Accepted", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
