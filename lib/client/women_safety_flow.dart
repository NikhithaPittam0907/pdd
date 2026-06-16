import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class WomenSafetyFlowScreen extends StatefulWidget {
  const WomenSafetyFlowScreen({super.key});

  @override
  State<WomenSafetyFlowScreen> createState() => _WomenSafetyFlowScreenState();
}

class _WomenSafetyFlowScreenState extends State<WomenSafetyFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  final TextEditingController quickDescriptionController = TextEditingController();
  String currentLocation = "Detecting location...";
  
  Map<String, PlatformFile?> uploadedFiles = {
    'evidence': null,
    'audio': null,
    'video': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  void _detectLocation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => currentLocation = "MG Road, Pune, Maharashtra");
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    quickDescriptionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 7) {
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
      allowedExtensions: ['pdf', 'jpg', 'png', 'mp4', 'mp3', 'wav']
    );
    if (result != null) {
      setState(() {
        uploadedFiles[category] = result.files.first;
      });
    }
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-women-safety-report');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['description'] = quickDescriptionController.text.isEmpty ? "Quick complaint" : quickDescriptionController.text
        ..fields['location'] = currentLocation;

      for (var entry in uploadedFiles.entries) {
        if (entry.value?.path != null) {
          req.files.add(await http.MultipartFile.fromPath(entry.key, entry.value!.path!));
        }
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

  final Color primaryColor = const Color(0xFFD81B60);
  final Color dangerColor = const Color(0xFFB71C1C);
  final Color successColor = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Women Safety Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Step ${_currentStep + 1}/8", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold)))),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _step1Emergency(),
          _step2QuickComplaint(),
          _step3Evidence(),
          _step4AIAnalysis(),
          _step5Rights(),
          _step6NearbyHelp(),
          _step7Actions(),
          _step8Tracking(),
        ],
      ),
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _step1Emergency() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _stepHeader("Emergency Actions", "Immediate help is one tap away."),
          const Spacer(),
          _emergencyAction(Icons.phone, "Call Police", Colors.blue, () {}),
          _emergencyAction(Icons.location_on, "Share Live Location", Colors.orange, () {}),
          _emergencyAction(Icons.people, "Notify Contacts", Colors.green, () {}),
          const Spacer(),
          _navButtons(nextText: "Proceed to Report"),
        ],
      ),
    );
  }

  Widget _emergencyAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap, 
        icon: Icon(icon, color: Colors.white), 
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _step2QuickComplaint() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Quick Complaint", "Report the incident instantly."),
          Text("What happened?", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: quickDescriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Briefly describe the situation or record voice...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: Colors.red), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 24),
          Text("Current Location", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(currentLocation, style: GoogleFonts.inter(fontSize: 14))),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _navButtons(onNext: () {
            _submitReport();
            _nextPage();
          }, nextText: "Submit & Analyze"),
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
          _stepHeader("Evidence Upload", "Upload proof to strengthen the case."),
          _uploadTile("Photos / Videos", "evidence", "Recommended"),
          const SizedBox(height: 12),
          _uploadTile("Audio Recordings", "audio", "Important"),
          const SizedBox(height: 12),
          _uploadTile("Screenshots / Documents", "video", "Optional"),
          const Spacer(),
          TextButton(onPressed: _nextPage, child: const Center(child: Text("Skip / Upload Later"))),
          _navButtons(),
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

  Widget _step4AIAnalysis() {
    if (_isSubmitting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text("AI Analyzing Situation...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    final risk = _caseResult?['risk_level'] ?? 'HIGH';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("AI Assistance", "Situation analysis and safety advice."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: dangerColor)),
            child: Row(
              children: [
                Icon(Icons.warning, color: dangerColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: dangerColor)),
                  Text("Risk Analysis:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on evidence.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text("Case Summary:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_caseResult?['case_summary'] ?? 'Emergency Alert', style: GoogleFonts.inter(fontSize: 12)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Safety Advice", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['safety_advice'] as List?) ?? ["Seek safe harbor immediately", "Keep emergency contacts updated"]).map((tip) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [const Icon(Icons.shield, size: 18, color: Colors.blue), const SizedBox(width: 8), Expanded(child: Text(tip.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 24),
          Text("Suggested Legal Actions", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['legal_actions'] as List?) ?? ["File FIR", "Contact protection officer"]).map((action) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [const Icon(Icons.gavel, size: 18, color: Colors.orange), const SizedBox(width: 8), Expanded(child: Text(action.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 40),
          _navButtons(nextText: "View My Rights"),
        ],
      ),
    );
  }

  Widget _step5Rights() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Legal Rights", "Understand your protections under law."),
          _rightCard("Zero FIR", "You can file an FIR at any police station regardless of jurisdiction."),
          _rightCard("Privacy", "Your identity is protected by law in cases of harassment or abuse."),
          _rightCard("Free Legal Aid", "Victims are entitled to free legal assistance from the state."),
          const SizedBox(height: 24),
          Text("Expert Info:", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          Text(_caseResult?['rights_info'] ?? "Under the IPC and Women Protection Acts, you have multiple safeguards for your safety and dignity.", style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
          const SizedBox(height: 40),
          _navButtons(nextText: "Find Nearby Help"),
        ],
      ),
    );
  }

  Widget _rightCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade900)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _step6NearbyHelp() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Nearby Help", "Police stations and helplines nearby."),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
            child: const Center(child: Icon(Icons.map, size: 64, color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          Text("Emergency Helplines", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _helplineTile("Women Helpline", "1091"),
          _helplineTile("Police Emergency", "100"),
          _helplineTile("Anti-Harassment Cell", "181"),
          const Spacer(),
          _navButtons(nextText: "Final Actions"),
        ],
      ),
    );
  }

  Widget _helplineTile(String label, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(number, style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 12),
          const Icon(Icons.phone, size: 18, color: Colors.green),
        ],
      ),
    );
  }

  Widget _step7Actions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Action Options", "Select your next step."),
          _actionButton("File Formal Complaint", Icons.description, () {}),
          _actionButton("Connect with Female Lawyer", Icons.person_search, () {}),
          _actionButton("Secure Evidence Folder", Icons.folder_shared, () {}),
          _actionButton("Save Draft & Exit", Icons.save_outlined, () => Navigator.pop(context)),
          const Spacer(),
          _navButtons(nextText: "Finish"),
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

  Widget _step8Tracking() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 80, color: successColor),
          const SizedBox(height: 24),
          Text("Report Successfully Filed", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'WSF-2026-R4T5Y1'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Police Review", "In Progress", false),
          _trackingItem("Protection Assigned", "Pending", false),
          const Spacer(),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Return to Home")),
        ],
      ),
    );
  }

  Widget _trackingItem(String label, String status, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? successColor : Colors.grey),
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
        if (_currentStep > 0 && _currentStep < 7) 
          TextButton(onPressed: _prevPage, child: const Text("Back", style: TextStyle(color: Colors.black54))) 
        else const SizedBox(),
        if (_currentStep < 7) 
          ElevatedButton(
            onPressed: onNext ?? _nextPage,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(nextText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
