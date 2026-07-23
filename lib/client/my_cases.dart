import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  List<dynamic> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCases();
  }

  Future<void> _fetchCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get-my-cases?email=$email'));

      if (response.statusCode == 200) {
        setState(() {
          _cases = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchCases,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        "Manage your active legal proceedings and track case documentation from a centralized dashboard.",
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.black54, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                else if (_cases.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.folder_open, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("No active cases found", style: GoogleFonts.inter(color: Colors.black45)),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: _cases.map((c) => _buildCaseCard(c)).toList(),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCaseDetails(Map<String, dynamic> caseData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CaseDetailsScreen(caseData: caseData),
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseData) {
    final analysis = caseData['analysis'] ?? {};
    final risk = analysis['risk_level'] ?? 'LOW';
    final type = caseData['type'] ?? 'Legal Case';
    final caseId = caseData['case_id'] ?? 'N/A';
    
    Color riskColor = Colors.green;
    if (risk == 'HIGH') riskColor = Colors.red;
    if (risk == 'MEDIUM') riskColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () => _showCaseDetails(caseData),
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: riskColor,
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
                          decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(risk, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: riskColor)),
                        ),
                        const SizedBox(width: 8),
                        Text(caseId, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                        const Spacer(),
                        Text(caseData['status'] ?? 'Submitted', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(type, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                    const SizedBox(height: 4),
                    Text(
                      analysis['case_summary'] ?? analysis['risk_summary'] ?? 'New case submission in progress.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.black54, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.black45),
                        const SizedBox(width: 6),
                        Text(
                          caseData['created_at'] != null ? caseData['created_at'].toString().split('T')[0] : 'Today',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
                        ),
                        const Spacer(),
                        Text("View Details ›", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF8A6A00))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class CaseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> caseData;
  const CaseDetailsScreen({super.key, required this.caseData});

  IconData _fileIcon(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) return Icons.image;
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi')) return Icons.videocam;
    return Icons.insert_drive_file;
  }

  String _resolveFileUrl(String serverPath) {
    if (serverPath.isEmpty) return "";
    if (serverPath.startsWith("http://") || serverPath.startsWith("https://")) {
      return serverPath;
    }
    String cleanPath = serverPath.replaceAll('\\', '/');
    if (cleanPath.startsWith("uploads/")) {
      cleanPath = cleanPath.substring("uploads/".length);
    }
    return "${ApiConfig.baseUrl}/uploads/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    final analysis = caseData['analysis'] ?? {};
    final details = caseData['details'] ?? {};
    final status = caseData['status'] ?? 'Submitted';
    final type = caseData['type'] ?? 'Legal Case';
    final caseId = caseData['case_id'] ?? 'N/A';

    final List<String> stages = ['Submitted', 'Under Review', 'Action Taken', 'Completed'];
    int currentStageIndex = stages.indexOf(status);
    if (currentStageIndex == -1) currentStageIndex = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Case Tracking", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B132B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("ID: $caseId", style: GoogleFonts.inter(color: Colors.black45)),
            const SizedBox(height: 16),
            
            if (caseData['handling_status'] != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Handling Status", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 2),
                          Text(caseData['handling_status'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
            // Incident Details & Uploaded Files
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
                            Text(
                              "UPLOADED EVIDENCE",
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black45),
                            ),
                            const SizedBox(height: 8),
                            ...files.entries.map((fe) {
                              final pathVal = fe.value.toString();
                              final bool hasFile = pathVal.isNotEmpty;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: !hasFile ? null : () async {
                                    final url = _resolveFileUrl(pathVal);
                                    if (url.isNotEmpty) {
                                      final uri = Uri.parse(url);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    }
                                  },
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
                                        Icon(
                                          _fileIcon(pathVal),
                                          color: hasFile ? Colors.blue.shade700 : const Color(0xFF0B132B),
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
                                                hasFile ? pathVal.split('/').last : 'Not uploaded',
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

            Text("CASE TIMELINE", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black45)),
            const SizedBox(height: 24),
            
            ...List.generate(stages.length, (index) {
              final bool isCompleted = index <= currentStageIndex;
              final bool isCurrent = index == currentStageIndex;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.blue : Colors.grey.shade300,
                          border: isCurrent ? Border.all(color: Colors.blue.shade100, width: 4) : null,
                        ),
                        child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                      ),
                      if (index != stages.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: index < currentStageIndex ? Colors.blue : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stages[index], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isCompleted ? Colors.black87 : Colors.black26)),
                      Text(isCompleted ? "Updated on ${caseData['created_at']?.toString().split('T')[0] ?? 'Today'}" : "Pending", style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),
            
            Text("AI ANALYSIS SUMMARY", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black45)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text(
                analysis['case_summary'] ?? "Detailed analysis is being prepared by LexisAI. Check back soon for legal suggestions.",
                style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: Colors.black87),
              ),
            ),
            
            if (analysis['complaint_draft'] != null && analysis['complaint_draft'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 32),
              Text("AI GENERATED COMPLAINT DRAFT", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black45)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  analysis['complaint_draft'].toString(),
                  style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final text = analysis['complaint_draft'].toString();
                        if (text.trim().isEmpty) return;
                        final doc = pw.Document();
                        doc.addPage(pw.MultiPage(
                          pageFormat: PdfPageFormat.a4,
                          margin: const pw.EdgeInsets.all(32),
                          build: (pw.Context ctx) => [
                            pw.Text('LexisAI — Domestic Violence Complaint',
                                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 8),
                            if (caseId.isNotEmpty)
                              pw.Text('Case ID: $caseId',
                                  style: pw.TextStyle(fontSize: 11, color: PdfColors.blue700)),
                            pw.SizedBox(height: 16),
                            pw.Text(text,
                                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4)),
                          ],
                        ));
                        await Printing.layoutPdf(onLayout: (fmt) => doc.save());
                      },
                      icon: const Icon(Icons.download_rounded, color: Colors.white),
                      label: const Text("Download Complaint PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B132B), padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}