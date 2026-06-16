import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class CyberCrimeFlowScreen extends StatefulWidget {
  const CyberCrimeFlowScreen({super.key});

  @override
  State<CyberCrimeFlowScreen> createState() => _CyberCrimeFlowScreenState();
}

class _CyberCrimeFlowScreenState extends State<CyberCrimeFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedIncidentType;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  PlatformFile? evidenceFile;
  PlatformFile? paymentProofFile;

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<String> incidentTypes = [
    "UPI / Bank Fraud",
    "Phishing Email",
    "Fake Website",
    "Hacking / Account Theft",
    "Scam Calls / Messages"
  ];

  @override
  void dispose() {
    _pageController.dispose();
    descriptionController.dispose();
    amountController.dispose();
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

  Future<void> _pickFile(bool isEvidence) async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png', 'docx']);
    if (result != null) {
      setState(() {
        if (isEvidence) evidenceFile = result.files.first;
        else paymentProofFile = result.files.first;
      });
    }
  }

  Future<void> _submitToBackend() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-cyber-crime');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['incident_type'] = selectedIncidentType ?? 'Cyber Crime'
        ..fields['description'] = descriptionController.text
        ..fields['amount'] = amountController.text;

      if (evidenceFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('evidence', evidenceFile!.path!));
      }
      if (paymentProofFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('id_proof', paymentProofFile!.path!));
      }

      final streamed = await req.send().timeout(const Duration(seconds: 40));
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

  final Color primaryColor = const Color(0xFF0B132B);
  final Color cyberBlue = const Color(0xFF1C2C54);
  final Color dangerColor = const Color(0xFFE53935);
  final Color successColor = const Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Cyber Crime Report", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryColor)),
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
          _step3Evidence(),
          _step4Analysis(),
          _step5Draft(),
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
          _stepHeader("Incident Type", "What kind of cyber crime are you reporting?"),
          Expanded(
            child: ListView(
              children: incidentTypes.map((type) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => selectedIncidentType = type),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selectedIncidentType == type ? primaryColor.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selectedIncidentType == type ? primaryColor : Colors.grey.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: selectedIncidentType == type ? primaryColor : Colors.grey),
                        const SizedBox(width: 16),
                        Text(type, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: selectedIncidentType == type ? primaryColor : Colors.black87)),
                        const Spacer(),
                        if (selectedIncidentType == type) Icon(Icons.check_circle, color: primaryColor),
                      ],
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _navButtons(onNext: selectedIncidentType != null ? _nextPage : null),
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
          _stepHeader("Incident Details", "Tell us more about what happened."),
          Text("Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: InputDecoration(hintText: "Explain the incident, messages received, or suspicious activity...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
          Text("Amount Lost (if any)", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter amount in INR", prefixText: "₹ ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 40),
          _navButtons(),
        ],
      ),
    );
  }

  Widget _step3Evidence() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Evidence Upload", "Upload screenshots, receipts, or call logs."),
          _uploadTile("Screenshots (Chats/Emails)", evidenceFile, () => _pickFile(true)),
          const SizedBox(height: 16),
          _uploadTile("Payment Proof (Receipts)", paymentProofFile, () => _pickFile(false)),
          const Spacer(),
          _navButtons(onNext: () {
            _submitToBackend();
            _nextPage();
          }, nextText: "Analyze Case"),
        ],
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
            Text("AI Analyzing Cyber Incident...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    final risk = _caseResult?['risk_level'] ?? 'MEDIUM';
    final fraud = _caseResult?['fraud_type_detected'] ?? 'Detected';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("AI Analysis", "Fraud detection and risk assessment."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: risk == 'HIGH' ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.warning, color: risk == 'HIGH' ? dangerColor : Colors.blue),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: risk == 'HIGH' ? dangerColor : Colors.blue)),
                  Text(fraud, style: GoogleFonts.inter(fontSize: 12)),
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
          Text(_caseResult?['case_summary'] ?? 'N/A', style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          Text("Suggested Legal Sections", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          Wrap(spacing: 8, children: ((_caseResult?['suggested_sections'] as List?) ?? []).map((s) => Chip(label: Text(s.toString(), style: const TextStyle(fontSize: 10)))).toList()),
          const SizedBox(height: 40),
          _navButtons(nextText: "Review Complaint"),
        ],
      ),
    );
  }

  Widget _step5Draft() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Complaint Draft", "Review the auto-generated complaint."),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Text(_caseResult?['complaint_draft'] ?? 'Drafting...', style: GoogleFonts.inter(fontSize: 12, height: 1.6)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text("Download PDF"), style: ElevatedButton.styleFrom(backgroundColor: primaryColor)),
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
          _actionButton("Report to Cyber Crime Portal", Icons.language, () {}),
          _actionButton("Contact Police", Icons.local_police, () {}),
          _actionButton("Save as Draft", Icons.save, () => Navigator.pop(context)),
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
          Icon(Icons.check_circle, size: 80, color: successColor),
          const SizedBox(height: 24),
          Text("Submitted Successfully", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'N/A'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Submitted", "Completed", true),
          _trackingItem("Police Review", "Pending", false),
          _trackingItem("Investigation", "Pending", false),
          const Spacer(),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Return to Dashboard")),
        ],
      ),
    );
  }

  Widget _uploadTile(String title, PlatformFile? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)),
        child: Row(children: [
          Icon(Icons.cloud_upload, color: primaryColor),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(file?.name ?? "No file selected", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          ])),
          if (file != null) Icon(Icons.check_circle, color: successColor),
        ]),
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, color: primaryColor), label: Text(title, style: TextStyle(color: primaryColor)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16))),
    );
  }

  Widget _trackingItem(String label, String status, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? successColor : Colors.grey),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          Text(status, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
        ]),
      ]),
    );
  }

  Widget _navButtons({VoidCallback? onNext, String nextText = "Next"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0 && _currentStep < 6) TextButton(onPressed: _prevPage, child: const Text("Back")) else const SizedBox(),
        if (_currentStep < 6) ElevatedButton(
          onPressed: onNext ?? _nextPage,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
          child: Text(nextText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
