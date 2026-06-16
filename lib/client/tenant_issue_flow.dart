import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class TenantIssueFlowScreen extends StatefulWidget {
  const TenantIssueFlowScreen({super.key});

  @override
  State<TenantIssueFlowScreen> createState() => _TenantIssueFlowScreenState();
}

class _TenantIssueFlowScreenState extends State<TenantIssueFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedCaseType;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController depositController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  Map<String, PlatformFile?> uploadedFiles = {
    'rent_agreement': null,
    'payment_proof': null,
    'receipts': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<Map<String, dynamic>> caseTypes = [
    {"name": "Deposit Not Returned", "icon": Icons.money_off_rounded, "desc": "Security deposit issues"},
    {"name": "Forced Eviction", "icon": Icons.home_work_rounded, "desc": "Illegal eviction threats"},
    {"name": "Rent Dispute", "icon": Icons.payments_rounded, "desc": "Disagreement over rent amount"},
    {"name": "Agreement Violation", "icon": Icons.gavel_rounded, "desc": "Breach of rental terms"},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    addressController.dispose();
    ownerController.dispose();
    durationController.dispose();
    depositController.dispose();
    descriptionController.dispose();
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-tenant-issue');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['case_type'] = selectedCaseType ?? 'Tenant Issue'
        ..fields['property_address'] = addressController.text
        ..fields['owner_name'] = ownerController.text
        ..fields['duration_stay'] = durationController.text
        ..fields['deposit_amount'] = depositController.text
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

  final Color primaryColor = const Color(0xFF795548);
  final Color accentColor = const Color(0xFFA1887F);
  final Color successColor = const Color(0xFF43A047);
  final Color dangerColor = const Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Tenant Legal Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: primaryColor), onPressed: () => Navigator.pop(context)),
        actions: [
          Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Step ${_currentStep + 1}/8", style: GoogleFonts.inter(color: Colors.black54, fontWeight: FontWeight.bold)))),
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
          _step6Mediation(),
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
          _stepHeader("Dispute Type", "What kind of rental issue are you facing?"),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(type["icon"], color: isSelected ? primaryColor : Colors.grey, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(type["name"], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black87)),
                              Text(type["desc"], style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
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
          _stepHeader("Property Details", "Tell us about the property and stay."),
          _textField("Property Address", addressController, "e.g. Flat 101, Blue Plaza"),
          const SizedBox(height: 16),
          _textField("Owner / Landlord Name", ownerController, "Enter name (if known)"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _textField("Stay Duration", durationController, "e.g. 11 Months")),
              const SizedBox(width: 16),
              Expanded(child: _textField("Deposit Paid", depositController, "in INR", prefix: "₹ ")),
            ],
          ),
          const SizedBox(height: 16),
          Text("Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Explain the dispute in your own words...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: Colors.brown), onPressed: () {}),
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
          _stepHeader("Agreement & Proofs", "Upload documents to support your claim."),
          _uploadTile("Rental Agreement", "rent_agreement", "Important"),
          const SizedBox(height: 12),
          _uploadTile("Deposit Payment Proof", "payment_proof", "Recommended"),
          const SizedBox(height: 12),
          _uploadTile("Rent Receipts / Bills", "receipts", "Optional"),
          const Spacer(),
          TextButton(onPressed: _nextPage, child: const Center(child: Text("Skip / Upload Later"))),
          _navButtons(onNext: () {
            _submitToBackend();
            _nextPage();
          }, nextText: "Analyze Case"),
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
            Icon(Icons.house_siding_rounded, color: primaryColor),
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
            Text("AI Analyzing Rental Dispute...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
          _stepHeader("AI Analysis", "Detection and legal assessment."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: riskColor)),
            child: Row(
              children: [
                Icon(Icons.home_outlined, color: riskColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: riskColor)),
                  Text(selectedCaseType ?? 'Dispute', style: GoogleFonts.inter(fontSize: 12)),
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
          Text("Agreement Analysis", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['agreement_terms'] ?? 'Analyzing terms...', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 24),
          Text("Suggested Legal Steps", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['suggested_steps'] as List?) ?? []).map((step) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [Icon(Icons.check, size: 18, color: successColor), const SizedBox(width: 8), Expanded(child: Text(step.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
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
          _stepHeader("Legal Notice", "Auto-generated legal document."),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Text(_caseResult?['legal_notice'] ?? 'Drafting document...', style: GoogleFonts.inter(fontSize: 12, height: 1.6)),
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
          ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: successColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Proceed to Mediation")),
          const SizedBox(height: 40),
          _navButtons(nextText: "Resolution Steps"),
        ],
      ),
    );
  }

  Widget _step6Mediation() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Mediation Support", "Settle the dispute without court."),
          _mediationCard("Contact Neutral Mediator", "Resolve issues through professional mediation."),
          _mediationCard("Negotiation Strategy", "View AI-suggested points for talking to your landlord."),
          _mediationCard("Local Rent Control Info", "Check if your property falls under rent control laws."),
          const Spacer(),
          _navButtons(nextText: "Final Actions"),
        ],
      ),
    );
  }

  Widget _mediationCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryColor.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.handshake_outlined, color: primaryColor),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.black26),
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
          _stepHeader("Action Options", "Select your next course of action."),
          _actionButton("File Case with Rent Tribunal", Icons.gavel_rounded, () {}),
          _actionButton("Hire Property Lawyer", Icons.person_search_rounded, () {}),
          _actionButton("Save Draft for Later", Icons.save_rounded, () => Navigator.pop(context)),
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
          Icon(Icons.check_circle_rounded, size: 80, color: successColor),
          const SizedBox(height: 24),
          Text("Dispute Filed Successfully", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'TEN-2026-X8Y1Z2'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Submitted", "Completed on 02 May 2026", true),
          _trackingItem("Under Review", "Case assigned to legal expert", false),
          _trackingItem("Mediation", "Initial call pending", false),
          _trackingItem("Resolved", "Final settlement", false),
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
          Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: done ? successColor : Colors.grey),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: done ? primaryColor : Colors.black54)),
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
