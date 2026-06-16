import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class StudentIssueFlowScreen extends StatefulWidget {
  const StudentIssueFlowScreen({super.key});

  @override
  State<StudentIssueFlowScreen> createState() => _StudentIssueFlowScreenState();
}

class _StudentIssueFlowScreenState extends State<StudentIssueFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedCaseType;
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  Map<String, PlatformFile?> uploadedFiles = {
    'evidence': null,
    'receipts': null,
    'id_proof': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<Map<String, dynamic>> caseTypes = [
    {"name": "Ragging / Harassment", "icon": Icons.report_problem_rounded, "color": Colors.red},
    {"name": "Fee Fraud", "icon": Icons.money_off_rounded, "color": Colors.blue},
    {"name": "Certificate Not Issued", "icon": Icons.article_rounded, "color": Colors.green},
    {"name": "Admission Issues", "icon": Icons.school_rounded, "color": Colors.orange},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    collegeController.dispose();
    departmentController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 6) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickFile(String category) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['pdf', 'jpg', 'png', 'mp4', 'mp3']
    );
    if (result != null) {
      setState(() {
        uploadedFiles[category] = result.files.first;
      });
    }
  }

  Future<void> _submitToBackend() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-student-issue');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['case_type'] = selectedCaseType ?? 'Student Issue'
        ..fields['college_name'] = collegeController.text
        ..fields['department'] = departmentController.text
        ..fields['date_incident'] = dateController.text
        ..fields['description'] = descriptionController.text;

      for (var entry in uploadedFiles.entries) {
        if (entry.value?.path != null) {
          req.files.add(await http.MultipartFile.fromPath(entry.key, entry.value!.path!));
        }
      }

      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        if (mounted) setState(() { _caseResult = json.decode(res.body); _isSubmitting = false; });
      } else {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  final Color primaryColor = const Color(0xFFFBC02D); // Amber
  final Color secondaryColor = const Color(0xFF0B132B); // Dark Navy

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Student Legal Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: secondaryColor)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: secondaryColor), onPressed: () => Navigator.pop(context)),
        actions: [
          Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Step ${_currentStep + 1}/7", style: GoogleFonts.inter(color: secondaryColor.withOpacity(0.7), fontWeight: FontWeight.bold)))),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _step1Type(),
          _step2Details(),
          _step3Documents(),
          _step4Analysis(),
          _step5Generator(),
          _step6Escalation(),
          _step7Tracking(),
        ],
      ),
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: secondaryColor)),
        const SizedBox(height: 8),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _step1Type() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("What's the issue?", "Select the category that best fits your situation."),
          Expanded(
            child: ListView.builder(
              itemCount: caseTypes.length,
              itemBuilder: (context, index) {
                final type = caseTypes[index];
                final isSelected = selectedCaseType == type["name"];
                return InkWell(
                  onTap: () => setState(() => selectedCaseType = type["name"]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? type["color"].withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? type["color"] : Colors.grey.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(type["icon"], color: type["color"], size: 30),
                        const SizedBox(width: 16),
                        Text(type["name"], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isSelected ? type["color"] : Colors.black87)),
                        const Spacer(),
                        if (isSelected) Icon(Icons.check_circle, color: type["color"]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _navButtons(onNext: selectedCaseType != null ? _nextPage : null),
        ],
      ),
    );
  }

  Widget _step2Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Details", "Provide context about the academic institution and incident."),
          _textField("College / University Name", collegeController, "e.g. National Institute of Technology"),
          const SizedBox(height: 16),
          _textField("Course / Department", departmentController, "e.g. Computer Science"),
          const SizedBox(height: 16),
          _textField("Date of Incident", dateController, "DD/MM/YYYY"),
          const SizedBox(height: 16),
          Text("Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Briefly explain what happened...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: Colors.amber), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 40),
          _navButtons(),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }

  Widget _step3Documents() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Evidence Upload", "Upload proofs to strengthen your academic claim."),
          _uploadTile("Evidence (Photos/Videos/Chats)", "evidence", "Recommended"),
          const SizedBox(height: 12),
          _uploadTile("Fee Receipts / Payment Proof", "receipts", "Important"),
          const SizedBox(height: 12),
          _uploadTile("Student ID / Certificates", "id_proof", "Optional"),
          const Spacer(),
          TextButton(onPressed: _nextPage, child: const Center(child: Text("Skip / Upload Later"))),
          _navButtons(onNext: () {
            _submitToBackend();
            _nextPage();
          }, nextText: "Analyze with AI"),
        ],
      ),
    );
  }

  Widget _uploadTile(String title, String category, String priority) {
    final file = uploadedFiles[category];
    return InkWell(
      onTap: () => _pickFile(category),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            const Icon(Icons.attachment_rounded, color: Colors.amber),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(file?.name ?? "No file selected ($priority)", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (file != null) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _step4Analysis() {
    if (_isSubmitting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text("AI Analyzing Student Case...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    final risk = _caseResult?['risk_level'] ?? 'LOW';
    final riskColor = risk == 'HIGH' ? Colors.red : (risk == 'MEDIUM' ? Colors.orange : Colors.green);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("AI Assessment", "Case summary and risk detection."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: riskColor)),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: riskColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: riskColor)),
                  Text(selectedCaseType ?? 'Student Issue', style: GoogleFonts.inter(fontSize: 12)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Risk Analysis", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on severity and evidence provided.', style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          Text("Case Summary", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['case_summary'] ?? 'N/A', style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          Text("Suggested Next Steps", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['suggested_steps'] as List?) ?? []).map((step) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [const Icon(Icons.arrow_right_alt, color: Colors.amber), const SizedBox(width: 8), Expanded(child: Text(step.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 40),
          _navButtons(nextText: "Generate Complaint"),
        ],
      ),
    );
  }

  Widget _step5Generator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Academic Complaint", "Auto-generated complaint draft."),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Text(_caseResult?['legal_document'] ?? 'Drafting document...', style: GoogleFonts.inter(fontSize: 12, height: 1.6)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text("Edit"))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text("Download"), style: ElevatedButton.styleFrom(backgroundColor: secondaryColor))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)), child: const Text("Ready to Escalate")),
          const SizedBox(height: 40),
          _navButtons(nextText: "Escalation Options"),
        ],
      ),
    );
  }

  Widget _step6Escalation() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Escalation Hub", "Actionable paths for your complaint."),
          _escalateButton("Submit to College Authority", Icons.account_balance, () {}),
          _escalateButton("Escalate to Education Board", Icons.gavel, () {}),
          _escalateButton("Contact Education Lawyer", Icons.person_search, () {}),
          _escalateButton("Save for Later", Icons.save_outlined, () => Navigator.pop(context)),
          const Spacer(),
          _navButtons(nextText: "Finish"),
        ],
      ),
    );
  }

  Widget _escalateButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap, 
        icon: Icon(icon, color: secondaryColor), 
        label: Text(title, style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)), 
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
      ),
    );
  }

  Widget _step7Tracking() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text("Case Filed Successfully", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'STU-2026-N4M5K6'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Complaint Filed", "Action completed on 02 May 2026", true),
          _trackingItem("Authority Review", "Pending response from College", false),
          _trackingItem("Action Taken", "Awaiting official update", false),
          const Spacer(),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Back to Home")),
        ],
      ),
    );
  }

  Widget _trackingItem(String label, String status, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            Text(status, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          ]),
        ],
      ),
    );
  }

  Widget _navButtons({VoidCallback? onNext, String nextText = "Next"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0 && _currentStep < 6) 
          TextButton(onPressed: _prevPage, child: const Text("Back", style: TextStyle(color: Colors.black54))) 
        else const SizedBox(),
        if (_currentStep < 6) 
          ElevatedButton(
            onPressed: onNext ?? _nextPage,
            style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(nextText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
