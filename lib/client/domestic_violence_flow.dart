import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../config/api_config.dart';
import '../services/live_location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DomesticViolenceFlowScreen extends StatefulWidget {
  const DomesticViolenceFlowScreen({super.key});

  @override
  State<DomesticViolenceFlowScreen> createState() => _DomesticViolenceFlowScreenState();
}

class _DomesticViolenceFlowScreenState extends State<DomesticViolenceFlowScreen> {
  final PageController _pageController = PageController();
  final LiveLocationService _liveLocationService = LiveLocationService();
  int _currentPage = 0;

  bool isRecording = false;
  String recordingStatusText = "Use Voice Input";
  TextEditingController descriptionController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Backend state
  bool _isSubmitting = false;
  Map<String, dynamic>? _caseResult;

  PlatformFile? mandatoryIdFile;
  PlatformFile? evidenceFile;
  PlatformFile? medicalFile;

  // Complaint draft controller so edits are preserved
  final TextEditingController _complaintController = TextEditingController();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _shareLocation() async {
    try {
      String link = await _liveLocationService.startLiveLocationSharing();
      await _liveLocationService.shareLocationLink(link);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Live location sharing active")),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        if (errorStr.contains("Location services are disabled") || errorStr.contains("disabled")) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(Icons.location_off, color: dangerColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Enable Location Services",
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  "Location services are turned off on your device. Please turn on location to share your live location.",
                  style: GoogleFonts.inter(fontSize: 14, height: 1.4),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await Geolocator.openLocationSettings();
                    },
                    child: Text(
                      "Turn On",
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  void _toggleRecording() async {
    if (!isRecording) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() {
              isRecording = false;
              recordingStatusText = "Voice Input Captured";
            });
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          isRecording = true;
          recordingStatusText = "Listening... Tap to stop";
        });
        _speech.listen(
          onResult: (val) => setState(() {
            descriptionController.text = val.recognizedWords;
          }),
        );
      } else {
        setState(() => recordingStatusText = "Microphone Permission Denied");
      }
    } else {
      setState(() {
        isRecording = false;
        recordingStatusText = "Voice Input Captured";
      });
      _speech.stop();
    }
  }

  Future<void> _pickFile(String category) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'mp4', 'mov', 'avi']
    );
    if (result != null) {
      setState(() {
        if (category == 'Mandatory') {
          mandatoryIdFile = result.files.first;
        } else if (category == 'Recommended') {
          evidenceFile = result.files.first;
        } else if (category == 'Optional') {
          medicalFile = result.files.first;
        }
      });
    }
  }

  void _validateAndProceedStep3() {
    if (mandatoryIdFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must upload a Mandatory ID Proof to proceed securely."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      _submitComplaintToBackend();
      _nextPage();
    }
  }

  String _analysisStatus = "Initializing Secure Upload...";

  Future<void> _submitComplaintToBackend() async {
    setState(() {
      _isSubmitting = true;
      _analysisStatus = "Uploading Documents Securely...";
    });
    
    // Simulate real-time steps for AI analysis feel
    Timer? statusTimer;
    statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_isSubmitting) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_analysisStatus.contains("Uploading")) {
          _analysisStatus = "AI: Analyzing Incident Details...";
        } else if (_analysisStatus.contains("Analyzing Incident")) {
          _analysisStatus = "AI: Detecting Risk Levels...";
        } else if (_analysisStatus.contains("Detecting Risk")) {
          _analysisStatus = "AI: Drafting Legal Complaint...";
        } else if (_analysisStatus.contains("Drafting")) {
          _analysisStatus = "Finalizing Case Assessment...";
        }
      });
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final uri = Uri.parse('${ApiConfig.baseUrl}/submit-dv-complaint');
      final req = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['description'] = descriptionController.text;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          req.fields['latitude'] = position.latitude.toString();
          req.fields['longitude'] = position.longitude.toString();
        }
      } catch (e) {
        // Continue even if location fails
      }

      if (mandatoryIdFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('id_proof', mandatoryIdFile!.path!));
      }
      if (evidenceFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('evidence', evidenceFile!.path!));
      }
      if (medicalFile?.path != null) {
        req.files.add(await http.MultipartFile.fromPath('medical', medicalFile!.path!));
      }

      final streamed = await req.send().timeout(const Duration(seconds: 120));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        statusTimer.cancel();
        if (mounted) {
          setState(() { 
            _caseResult = json.decode(res.body); 
            _isSubmitting = false; 
            _complaintController.text = _caseResult?['complaint_draft'] ?? "To,\nThe Officer-in-Charge,\n[Local Police Station Name]\n\nSubject: Formal Complaint regarding Domestic Violence under Section 498A.\n\nRespected Sir/Madam,\n\nI, [Your Name], wish to report a case of continuous domestic violence.\n\n${descriptionController.text}\n\nI request immediate intervention and a protection order.\n\nSincerely,\n[Your Name]";
          });
        }
      } else {
        statusTimer.cancel();
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _complaintController.text = "To,\nThe Officer-in-Charge,\n[Local Police Station Name]\n\nSubject: Formal Complaint regarding Domestic Violence under Section 498A.\n\nRespected Sir/Madam,\n\nI, [Your Name], wish to report a case of continuous domestic violence.\n\n${descriptionController.text}\n\nI request immediate intervention and a protection order.\n\nSincerely,\n[Your Name]";
          });
        }
      }
    } catch (e) {
      statusTimer.cancel();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _complaintController.text = "To,\nThe Officer-in-Charge,\n[Local Police Station Name]\n\nSubject: Formal Complaint regarding Domestic Violence under Section 498A.\n\nRespected Sir/Madam,\n\nI, [Your Name], wish to report a case of continuous domestic violence.\n\n${descriptionController.text}\n\nI request immediate intervention and a protection order.\n\nSincerely,\n[Your Name]";
        });
      }
    }
  }

  final Color primaryColor = const Color(0xFF0B132B);
  final Color goldColor = const Color(0xFF8A6A00);
  final Color bgLight = const Color(0xFFF8F9FA);
  final Color dangerColor = const Color(0xFFD32F2F);

  void _nextPage() {
    if (_currentPage < 6) {
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
          "Secure Reporting",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: false,
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
          _buildStep1SafetyFirst(),
          _buildStep2Description(),
          _buildStep3FileUpload(),
          _buildStep4AIAnalysis(),
          _buildStep5FIRGenerator(),
          _buildStep6ActionOptions(),
          _buildStep7CaseTracking(),
        ],
      ),
    );
  }

  // --- STEP 1: SAFETY FIRST ---
  Widget _buildStep1SafetyFirst() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, size: 64, color: primaryColor),
          const SizedBox(height: 24),
          Text(
            "Your Safety is Priority",
            style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "This space is completely private and secure. If you are in immediate danger, use the emergency options below.",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _largeEmergencyButton(
            title: "Call Police (100)",
            subtitle: "Direct line to local authorities",
            icon: Icons.local_police,
            color: const Color(0xFF1976D2),
            onTap: () => _makePhoneCall('100'),
          ),
          const SizedBox(height: 16),
          _largeEmergencyButton(
            title: "Share Live Location",
            subtitle: "Send your current location securely",
            icon: Icons.location_on,
            color: const Color(0xFF388E3C),
            onTap: _shareLocation,
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: _nextPage,
            child: Text("I am safe, proceed to report", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor, decoration: TextDecoration.underline)),
          )
        ],
      ),
    );
  }

  Widget _largeEmergencyButton({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: color.withOpacity(0.8))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: CASE DESCRIPTION ---
  Widget _buildStep2Description() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Step 1 of 6", "Describe the Incident"),
          const SizedBox(height: 8),
          Text("Please provide details of what happened, when, and where. You can type or use voice dictation.", style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: descriptionController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "E.g., Yesterday around 8 PM at my residence...",
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecording ? const Color(0xFFFFEBEE) : const Color(0xFFEef2ff),
                    foregroundColor: isRecording ? const Color(0xFFD32F2F) : const Color(0xFF3B5998),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _toggleRecording,
                  icon: isRecording 
                      ? const Icon(Icons.stop, color: Color(0xFFD32F2F)) 
                      : const Icon(Icons.mic),
                  label: Text(recordingStatusText, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _navButtons(),
        ],
      ),
    );
  }

  // --- STEP 3: FILE UPLOAD ---
  Widget _buildStep3FileUpload() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Step 2 of 6", "Upload Evidence"),
          const SizedBox(height: 8),
          Text("Provide any supporting documents or media. You can skip this and provide them later.", style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 24),
          
          _uploadCategory("Mandatory", "ID Proof (Aadhar, PAN)", true, mandatoryIdFile),
          const SizedBox(height: 16),
          _uploadCategory("Recommended", "Evidence (Photos, Audio, Chats)", false, evidenceFile),
          const SizedBox(height: 16),
          _uploadCategory("Optional", "Medical Reports, Relationship Proof", false, medicalFile),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _prevPage,
                child: Text("Back", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _validateAndProceedStep3,
                child: Text("Next Step", style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _uploadCategory(String type, String title, bool isMandatory, PlatformFile? currentFile) {
    bool hasFile = currentFile != null;
    return GestureDetector(
      onTap: () => _pickFile(type),
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
              decoration: BoxDecoration(
                color: hasFile ? const Color(0xFF4CAF50) : (isMandatory ? const Color(0xFFFFF4E5) : const Color(0xFFEef2ff)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasFile ? Icons.check : Icons.upload_file, 
                color: hasFile ? Colors.white : (isMandatory ? const Color(0xFFD48806) : const Color(0xFF3B5998))
              ),
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
                  Text(
                    hasFile ? currentFile.name : title, 
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: hasFile ? const Color(0xFF2E7D32) : primaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(hasFile ? Icons.check_circle : Icons.add_circle_outline, color: hasFile ? const Color(0xFF4CAF50) : Colors.black45),
          ],
        ),
      ),
    );
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
            Text(_analysisStatus, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            Text("This may take a few moments for a thorough assessment.", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    }

    final riskLevel = _caseResult?['risk_level'] ?? 'HIGH';
    final riskSummary = _caseResult?['risk_summary'] ?? 'Immediate legal protection recommended.';
    final caseSummary = _caseResult?['case_summary'] ?? 'Victim reports continuous physical and emotional abuse. Immediate safety intervention and legal protection are required.';
    final missingDocs = (_caseResult?['missing_documents'] as List<dynamic>?)?.cast<String>() ?? ['Medical report from recent incident'];
    final legalActions = (_caseResult?['legal_actions'] as List<dynamic>?)?.cast<String>() ?? ['File FIR under Section 498A', 'Apply for Protection Order'];
    final idVerificationStatus = _caseResult?['id_verification_status'] ?? 'Pending Verification';
    final isHigh = riskLevel == 'HIGH';
    final riskColor = isHigh ? const Color(0xFFD48806) : (riskLevel == 'MEDIUM' ? const Color(0xFF1976D2) : const Color(0xFF388E3C));
    final riskBg = isHigh ? const Color(0xFFFFF4E5) : (riskLevel == 'MEDIUM' ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9));
    final riskBorderColor = isHigh ? const Color(0xFFFFCC80) : (riskLevel == 'MEDIUM' ? const Color(0xFF90CAF9) : Colors.green.shade200);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Step 3 of 6", "AI Case Analysis"),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: riskBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: riskBorderColor)),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: riskColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Risk Level: $riskLevel", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: riskColor)),
                      const SizedBox(height: 4),
                      Text(riskSummary, style: GoogleFonts.inter(fontSize: 12, color: riskColor.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Risk Analysis", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on severity and evidence provided.', style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          Text("Case Summary", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 8),
          Text(caseSummary, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          Text("ID Verification", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: idVerificationStatus.contains("Valid")
                  ? const Color(0xFFE8F5E9)
                  : idVerificationStatus.contains("Pending") || idVerificationStatus.contains("Unable")
                      ? const Color(0xFFFFF8E1)
                      : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: idVerificationStatus.contains("Valid")
                    ? const Color(0xFF81C784)
                    : idVerificationStatus.contains("Pending") || idVerificationStatus.contains("Unable")
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFFE57373),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  idVerificationStatus.contains("Valid")
                      ? Icons.verified_user
                      : idVerificationStatus.contains("Pending") || idVerificationStatus.contains("Unable")
                          ? Icons.hourglass_top
                          : Icons.gpp_bad,
                  color: idVerificationStatus.contains("Valid")
                      ? const Color(0xFF2E7D32)
                      : idVerificationStatus.contains("Pending") || idVerificationStatus.contains("Unable")
                          ? const Color(0xFFF9A825)
                          : const Color(0xFFC62828),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mandatoryIdFile == null
                        ? "No ID file uploaded — upload your Aadhaar/PAN in Step 2"
                        : idVerificationStatus,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: idVerificationStatus.contains("Valid")
                          ? const Color(0xFF2E7D32)
                          : idVerificationStatus.contains("Pending") || idVerificationStatus.contains("Unable")
                              ? const Color(0xFFF9A825)
                              : const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Missing Documents", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 8),
          ...missingDocs.map((doc) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: dangerColor),
                const SizedBox(width: 8),
                Expanded(child: Text(doc, style: GoogleFonts.inter(fontSize: 13, color: dangerColor))),
              ],
            ),
          )),
          const SizedBox(height: 24),
          Text("Suggested Local Support", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 12),
          _buildPoliceStationTile("Nearest Police Station", _caseResult?['police_station_1']),
          _supportTile(
            "Suggested Local Lawyer",
            _caseResult?['suggested_lawyer'] ?? "Consult a local family law advocate",
            Icons.person,
            goldColor,
          ),
          const SizedBox(height: 24),
          Text("Suggested Legal Actions", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 12),
          ...legalActions.asMap().entries.map((e) => _actionTile("${e.key + 1}. Action", e.value)),
          const SizedBox(height: 40),
          _navButtons(nextText: "Generate Complaint"),
        ],
      ),
    );
  }

  Widget _buildPoliceStationTile(String label, String? stationData) {
    final text = stationData?.isNotEmpty == true ? stationData! : "Fetching nearby station...";
    return _supportTile(
      label,
      text,
      Icons.local_police,
      const Color(0xFF1976D2),
      onTap: text.contains("Fetching") ? null : () => _openMaps(text),
    );
  }

  Future<void> _openMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _supportTile(String title, String subtitle, IconData icon, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap != null ? const Color(0xFFE3F2FD) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: onTap != null ? const Color(0xFF90CAF9) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.open_in_new, size: 16, color: Color(0xFF1976D2)),
          ],
        ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 5: FIR GENERATOR ---
  Widget _buildStep5FIRGenerator() {
    final caseId = _caseResult?['case_id'] ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Step 4 of 6", "Generated Complaint"),
          const SizedBox(height: 8),
          Text("The AI has drafted an official complaint based on your description. Review and edit as needed.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          if (caseId.isNotEmpty) ...[  
            const SizedBox(height: 12),
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
              maxLines: 18,
              style: GoogleFonts.inter(fontSize: 13, height: 1.6),
              controller: _complaintController,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final text = _complaintController.text;
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
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: Text("Download PDF",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B132B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _navButtons(nextText: "Proceed to Action"),
        ],
      ),
    );
  }

  Future<void> _assignCase(String assignTo) async {
    final caseId = _caseResult?['case_id'];
    if (caseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Case ID not found. Please try again.")));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/assign-case'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "case_id": caseId,
          "assign_to": assignTo,
        }),
      );

      if (response.statusCode == 200) {
        _nextPage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to assign case.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network error occurred.")));
    }
  }

  // --- STEP 6: ACTION OPTIONS ---
  Widget _buildStep6ActionOptions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader("Step 5 of 6", "Choose Next Action"),
          const SizedBox(height: 8),
          Text("Your complaint is ready. How would you like to proceed?", style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 32),
          
          _finalActionButton(
            title: "Submit to Local Police",
            subtitle: "Send the FIR draft online to the nearest station",
            icon: Icons.send,
            color: primaryColor,
            bgColor: Colors.white,
            isSolid: true,
            onTap: () {
              final policeDetails = _caseResult?['police_station_1'] ?? "Nearest Local Police Station";
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Row(
                      children: [
                        Icon(Icons.local_police, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Submit to Police",
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your complaint will be submitted to the following police station:",
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            policeDetails,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Do you want to proceed?",
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _assignCase("police");
                        },
                        child: Text(
                          "Submit",
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          _finalActionButton(
            title: "Contact a Lawyer",
            subtitle: "Connect with our empaneled legal experts immediately",
            icon: Icons.gavel,
            color: goldColor,
            bgColor: const Color(0xFFFFF4E5),
            isSolid: false,
            onTap: () => _assignCase("lawyer"),
          ),
          const SizedBox(height: 16),
          _finalActionButton(
            title: "Save as Draft",
            subtitle: "Keep it in your secure vault to submit later",
            icon: Icons.save,
            color: Colors.black54,
            bgColor: Colors.grey.shade100,
            isSolid: false,
            onTap: _nextPage,
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: _prevPage, child: Text("Back", style: GoogleFonts.inter(color: Colors.grey))),
            ],
          )
        ],
      ),
    );
  }

  Widget _finalActionButton({required String title, required String subtitle, required IconData icon, required Color color, required Color bgColor, required bool isSolid, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSolid ? color : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isSolid ? null : Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSolid ? Colors.white : color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isSolid ? Colors.white : color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isSolid ? Colors.white70 : color.withOpacity(0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 7: CASE TRACKING ---
  Widget _buildStep7CaseTracking() {
    final caseId = _caseResult?['case_id'] ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF388E3C), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text("Complaint Submitted Successfully", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
              ),
            ],
          ),
          if (caseId.isNotEmpty) ...
            [
              const SizedBox(height: 12),
              Container(
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
            ],
          const SizedBox(height: 32),
          Text("Case Tracking Timeline", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 24),
          _timelineItem("Complaint Submitted", "${DateTime.now().day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][DateTime.now().month - 1]}, ${TimeOfDay.now().format(context)}", true, true),
          _timelineItem("Under Police Review", "Pending", false, true),
          _timelineItem("Action Taken / FIR Registered", "Pending", false, true),
          _timelineItem("Protection Order Hearing", "Pending", false, false),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: Text("Return to Dashboard", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _timelineItem(String title, String time, bool isCompleted, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF388E3C) : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? const Color(0xFF388E3C) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500, color: isCompleted ? primaryColor : Colors.grey)),
            const SizedBox(height: 4),
            Text(time, style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 20), // extra padding
          ],
        )
      ],
    );
  }

  // --- HELPERS ---
  Widget _stepHeader(String step, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
      ],
    );
  }

  Widget _navButtons({String nextText = "Next Step"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _prevPage,
          child: Text("Back", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _nextPage,
          child: Text(nextText, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _liveLocationService.stopLiveLocationSharing();
    super.dispose();
  }
}
