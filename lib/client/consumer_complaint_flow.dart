import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';

class ConsumerComplaintFlowScreen extends StatefulWidget {
  const ConsumerComplaintFlowScreen({super.key});

  @override
  State<ConsumerComplaintFlowScreen> createState() => _ConsumerComplaintFlowScreenState();
}

class _ConsumerComplaintFlowScreenState extends State<ConsumerComplaintFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Data
  String? selectedCaseType;
  final TextEditingController productController = TextEditingController();
  final TextEditingController sellerController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  Map<String, PlatformFile?> uploadedFiles = {
    'bill_invoice': null,
    'product_photos': null,
    'delivery_proof': null,
  };

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  final List<Map<String, dynamic>> caseTypes = [
    {"name": "Fake Product", "icon": Icons.shopping_basket_outlined},
    {"name": "Refund Not Received", "icon": Icons.money_off_rounded},
    {"name": "Defective Product", "icon": Icons.production_quantity_limits_rounded},
    {"name": "Poor Service", "icon": Icons.sentiment_very_dissatisfied_rounded},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    productController.dispose();
    sellerController.dispose();
    dateController.dispose();
    amountController.dispose();
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
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-consumer-complaint');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['case_type'] = selectedCaseType ?? 'Consumer Complaint'
        ..fields['product_name'] = productController.text
        ..fields['seller_name'] = sellerController.text
        ..fields['purchase_date'] = dateController.text
        ..fields['amount_paid'] = amountController.text
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

  final Color primaryColor = const Color(0xFF009688); // Teal
  final Color successColor = const Color(0xFF4CAF50);
  final Color dangerColor = const Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Consumer Assistant", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: primaryColor)),
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
          _stepHeader("Case Selection", "What issue are you reporting?"),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
          _stepHeader("Purchase Details", "Provide information about the transaction."),
          _textField("Product / Service Name", productController, "e.g. iPhone 15 Pro"),
          const SizedBox(height: 16),
          _textField("Seller / Company Name", sellerController, "e.g. Amazon India"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _textField("Purchase Date", dateController, "DD/MM/YYYY")),
              const SizedBox(width: 16),
              Expanded(child: _textField("Amount Paid", amountController, "in INR", prefix: "₹ ")),
            ],
          ),
          const SizedBox(height: 16),
          Text("Description", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Briefly explain the issue (e.g. product was broken on arrival)...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: Colors.teal), onPressed: () {}),
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
          _stepHeader("Evidence Upload", "Upload proofs to strengthen your claim."),
          _uploadTile("Bill / Invoice", "bill_invoice", "Important"),
          const SizedBox(height: 12),
          _uploadTile("Product Photos / Videos", "product_photos", "Recommended"),
          const SizedBox(height: 12),
          _uploadTile("Delivery Proof / Chats", "delivery_proof", "Optional"),
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
            Icon(Icons.add_shopping_cart_rounded, color: primaryColor),
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
            Text("AI Analyzing Consumer Dispute...", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
          _stepHeader("AI Analysis", "Detection and refund eligibility."),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: riskColor)),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, color: riskColor),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Risk Level: $risk", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: riskColor)),
                  Text("Refund Eligibility: ${_caseResult?['refund_eligibility'] ?? 'Analyzing...'}", style: GoogleFonts.inter(fontSize: 12)),
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
          Text("Suggested Legal Steps", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ...((_caseResult?['suggested_steps'] as List?) ?? []).map((step) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [Icon(Icons.arrow_right_alt_rounded, size: 20, color: primaryColor), const SizedBox(width: 8), Expanded(child: Text(step.toString(), style: GoogleFonts.inter(fontSize: 13)))]),
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
          _stepHeader("Complaint / Letter", "Auto-generated legal document."),
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
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download_outlined), label: const Text("Download"), style: ElevatedButton.styleFrom(backgroundColor: primaryColor))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: successColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Ready to Request Refund")),
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
          _stepHeader("Action Options", "Select your next course of action."),
          _actionButton("File Case in Consumer Court", Icons.gavel_rounded, () {}),
          _actionButton("Connect with Consumer Lawyer", Icons.person_search_rounded, () {}),
          _actionButton("Request Direct Refund", Icons.monetization_on_outlined, () {}),
          _actionButton("Save as Draft", Icons.save_outlined, () => Navigator.pop(context)),
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

  Widget _step7Tracking() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_rounded, size: 80, color: successColor),
          const SizedBox(height: 24),
          Text("Complaint Registered", style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("Case ID: ${_caseResult?['case_id'] ?? 'CON-2026-T9R1P2'}", style: GoogleFonts.inter(color: Colors.black54)),
          const SizedBox(height: 40),
          _trackingItem("Refund Requested", "Sent to Amazon India on 02 May", true),
          _trackingItem("Processing", "Under review by seller", false),
          _trackingItem("Resolution", "Awaiting outcome", false),
          const Spacer(),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("Return to Dashboard")),
        ],
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
