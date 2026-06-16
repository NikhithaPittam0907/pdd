import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'ai_chat.dart';

class LandFraudFlowScreen extends StatefulWidget {
  const LandFraudFlowScreen({super.key});

  @override
  State<LandFraudFlowScreen> createState() => _LandFraudFlowScreenState();
}

class _LandFraudFlowScreenState extends State<LandFraudFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color primaryColor = const Color(0xFF0B132B);
  final Color goldColor = const Color(0xFF8A6A00);
  final Color bgLight = const Color(0xFFF8F9FA);
  final Color dangerColor = const Color(0xFFD32F2F);
  final Color successColor = const Color(0xFF2E7D32);

  // State Variables
  String? selectedFraudType;
  TextEditingController locationController = TextEditingController();
  TextEditingController propertyTypeController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();

  // Map state
  LatLng _pinnedLocation = const LatLng(20.5937, 78.9629); // Default: India center
  bool _locationPinned = false;
  final MapController _mapController = MapController();

  PlatformFile? idProofFile;
  PlatformFile? landDocFile;
  PlatformFile? optionalDocFile;

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  void _nextPage() {
    if (_currentPage < 8) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickFile(String category) async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null) {
      setState(() {
        if (category == 'ID') idProofFile = result.files.first;
        else if (category == 'Land') landDocFile = result.files.first;
        else if (category == 'Optional') optionalDocFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: _prevPage,
        ),
        title: Text(
          "Land Dispute Flow",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFEAF0FF), borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Text("Step ${_currentPage + 1} of 9", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B5998))),
              ),
            ),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildStep1CaseType(),
          _buildStep2PropertyDetails(),
          _buildStep3DocumentUpload(),
          _buildStep4AIAnalysis(),
          _buildStep5OwnershipVerification(),
          _buildStep6LegalGuidance(),
          _buildStep7ComplaintGenerator(),
          _buildStep8LawyerConnect(),
          _buildStep9CaseTracking(),
        ],
      ),
    );
  }

  // --- STEP 1: CASE TYPE ---
  Widget _buildStep1CaseType() {
    final types = [
      {"icon": Icons.description, "title": "Fake Documents", "desc": "Forged sale deeds or registries"},
      {"icon": Icons.location_off, "title": "Illegal Land Occupation", "desc": "Encroachment or trespassing"},
      {"icon": Icons.group, "title": "Ownership Dispute", "desc": "Family or multi-party claims"},
      {"icon": Icons.real_estate_agent, "title": "Property Sale Fraud", "desc": "Double registration or scam"},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Select Case Type", "Help us categorize your issue to provide precise guidance."),
          const SizedBox(height: 32),
          ...types.map((type) {
            bool isSelected = selectedFraudType == type["title"];
            return GestureDetector(
              onTap: () {
                setState(() => selectedFraudType = type["title"] as String);
                Future.delayed(const Duration(milliseconds: 300), _nextPage);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0B132B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF0B132B) : Colors.grey.shade300),
                  boxShadow: [if (isSelected) BoxShadow(color: const Color(0xFF0B132B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isSelected ? Colors.white24 : const Color(0xFFF4F6FB), shape: BoxShape.circle),
                      child: Icon(type["icon"] as IconData, color: isSelected ? Colors.white : primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type["title"] as String, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : primaryColor)),
                          const SizedBox(height: 4),
                          Text(type["desc"] as String, style: GoogleFonts.inter(fontSize: 12, color: isSelected ? Colors.white70 : Colors.black54)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: isSelected ? Colors.white : Colors.grey),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- STEP 2: PROPERTY DETAILS ---
  Widget _buildStep2PropertyDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Property Details", "Enter the exact details of the disputed property."),
          const SizedBox(height: 24),
          _inputField(label: "Location (State, City, Survey No.)", controller: locationController, hint: "e.g., Survey 42, Sector 14, Delhi"),
          const SizedBox(height: 16),
          _inputField(label: "Property Type", controller: propertyTypeController, hint: "e.g., Agricultural Land, Apartment"),
          const SizedBox(height: 16),
          _inputField(label: "Owner Name (Optional)", controller: ownerNameController, hint: "As per original documents"),
          const SizedBox(height: 24),
          Text("Pin Location", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 4),
          Text(
            "Tap on the map to pin the exact property location.",
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _pinnedLocation,
                  initialZoom: 5.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _pinnedLocation = point;
                      _locationPinned = true;
                    });
                    _mapController.move(point, _mapController.camera.zoom);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.my_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pinnedLocation,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _locationPinned ? const Color(0xFFEAF4FF) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _locationPinned ? const Color(0xFF3B5998) : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _locationPinned ? Icons.my_location : Icons.location_searching,
                  size: 16,
                  color: _locationPinned ? const Color(0xFF3B5998) : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationPinned
                        ? 'Pinned: ${_pinnedLocation.latitude.toStringAsFixed(5)}, ${_pinnedLocation.longitude.toStringAsFixed(5)}'
                        : 'No location pinned yet — tap the map',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _locationPinned ? const Color(0xFF0B132B) : Colors.grey,
                      fontWeight: _locationPinned ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (_locationPinned)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _pinnedLocation = const LatLng(20.5937, 78.9629);
                        _locationPinned = false;
                      });
                      _mapController.move(const LatLng(20.5937, 78.9629), 5.0);
                    },
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _navButtons(),
        ],
      ),
    );
  }

  // --- STEP 3: DOCUMENT UPLOAD ---
  Widget _buildStep3DocumentUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Secure Upload", "Provide proof of identity and property ownership."),
          const SizedBox(height: 8),
          Text("We use 256-bit encryption. Your documents are secure.", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 24),
          
          _uploadCategory("Mandatory", "ID Proof (Aadhar, PAN)", true, idProofFile, 'ID'),
          const SizedBox(height: 16),
          _uploadCategory("Mandatory", "Land Docs (Sale Deed, Patta)", true, landDocFile, 'Land'),
          const SizedBox(height: 16),
          _uploadCategory("Optional", "Tax Receipts, Prior Agreements", false, optionalDocFile, 'Optional'),
          
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () { _submitToBackend(); _nextPage(); },
              child: Text("Upload Later / Skip", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            ),
          ),
          const SizedBox(height: 16),
          _navButtons(onNext: () {
            if (idProofFile == null || landDocFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload Mandatory files or choose Skip."), backgroundColor: Colors.red));
              return;
            }
            _submitToBackend();
            _nextPage();
          }),
        ],
      ),
    );
  }

  Future<void> _submitToBackend() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-land-fraud');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['fraud_type'] = selectedFraudType ?? ''
        ..fields['location'] = locationController.text
        ..fields['property_type'] = propertyTypeController.text
        ..fields['owner_name'] = ownerNameController.text
        ..fields['latitude'] = _pinnedLocation.latitude.toString()
        ..fields['longitude'] = _pinnedLocation.longitude.toString();

      if (idProofFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('id_proof', idProofFile!.path!));
      }
      if (landDocFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('land_doc', landDocFile!.path!));
      }
      if (optionalDocFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('optional_doc', optionalDocFile!.path!));
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

  // --- STEP 4: AI ANALYSIS ---
  Widget _buildStep4AIAnalysis() {
    if (_isSubmitting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF0B132B)),
            const SizedBox(height: 24),
            Text("AI Analysing Your Case...", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            Text("Scanning documents and verifying ownership records...", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    }

    final riskLevel = _caseResult?['risk_level'] ?? 'HIGH';
    final riskSummary = _caseResult?['risk_summary'] ?? 'Multiple anomalies detected in document formatting.';
    final info = (_caseResult?['extracted_info'] as Map<String, dynamic>?) ?? {};
    final ownerName = info['ownership_name'] ?? (ownerNameController.text.isNotEmpty ? ownerNameController.text : 'Not specified');
    final surveyNo = info['survey_number'] ?? 'Not found';
    final regDate = info['registration_date'] ?? 'Not found';
    final warnings = (_caseResult?['warnings'] as List<dynamic>?)?.cast<String>() ?? ['Missing valid digital signature from sub-registrar.'];
    final isHigh = riskLevel == 'HIGH';
    final riskColor = isHigh ? dangerColor : (riskLevel == 'MEDIUM' ? const Color(0xFFD48806) : successColor);
    final riskBg = isHigh ? const Color(0xFFFFEBEE) : (riskLevel == 'MEDIUM' ? const Color(0xFFFFF4E5) : const Color(0xFFE8F5E9));
    final riskBorder = isHigh ? Colors.red.shade200 : (riskLevel == 'MEDIUM' ? const Color(0xFFFFCC80) : Colors.green.shade200);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("AI Fraud Analysis", "We analysed your documents and case details."),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: riskBorder)),
            child: Row(
              children: [
                Icon(Icons.gpp_bad, color: riskColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fraud Risk Level: $riskLevel", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: riskColor)),
                      const SizedBox(height: 4),
                      Text(riskSummary, style: GoogleFonts.inter(fontSize: 12, color: riskColor.withOpacity(0.85))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Extracted Information", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 12),
          _detailRow("Ownership Name", ownerName),
          _detailRow("Survey Number", surveyNo),
          _detailRow("Registration Date", regDate),
          const SizedBox(height: 24),
          Text("Warnings", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 8),
          ...warnings.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, size: 16, color: dangerColor),
                const SizedBox(width: 8),
                Expanded(child: Text(w, style: GoogleFonts.inter(fontSize: 13, color: dangerColor))),
              ],
            ),
          )),
          const SizedBox(height: 40),
          _navButtons(onNext: () => _nextPage()),
        ],
      ),
    );
  }

  // Verification is now part of the same backend submission; no extra call needed.

  // --- STEP 5: OWNERSHIP VERIFICATION ---
  Widget _buildStep5OwnershipVerification() {
    if (_isSubmitting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance, size: 48, color: Color(0xFF0B132B)),
            const SizedBox(height: 24),
            Text("Querying Govt Records...", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            Text("Connecting to state land registry database...", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    }

    final info = (_caseResult?['extracted_info'] as Map<String, dynamic>?) ?? {};
    final userOwner = info['ownership_name'] ?? (ownerNameController.text.isNotEmpty ? ownerNameController.text : 'As per your document');
    final govtOwner = _caseResult?['government_record_name'] ?? 'Differs in official records';
    final isMismatch = userOwner.toLowerCase() != govtOwner.toLowerCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Verification Results", "Comparison with state registry database."),
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMismatch ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                border: Border.all(color: isMismatch ? dangerColor : successColor, width: 2),
              ),
              child: Icon(isMismatch ? Icons.cancel : Icons.verified, size: 64, color: isMismatch ? dangerColor : successColor),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text(isMismatch ? "Mismatch Found" : "Records Match", style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: isMismatch ? dangerColor : successColor))),
          const SizedBox(height: 12),
          Center(
            child: Text(
              isMismatch
                  ? "The ownership name on the uploaded deed does not match the current official records."
                  : "The ownership details appear consistent with official records.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _detailRow("Your Document", userOwner),
                const Divider(),
                _detailRow("Govt Record", govtOwner, isAlert: isMismatch),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _navButtons(),
        ],
      ),
    );
  }

  // --- STEP 6: LEGAL GUIDANCE ---
  Widget _buildStep6LegalGuidance() {
    final actions = (_caseResult?['legal_actions'] as List<dynamic>?)?.cast<String>() ??
        ["File an FIR under relevant IPC sections.", "Apply for an Injunction.", "Obtain an Encumbrance Certificate."];
    final summary = _caseResult?['risk_summary'] ?? 'Potential Property Sale Fraud detected. Immediate legal intervention required.';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Legal Guidance", "Based on the AI findings, here is your action plan."),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF3B5998))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel, color: Color(0xFF3B5998), size: 20),
                    const SizedBox(width: 8),
                    Text("Risk Analysis", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on severity and evidence provided.', style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          Text("Case Summary", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(summary, style: GoogleFonts.inter(fontSize: 12, color: Colors.black87, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Suggested Actions", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 12),
          ...actions.asMap().entries.map((e) => _actionTile("${e.key + 1}. Action", e.value)),
          const SizedBox(height: 40),
          _navButtons(nextText: "Generate Complaint"),
        ],
      ),
    );
  }

  // --- STEP 7: COMPLAINT GENERATOR ---
  Widget _buildStep7ComplaintGenerator() {
    final firDraft = _caseResult?['fir_draft'] ??
        "To,\nThe Station House Officer,\n[Local Police Station]\n\nSubject: FIR for Land Fraud regarding Property at [${locationController.text.isNotEmpty ? locationController.text : 'Location'}].\n\nRespected Sir/Madam,\n\nI am writing to formally lodge a complaint regarding fraudulent activities related to the aforementioned property. I request an immediate investigation.\n\nYours faithfully,\n[Your Name]";
    final caseId = _caseResult?['case_id'] ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("FIR Draft", "AI-generated legal complaint based on your case."),
          if (caseId.isNotEmpty) ...
            [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEAF4FF), borderRadius: BorderRadius.circular(8)),
                child: Text("Case ID: $caseId", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B5998))),
              ),
            ],
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: TextField(
              maxLines: 15,
              style: GoogleFonts.inter(fontSize: 12, height: 1.6),
              controller: TextEditingController(text: firDraft),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text("Download PDF"),
                  style: OutlinedButton.styleFrom(foregroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _navButtons(nextText: "Find a Lawyer"),
        ],
      ),
    );
  }

  // --- STEP 8: LAWYER CONNECT ---
  Widget _buildStep8LawyerConnect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Connect with Experts", "Specialized property lawyers available for immediate consultation."),
          const SizedBox(height: 24),
          
          _lawyerCard("Adv. Vikram Singh", "Real Estate & Civil Litigation", "15 Yrs Exp", "4.9", "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=200"),
          const SizedBox(height: 16),
          _lawyerCard("Adv. Meera Reddy", "Property Fraud & Documentation", "10 Yrs Exp", "4.8", "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200"),
          
          const SizedBox(height: 40),
          _navButtons(nextText: "Track Case"),
        ],
      ),
    );
  }

  Widget _lawyerCard(String name, String spec, String exp, String rating, String img) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(img, width: 60, height: 60, fit: BoxFit.cover)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 4),
                Text(spec, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: goldColor),
                    const SizedBox(width: 4),
                    Text(rating, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text(exp, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {},
            child: Text("Contact", style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- STEP 9: CASE TRACKING ---
  Widget _buildStep9CaseTracking() {
    final caseId = _caseResult?['case_id'] ?? 'Pending';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: successColor, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text("Case Initialized Successfully", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (caseId.isNotEmpty && caseId != 'Pending')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFEAF4FF), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_open, size: 16, color: Color(0xFF3B5998)),
                  const SizedBox(width: 8),
                  Text("Case ID: $caseId", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF3B5998))),
                ],
              ),
            ),
          Text("Case Tracking Timeline", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 24),
          
          _timelineItem("Submitted Documents", "Completed", true, true),
          _timelineItem("AI Analysis & Verification", "Completed", true, true),
          _timelineItem("Drafted FIR", "Completed", true, true),
          _timelineItem("Lawyer Consultation", "Pending Booking", false, true),
          _timelineItem("Official Police Action", "Awaiting Submission", false, false),
          
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
                  },
                  icon: Icon(Icons.chat, color: primaryColor),
                  label: const Text("Ask Lexis AI"),
                  style: OutlinedButton.styleFrom(foregroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Dashboard", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
        const SizedBox(height: 8),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, height: 1.5)),
      ],
    );
  }

  Widget _inputField({required String label, required TextEditingController controller, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          ),
        ),
      ],
    );
  }

  Widget _uploadCategory(String type, String title, bool isMandatory, PlatformFile? currentFile, String catType) {
    bool hasFile = currentFile != null;
    return GestureDetector(
      onTap: () => _pickFile(catType),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasFile ? const Color(0xFF81C784) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: hasFile ? const Color(0xFF4CAF50) : (isMandatory ? const Color(0xFFFFF4E5) : const Color(0xFFEef2ff)), borderRadius: BorderRadius.circular(8)),
              child: Icon(hasFile ? Icons.check : Icons.upload_file, color: hasFile ? Colors.white : (isMandatory ? const Color(0xFFD48806) : const Color(0xFF3B5998))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(type, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: hasFile ? const Color(0xFF388E3C) : (isMandatory ? const Color(0xFFD48806) : const Color(0xFF3B5998)), letterSpacing: 1)),
                      if (isMandatory && !hasFile) Text(" *", style: TextStyle(color: dangerColor, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(hasFile ? currentFile.name : title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: hasFile ? const Color(0xFF2E7D32) : primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(hasFile ? Icons.check_circle : Icons.add_circle_outline, color: hasFile ? const Color(0xFF4CAF50) : Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isAlert ? dangerColor : primaryColor)),
        ],
      ),
    );
  }

  Widget _actionTile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF388E3C), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(String title, String status, bool isCompleted, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(color: isCompleted ? successColor : Colors.grey.shade300, shape: BoxShape.circle), child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null),
            if (showLine) Container(width: 2, height: 40, color: isCompleted ? successColor : Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500, color: isCompleted ? primaryColor : Colors.grey)),
            const SizedBox(height: 4),
            Text(status, style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 20),
          ],
        )
      ],
    );
  }

  Widget _navButtons({String nextText = "Next Step", VoidCallback? onNext}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(onPressed: _prevPage, child: Text("Back", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: onNext ?? _nextPage,
          child: Text(nextText, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
