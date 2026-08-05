import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';

class AssignedCasesScreen extends StatefulWidget {
  const AssignedCasesScreen({super.key});

  @override
  State<AssignedCasesScreen> createState() => _AssignedCasesScreenState();
}

class _AssignedCasesScreenState extends State<AssignedCasesScreen> {
  List<dynamic> lawyerCases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLawyerCases();
  }

  Future<void> _fetchLawyerCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/lawyer/cases?email=$email'));
      if (response.statusCode == 200) {
        setState(() {
          lawyerCases = jsonDecode(response.body);
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
    String rawType = c['type'] ?? "General Case";
    String caseId = c['case_id'] ?? "N/A";
    String title = (rawType.toLowerCase().contains('domestic') || rawType.toLowerCase().contains('violence')) ? "Case ID: $caseId" : rawType;
    String client = c['email'] ?? "Unknown";
    String type = c['type'] ?? "Legal Matter";
    String status = c['handling_status'] ?? c['status'] ?? "Active";
    String date = c['created_at'] != null ? c['created_at'].toString().split('T')[0] : "Unknown Date";

    Color statusColor = status.contains('Closed') ? Colors.red : (status.contains('Pending') ? Colors.orange : Colors.green);

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          infoRow(Icons.person, "Client", client),
          const SizedBox(height: 10),
          infoRow(Icons.gavel, "Case Type", type),
          const SizedBox(height: 10),
          infoRow(Icons.event, "Requested On", date),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LawyerCaseDetailsScreen(
                      caseData: c,
                      onAccept: _fetchLawyerCases,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0B132B)),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B132B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
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
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0B132B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
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
                  const Icon(Icons.verified_user),
                ],
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Assigned Cases",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B132B),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Manage your active legal assignments and track hearing schedules.",
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
                          children: [
                            topTag(Icons.work, "Active Cases"),
                            topTag(Icons.event, "Hearings"),
                            topTag(Icons.analytics, "Insights"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : lawyerCases.isEmpty
                            ? Center(
                                child: Text(
                                  "No cases assigned yet.",
                                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchLawyerCases,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: lawyerCases.length,
                                  itemBuilder: (context, index) {
                                    return caseCard(lawyerCases[index]);
                                  },
                                ),
                              ),
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

class LawyerCaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;
  final VoidCallback onAccept;

  const LawyerCaseDetailsScreen({
    super.key,
    required this.caseData,
    required this.onAccept,
  });

  @override
  State<LawyerCaseDetailsScreen> createState() => _LawyerCaseDetailsScreenState();
}

class _LawyerCaseDetailsScreenState extends State<LawyerCaseDetailsScreen> {
  bool isAccepting = false;

  String _resolveFileUrl(String serverPath) {
    if (serverPath.isEmpty) return "";
    if (serverPath.startsWith("http://") || serverPath.startsWith("https://")) {
      return serverPath;
    }
    String cleanPath = serverPath.replaceAll('\\', '/');
    if (cleanPath.contains("uploads/")) {
      cleanPath = cleanPath.substring(cleanPath.indexOf("uploads/") + "uploads/".length);
    }
    return "${ApiConfig.baseUrl}/uploads/$cleanPath";
  }

  void _previewFile(BuildContext context, String pathVal) {
    final url = _resolveFileUrl(pathVal);
    if (url.isEmpty) return;

    final lower = pathVal.toLowerCase();
    final isImage = lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pathVal.split('/').last.split('\\').last,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Column(
                      children: [
                        const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text("Unable to load image preview.", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Icon(_fileIcon(pathVal), size: 54, color: const Color(0xFF0B132B)),
                    const SizedBox(height: 12),
                    Text("Document / Evidence File Attached", style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text("Open / Download File"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B132B)),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _fileIcon(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) return Icons.image;
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi')) return Icons.videocam;
    return Icons.insert_drive_file;
  }

  Future<void> _handleCaseAction(String action) async {
    setState(() => isAccepting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final officialName = prefs.getString('name') ?? '';
      final officialEmail = prefs.getString('email') ?? '';

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/accept-case'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "case_id": widget.caseData['case_id'],
          "role": "lawyer",
          "action": action,
          "official_name": officialName,
          "official_email": officialEmail,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        final bool isAccept = action == 'accept';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAccept ? "Case officially accepted. Client notified." : "Case declined. Client notified."),
            backgroundColor: isAccept ? Colors.green : Colors.red,
          ),
        );
        widget.onAccept();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        String errMsg = "Failed to process case.";
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

    bool alreadyAccepted = status == "Lawyer Accepted";

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
            Text(
              (type.toLowerCase().contains('domestic') || type.toLowerCase().contains('violence')) ? "Case ID: $caseId" : type,
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B)),
            ),
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
                    if (e.key == 'uploaded_files' && e.value is Map) {
                      final files = e.value as Map;
                      if (files.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("UPLOADED FILES", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black45)),
                            const SizedBox(height: 8),
                            ...files.entries.map((fe) {
                              final pathVal = fe.value.toString();
                              final bool hasFile = pathVal.isNotEmpty;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: !hasFile ? null : () => _previewFile(context, pathVal),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: hasFile ? Colors.blue.shade100 : Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(_fileIcon(pathVal), color: hasFile ? Colors.blue.shade700 : const Color(0xFF0B132B), size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(fe.key.toString().replaceAll('_', ' ').toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w600)),
                                              Text(
                                                hasFile ? pathVal.split('/').last.split('\\').last : 'Not uploaded',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: hasFile ? Colors.blue.shade900 : Colors.black87,
                                                  fontWeight: hasFile ? FontWeight.w600 : FontWeight.normal,
                                                  decoration: hasFile ? TextDecoration.underline : null,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (hasFile)
                                          Icon(Icons.open_in_new, size: 16, color: Colors.blue.shade700),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key.toString().replaceAll('_', ' ').toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black45)),
                          const SizedBox(height: 4),
                          Text(e.value.toString(), style: GoogleFonts.inter(fontSize: 14, color: Colors.black87)),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isAccepting ? null : () => _handleCaseAction('decline'),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: Text("DECLINE CASE", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isAccepting ? null : () => _handleCaseAction('accept'),
                      icon: isAccepting 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: Text(
                        isAccepting ? "Processing..." : "ACCEPT CASE",
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
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
