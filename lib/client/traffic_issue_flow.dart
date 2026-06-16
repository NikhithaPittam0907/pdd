import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class TrafficIssueFlowScreen extends StatefulWidget {
  const TrafficIssueFlowScreen({super.key});

  @override
  State<TrafficIssueFlowScreen> createState() => _TrafficIssueFlowScreenState();
}

class _TrafficIssueFlowScreenState extends State<TrafficIssueFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedCaseType;
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  Map<String, PlatformFile?> uploadedFiles = {
    'evidence': null,
    'challan': null,
    'insurance': null,
    'rc': null,
    'dl': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<Map<String, dynamic>> caseTypes = [
    {"name": "Wrong Challan", "icon": Icons.assignment_late_outlined},
    {"name": "Accident Dispute", "icon": Icons.car_crash_outlined},
    {"name": "Insurance Claim", "icon": Icons.health_and_safety_outlined},
    {"name": "Traffic Fine Details", "icon": Icons.monetization_on_outlined},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    vehicleController.dispose();
    locationController.dispose();
    dateTimeController.dispose();
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
      allowedExtensions: ['pdf', 'jpg', 'png', 'mp4', 'mov', 'avi']
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-traffic-issue');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['case_type'] = selectedCaseType ?? 'Traffic Issue'
        ..fields['vehicle_number'] = vehicleController.text
        ..fields['location'] = locationController.text
        ..fields['date_time'] = dateTimeController.text
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

  final Color primaryColor = const Color(0xFF0B132B);
  final Color dangerColor = const Color(0xFFE53935);
  final Color successColor = const Color(0xFF388E3C);
  final Color accentColor = const Color(0xFF1C2C54);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Traffic Legal Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryColor)),
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
          _step5Generator(),
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
          _stepHeader("Case Type", "Select the type of traffic issue you are facing."),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: caseTypes.length,
              itemBuilder: (context, index) {
                final type = caseTypes[index];
                final isSelected = selectedCaseType == type["name"];
                return InkWell(
                  onTap: () => setState(() => selectedCaseType = type["name"]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type["icon"], size: 40, color: isSelected ? primaryColor : Colors.grey),
                        const SizedBox(height: 12),
                        Text(type["name"], textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? primaryColor : Colors.black87)),
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
          _stepHeader("Basic Details", "Provide information about the incident."),
          _textField("Vehicle Number", vehicleController, "e.g. MH 12 AB 1234"),
          const SizedBox(height: 16),
          _textField("Location", locationController, "e.g. MG Road, Pune"),
          const SizedBox(height: 16),
          _textField("Date and Time", dateTimeController, "e.g. 24 Oct 2025, 10:30 AM"),
          const SizedBox(height: 16),
          Text("Short Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Briefly explain what happened...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
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

  Widget _step3Evidence() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Evidence Upload", "Upload relevant documents and media."),
          Expanded(
            child: ListView(
              children: [
                _uploadTile("Accident Photos / Videos", "evidence", "Recommended"),
                const SizedBox(height: 12),
                _uploadTile("Challan Copy / FIR", "challan", "Important"),
                const SizedBox(height: 12),
                _uploadTile("Insurance Documents", "insurance", "Optional"),
                const SizedBox(height: 12),
                _uploadTile("RC / Driving License", "rc", "Optional"),
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
            Icon(Icons.cloud_upload_outlined, color: primaryColor),
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
            Text("AI Analyzing Traffic Issue...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    final risk = _caseResult?['risk_level'] ?? 'LOW';
    final riskColor = risk == 'HIGH' ? dangerColor : (risk == 'MEDIUM' ? Colors.orange : successColor);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("AI Analysis", "Detection and assessment results."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: riskColor)),
            child: Row(
              children: [
                Icon(Icons.security, color: riskColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: riskColor)),
                  Text(_caseResult?['issue_type'] ?? 'Detected Type', style: GoogleFonts.inter(fontSize: 12)),
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
          Text("Missing Documents", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          Wrap(spacing: 8, children: ((_caseResult?['missing_documents'] as List?) ?? []).map((s) => Chip(label: Text(s.toString(), style: const TextStyle(fontSize: 11)))).toList()),
          const SizedBox(height: 24),
          Text("Suggested Legal Steps", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['suggested_steps'] as List?) ?? []).map((step) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [Icon(Icons.arrow_right, size: 20), Expanded(child: Text(step.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 40),
          _navButtons(nextText: "Generate Appeal"),
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
          _stepHeader("Appeal / Document", "Auto-generated legal document."),
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
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text("Download"), style: ElevatedButton.styleFrom(backgroundColor: primaryColor))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: successColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Ready to Submit")),
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
          _actionButton("Appeal Challan", Icons.gavel, () {}),
          _actionButton("Contact Lawyer", Icons.person_search, () {}),
          _actionButton("Submit Insurance Claim", Icons.health_and_safety, () {}),
          _actionButton("Save as Draft", Icons.save_outlined, () => Navigator.pop(context)),
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
          Icon(Icons.check_circle_outline, size: 80, color: successColor),
          const SizedBox(height: 24),
          Text("Case Submitted", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'TRF-2026-X8Y2Z1'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Submitted", "Action completed on 02 May 2026", true),
          _trackingItem("Under Review", "AI analysis completed. Lawyer review pending.", false),
          _trackingItem("Action Taken", "Pending response from authorities", false),
          _trackingItem("Closed", "Final resolution", false),
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
          Column(
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? successColor : Colors.grey),
              if (label != "Closed") Container(width: 2, height: 30, color: Colors.grey.shade200),
            ],
          ),
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
          TextButton(onPressed: _prevPage, child: Text("Back", style: TextStyle(color: primaryColor))) 
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
