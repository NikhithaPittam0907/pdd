import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class AccidentClaimFlowScreen extends StatefulWidget {
  const AccidentClaimFlowScreen({super.key});

  @override
  State<AccidentClaimFlowScreen> createState() => _AccidentClaimFlowScreenState();
}

class _AccidentClaimFlowScreenState extends State<AccidentClaimFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedCaseType;
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  Map<String, PlatformFile?> uploadedFiles = {
    'police_reports': null,
    'medical_reports': null,
    'insurance_policy': null,
    'accident_photos': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<Map<String, dynamic>> caseTypes = [
    {"name": "Minor Accident", "icon": Icons.car_crash_rounded, "desc": "Minimal vehicle damage, no injuries"},
    {"name": "Major Accident", "icon": Icons.dangerous_rounded, "desc": "Significant damage or multiple vehicles"},
    {"name": "Injury Claim", "icon": Icons.personal_injury_rounded, "desc": "Physical injury or medical expenses"},
    {"name": "Insurance Claim", "icon": Icons.security_rounded, "desc": "Seeking repair or theft settlement"},
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
    if (_currentStep < 8) {
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
      allowedExtensions: ['pdf', 'jpg', 'png', 'mp4']
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-accident-claim');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['case_type'] = selectedCaseType ?? 'Accident Claim'
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

  final Color primaryColor = const Color(0xFFE53935); // Red
  final Color secondaryColor = const Color(0xFF263238); // Dark Grey

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Accident Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Step ${_currentStep + 1}/9", style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold)))),
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
          _step5FIRGuide(),
          _step6Calculator(),
          _step7Support(),
          _step8Advocates(),
          _step9Tracking(),
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
          _stepHeader("Select Case Type", "Help us understand the severity of the accident."),
          Expanded(
            child: ListView.builder(
              itemCount: caseTypes.length,
              itemBuilder: (context, index) {
                final type = caseTypes[index];
                final isSelected = selectedCaseType == type["name"];
                return InkWell(
                  onTap: () => setState(() => selectedCaseType = type["name"]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(type["icon"], color: isSelected ? primaryColor : Colors.grey, size: 30),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(type["name"], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black87)),
                          Text(type["desc"], style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                        ])),
                        if (isSelected) Icon(Icons.check_circle, color: primaryColor),
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
          _stepHeader("Basic Details", "Provide core information about the incident."),
          _textField("Vehicle Number", vehicleController, "e.g. MH 01 AB 1234"),
          const SizedBox(height: 16),
          _textField("Location of Accident", locationController, "e.g. Link Road, Andheri West"),
          const SizedBox(height: 16),
          _textField("Date and Time", dateTimeController, "e.g. 02 May 2026, 10:30 AM"),
          const SizedBox(height: 16),
          Text("Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Briefly explain how the accident happened...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: Colors.red), onPressed: () {}),
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
          _stepHeader("Evidence & Documents", "Upload proofs to strengthen your claim."),
          Expanded(
            child: ListView(
              children: [
                _uploadTile("FIR / Police Report / DL", "police_reports", "Important"),
                const SizedBox(height: 12),
                _uploadTile("Accident Photos / Videos", "accident_photos", "Recommended"),
                const SizedBox(height: 12),
                _uploadTile("Medical Reports / Bills", "medical_reports", "Medical"),
                const SizedBox(height: 12),
                _uploadTile("Insurance Policy / Claim Form", "insurance_policy", "Insurance"),
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

  Widget _uploadTile(String title, String category, String tag) {
    final file = uploadedFiles[category];
    return InkWell(
      onTap: () => _pickFile(category),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Icon(Icons.file_present_rounded, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(file?.name ?? "No file selected ($tag)", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
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
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 24),
            Text("AI Analyzing Accident Data...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
          _stepHeader("AI Assessment", "Damage analysis and next steps."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: riskColor)),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: riskColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: riskColor)),
                  Text(selectedCaseType ?? 'Accident Claim', style: GoogleFonts.inter(fontSize: 12)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Damage Assessment", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['damage_assessment'] ?? 'N/A', style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          Text("Suggested Legal Steps", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['suggested_steps'] as List?) ?? []).map((step) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(step.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
          )).toList(),
          const SizedBox(height: 40),
          _navButtons(nextText: "FIR Guide"),
        ],
      ),
    );
  }

  Widget _step5FIRGuide() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("FIR & Checklist", "Step-by-step guidance for legal filings."),
          Expanded(
            child: ListView(
              children: [
                _guideItem("Step 1", "Visit the nearest Police Station to the accident spot.", true),
                _guideItem("Step 2", "Provide written or oral statement of the incident.", true),
                _guideItem("Step 3", "Collect a copy of the FIR (Zero FIR if needed).", false),
                const SizedBox(height: 24),
                Text("Required Documents Checklist", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _checkItem("Copy of FIR / Police Report"),
                _checkItem("Medical Reports (if injured)"),
                _checkItem("Insurance Policy Document"),
                _checkItem("Driver's License & RC Copy"),
              ],
            ),
          ),
          _navButtons(nextText: "Claim Calculator"),
        ],
      ),
    );
  }

  Widget _guideItem(String step, String desc, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: done ? Colors.green : Colors.grey, radius: 15, child: Text(step.split(" ")[1], style: const TextStyle(fontSize: 12, color: Colors.white))),
          const SizedBox(width: 16),
          Expanded(child: Text(desc, style: GoogleFonts.inter(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.check_box_outline_blank, size: 20, color: Colors.grey), const SizedBox(width: 12), Text(text, style: GoogleFonts.inter(fontSize: 13))]));
  }

  Widget _step6Calculator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _stepHeader("Compensation Calculator", "Estimated amount based on damages."),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: Colors.red, width: 2)),
            child: Column(
              children: [
                Text("Estimated Claim", style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
                Text(_caseResult?['compensation_estimate'] ?? "Calculating...", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Note: This is an AI-powered estimate. Actual claims may vary based on court rulings and insurance policies.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
          const Spacer(),
          _navButtons(nextText: "Legal Support"),
        ],
      ),
    );
  }

  Widget _step7Support() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Legal Support", "Auto-generated claim application."),
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
          ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)), child: const Text("Ready to Connect with Lawyer")),
          const SizedBox(height: 40),
          _navButtons(nextText: "Advocate Connect"),
        ],
      ),
    );
  }

  Widget _step8Advocates() {
    final List<Map<String, String>> lawyers = [
      {"name": "Adv. Rajesh Kumar", "exp": "12 Years", "rating": "4.8"},
      {"name": "Adv. Priya Singh", "exp": "8 Years", "rating": "4.9"},
      {"name": "Adv. Amit Mehra", "exp": "15 Years", "rating": "4.7"},
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Advocate Connect", "Book a consultation with experts."),
          Expanded(
            child: ListView.builder(
              itemCount: lawyers.length,
              itemBuilder: (context, index) {
                final lawyer = lawyers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lawyer["name"]!, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        Text("${lawyer["exp"]} Exp • ⭐ ${lawyer["rating"]}", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                      ])),
                      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 12)), child: const Text("Book", style: TextStyle(fontSize: 12))),
                    ],
                  ),
                );
              },
            ),
          ),
          _navButtons(nextText: "Finish"),
        ],
      ),
    );
  }

  Widget _step9Tracking() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.car_crash_rounded, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          Text("Claim Filed Successfully", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'ACC-2026-X1Y2Z3'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Submitted", "Completed on 02 May 2026", true),
          _trackingItem("Under Review", "Case assigned to claim expert", false),
          _trackingItem("Insurance Processing", "Awaiting verification", false),
          _trackingItem("Claim Approved", "Final settlement", false),
          const Spacer(),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Back to Dashboard")),
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
        if (_currentStep > 0 && _currentStep < 8) 
          TextButton(onPressed: _prevPage, child: const Text("Back", style: TextStyle(color: Colors.black54))) 
        else const SizedBox(),
        if (_currentStep < 8) 
          ElevatedButton(
            onPressed: onNext ?? _nextPage,
            style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(nextText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
