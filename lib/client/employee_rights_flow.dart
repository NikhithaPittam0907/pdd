import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class EmployeeRightsFlowScreen extends StatefulWidget {
  const EmployeeRightsFlowScreen({super.key});

  @override
  State<EmployeeRightsFlowScreen> createState() => _EmployeeRightsFlowScreenState();
}

class _EmployeeRightsFlowScreenState extends State<EmployeeRightsFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedCaseType;
  final TextEditingController companyController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  Map<String, PlatformFile?> uploadedFiles = {
    'salary_slips': null,
    'offer_letter': null,
    'contract': null,
    'termination_letter': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<Map<String, dynamic>> caseTypes = [
    {"name": "Salary Not Paid", "icon": Icons.money_off_rounded},
    {"name": "Unfair Termination", "icon": Icons.person_remove_rounded},
    {"name": "Workplace Harassment", "icon": Icons.report_problem_rounded},
    {"name": "Contract Violation", "icon": Icons.history_edu_rounded},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    companyController.dispose();
    roleController.dispose();
    durationController.dispose();
    salaryController.dispose();
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
      allowedExtensions: ['pdf', 'jpg', 'png']
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-employee-right-case');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['case_type'] = selectedCaseType ?? 'Employee Rights'
        ..fields['company_name'] = companyController.text
        ..fields['job_role'] = roleController.text
        ..fields['duration_work'] = durationController.text
        ..fields['salary_pending'] = salaryController.text
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

  final Color primaryColor = const Color(0xFF3F51B5);
  final Color accentColor = const Color(0xFF7986CB);
  final Color successColor = const Color(0xFF43A047);
  final Color dangerColor = const Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Employee Rights Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: primaryColor), onPressed: () => Navigator.pop(context)),
        actions: [
          Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Step ${_currentStep + 1}/7", style: GoogleFonts.inter(color: Colors.black54, fontWeight: FontWeight.bold)))),
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
          _step5NoticeGenerator(),
          _step6Actions(),
          _step7Tracking(),
        ],
      ),
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
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
          _stepHeader("Case Type", "Select the type of employment issue."),
          Expanded(
            child: ListView.builder(
              itemCount: caseTypes.length,
              itemBuilder: (context, index) {
                final type = caseTypes[index];
                final isSelected = selectedCaseType == type["name"];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => selectedCaseType = type["name"]),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(type["icon"], color: isSelected ? primaryColor : Colors.grey),
                          const SizedBox(width: 16),
                          Text(type["name"], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black87)),
                          const Spacer(),
                          if (isSelected) Icon(Icons.check_circle, color: primaryColor),
                        ],
                      ),
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
          _stepHeader("Basic Details", "Provide employment information."),
          _textField("Company Name", companyController, "e.g. Tech Solutions Inc."),
          const SizedBox(height: 16),
          _textField("Job Role", roleController, "e.g. Senior Developer"),
          const SizedBox(height: 16),
          _textField("Duration of Work", durationController, "e.g. 2 Years, 4 Months"),
          const SizedBox(height: 16),
          _textField("Salary Amount Pending (if any)", salaryController, "Enter amount in INR", prefix: "₹ "),
          const SizedBox(height: 16),
          Text("Short Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Explain what happened in detail...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: Colors.blue), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 40),
          _navButtons(),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, String hint, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, prefixText: prefix, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
          _stepHeader("Document Upload", "Upload evidence to support your case."),
          Expanded(
            child: ListView(
              children: [
                _uploadTile("Salary Slips / Bank Statements", "salary_slips", "Recommended"),
                const SizedBox(height: 12),
                _uploadTile("Offer Letter / Contract", "offer_letter", "Important"),
                const SizedBox(height: 12),
                _uploadTile("Termination Letter (if any)", "termination_letter", "Optional"),
                const SizedBox(height: 12),
                _uploadTile("Email/Chat Screenshots", "contract", "Optional"),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
            Icon(Icons.upload_file_rounded, color: primaryColor),
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
            if (file != null) Icon(Icons.check_circle, color: successColor),
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
            Text("AI Analyzing Labor Dispute...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    final risk = _caseResult?['risk_level'] ?? 'MEDIUM';
    final riskColor = risk == 'HIGH' ? dangerColor : (risk == 'MEDIUM' ? Colors.orange : successColor);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("AI Analysis", "Violation detection and assessment."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: riskColor)),
            child: Row(
              children: [
                Icon(Icons.assignment_ind_rounded, color: riskColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: riskColor)),
                  Text("Risk Analysis:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on evidence.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text("Case Summary:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_caseResult?['case_summary'] ?? 'Case Overview', style: GoogleFonts.inter(fontSize: 12)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Detected Violations", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['violations_detected'] as List?) ?? ["Possible contract breach", "Unpaid wage detention"]).map((v) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [const Icon(Icons.error_outline, size: 18, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(v.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 24),
          Text("Suggested Legal Steps", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['suggested_steps'] as List?) ?? ["Issue a legal notice", "Consult a labor lawyer"]).map((step) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [const Icon(Icons.arrow_right_alt, size: 20), Expanded(child: Text(step.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 40),
          _navButtons(nextText: "Generate Notice"),
        ],
      ),
    );
  }

  Widget _step5NoticeGenerator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Legal Notice", "Auto-generated demand notice."),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Text(_caseResult?['legal_notice'] ?? 'Drafting notice...', style: GoogleFonts.inter(fontSize: 12, height: 1.6)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit_note), label: const Text("Edit"))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_for_offline), label: const Text("Download"), style: ElevatedButton.styleFrom(backgroundColor: primaryColor))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.send_rounded), label: const Text("Send to Labor Office"), style: ElevatedButton.styleFrom(backgroundColor: successColor, minimumSize: const Size(double.infinity, 50))),
          const SizedBox(height: 40),
          _navButtons(nextText: "Action Options"),
        ],
      ),
    );
  }

  Widget _step6Actions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Action Options", "What would you like to do next?"),
          _actionButton("File Formal Complaint", Icons.gavel_rounded, () {}),
          _actionButton("Contact Labor Lawyer", Icons.person_search_rounded, () {}),
          _actionButton("Save Case as Draft", Icons.save_as_rounded, () => Navigator.pop(context)),
          const Spacer(),
          _navButtons(nextText: "Finish"),
        ],
      ),
    );
  }

  Widget _step7Tracking() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 80, color: successColor),
          const SizedBox(height: 24),
          Text("Case Filed Successfully", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'EMP-2026-L9K1J2'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Submitted", "Complaint received on 02 May 2026", true),
          _trackingItem("Under Review", "Awaiting labor office response", false),
          _trackingItem("Action Taken", "Mediation scheduled", false),
          _trackingItem("Resolved", "Final settlement", false),
          const Spacer(),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Return to Dashboard")),
        ],
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap, 
        icon: Icon(icon, color: primaryColor), 
        label: Text(title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)), 
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
      ),
    );
  }

  Widget _trackingItem(String label, String status, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: done ? successColor : Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: done ? primaryColor : Colors.black54)),
                Text(status, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(nextText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
