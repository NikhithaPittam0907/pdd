import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../config/api_config.dart';

class CourtPrepScreen extends StatefulWidget {
  const CourtPrepScreen({super.key});

  @override
  State<CourtPrepScreen> createState() => _CourtPrepScreenState();
}

class _CourtPrepScreenState extends State<CourtPrepScreen> {
  List<dynamic> assignedCases = [];
  String? selectedCaseId;
  bool isLoading = true;
  String lawyerEmail = "lawyer@gmail.com";

  @override
  void initState() {
    super.initState();
    _fetchAssignedCases();
  }

  Future<void> _fetchAssignedCases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      lawyerEmail = prefs.getString('email') ?? "lawyer@gmail.com";
      
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/lawyer/cases?email=$lawyerEmail'));
      if (response.statusCode == 200) {
        final List<dynamic> cases = jsonDecode(response.body);
        setState(() {
          assignedCases = cases;
          if (cases.isNotEmpty) {
            selectedCaseId = cases.first['case_id'].toString();
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget prepCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (selectedCaseId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a case first."), backgroundColor: Colors.orange),
          );
          return;
        }
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF0B132B),
            ),
          ],
        ),
      ),
    );
  }

  Widget topTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0B132B)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B132B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0B132B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.gavel, color: Color(0xFF0B132B)),
                  const SizedBox(width: 10),
                  Text(
                    "LexisAI",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.account_balance, color: Color(0xFF0B132B)),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "Court Preparation",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0B132B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Prepare arguments, evidence, documents and hearing notes before court appearance.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Case Selector Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_special, color: Colors.indigo),
                                const SizedBox(width: 12),
                                Text(
                                  "Select Case: ",
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: assignedCases.isEmpty
                                      ? Text("No assigned cases found", style: GoogleFonts.inter(color: Colors.red))
                                      : DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedCaseId,
                                            isExpanded: true,
                                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
                                            items: assignedCases.map((c) {
                                              final caseIdStr = c['case_id'].toString();
                                              final typeStr = c['type'] ?? 'Case';
                                              return DropdownMenuItem<String>(
                                                value: caseIdStr,
                                                child: Text(
                                                  "$caseIdStr ($typeStr)",
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() => selectedCaseId = val);
                                              }
                                            },
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              topTag(Icons.description, "Documents"),
                              topTag(Icons.gavel, "Arguments"),
                              topTag(Icons.event, "Hearings"),
                            ],
                          ),
                          const SizedBox(height: 24),

                          prepCard(
                            icon: Icons.fact_check,
                            title: "Case Summary",
                            subtitle: "Review facts, previous orders and timeline of events.",
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CaseSummaryScreen(caseId: selectedCaseId!),
                                ),
                              );
                            },
                          ),

                          prepCard(
                            icon: Icons.folder_copy,
                            title: "Evidence Bundle",
                            subtitle: "Organize evidence files, witness proof and exhibits.",
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EvidenceBundleScreen(caseId: selectedCaseId!),
                                ),
                              );
                            },
                          ),

                          prepCard(
                            icon: Icons.record_voice_over,
                            title: "Argument Notes",
                            subtitle: "Prepare opening statements and counter points.",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArgumentNotesScreen(caseId: selectedCaseId!),
                                ),
                              );
                            },
                          ),

                          prepCard(
                            icon: Icons.schedule,
                            title: "Hearing Checklist",
                            subtitle: "Track hearing date, judge notes and pending tasks.",
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HearingChecklistScreen(caseId: selectedCaseId!),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 1. CASE SUMMARY SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CaseSummaryScreen extends StatefulWidget {
  final String caseId;
  const CaseSummaryScreen({super.key, required this.caseId});

  @override
  State<CaseSummaryScreen> createState() => _CaseSummaryScreenState();
}

class _CaseSummaryScreenState extends State<CaseSummaryScreen> {
  Map<String, dynamic> summaryData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/cases/${widget.caseId}/summary'));
      if (res.statusCode == 200) {
        setState(() {
          summaryData = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSummary() async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/cases/${widget.caseId}/summary'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(summaryData),
      );
      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Case Summary saved successfully!")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save summary"), backgroundColor: Colors.red));
    }
  }

  void _showEditModal() {
    final titleCtrl = TextEditingController(text: summaryData['title']);
    final courtCtrl = TextEditingController(text: summaryData['court']);
    final judgeCtrl = TextEditingController(text: summaryData['judge']);
    final clientCtrl = TextEditingController(text: summaryData['client_details']);
    final opponentCtrl = TextEditingController(text: summaryData['opponent_details']);
    final factsCtrl = TextEditingController(text: summaryData['case_facts']);
    final aiCtrl = TextEditingController(text: summaryData['ai_summary']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Edit Case Summary", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Case Title")),
              TextField(controller: courtCtrl, decoration: const InputDecoration(labelText: "Court")),
              TextField(controller: judgeCtrl, decoration: const InputDecoration(labelText: "Judge")),
              TextField(controller: clientCtrl, decoration: const InputDecoration(labelText: "Client Details")),
              TextField(controller: opponentCtrl, decoration: const InputDecoration(labelText: "Opponent Details")),
              TextField(controller: factsCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Case Facts")),
              TextField(controller: aiCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "AI Generated Summary")),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B132B)),
                  onPressed: () {
                    setState(() {
                      summaryData['title'] = titleCtrl.text;
                      summaryData['court'] = courtCtrl.text;
                      summaryData['judge'] = judgeCtrl.text;
                      summaryData['client_details'] = clientCtrl.text;
                      summaryData['opponent_details'] = opponentCtrl.text;
                      summaryData['case_facts'] = factsCtrl.text;
                      summaryData['ai_summary'] = aiCtrl.text;
                    });
                    Navigator.pop(ctx);
                    _saveSummary();
                  },
                  child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _shareSummary() {
    final text = "CASE SUMMARY - ${summaryData['case_id']}\n"
        "Title: ${summaryData['title']}\n"
        "Court: ${summaryData['court']}\n"
        "Judge: ${summaryData['judge']}\n"
        "Status: ${summaryData['case_status']}\n\n"
        "CLIENT:\n${summaryData['client_details']}\n\n"
        "OPPONENT:\n${summaryData['opponent_details']}\n\n"
        "CASE FACTS:\n${summaryData['case_facts']}\n\n"
        "AI SUMMARY:\n${summaryData['ai_summary']}";
    Share.share(text);
  }

  Widget detailCard(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("Case Summary (${widget.caseId})", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0B132B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _showEditModal, icon: const Icon(Icons.edit)),
          IconButton(onPressed: _shareSummary, icon: const Icon(Icons.share)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(summaryData['case_id'] ?? widget.caseId, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                              child: Text(summaryData['case_status'] ?? 'Active', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(summaryData['title'] ?? 'Legal Case', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.account_balance, size: 16, color: Colors.black54),
                            const SizedBox(width: 6),
                            Expanded(child: Text("Court: ${summaryData['court'] ?? 'N/A'}", style: GoogleFonts.inter(fontSize: 13, color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.gavel, size: 16, color: Colors.black54),
                            const SizedBox(width: 6),
                            Expanded(child: Text("Judge: ${summaryData['judge'] ?? 'N/A'}", style: GoogleFonts.inter(fontSize: 13, color: Colors.black87))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  detailCard("Client Details", summaryData['client_details'] ?? 'N/A', Icons.person, Colors.blue),
                  detailCard("Opponent Details", summaryData['opponent_details'] ?? 'N/A', Icons.person_outline, Colors.red),
                  detailCard("Case Facts", summaryData['case_facts'] ?? 'N/A', Icons.notes, Colors.orange),
                  detailCard("AI Generated Summary", summaryData['ai_summary'] ?? 'N/A', Icons.auto_awesome, Colors.purple),

                  // Previous Hearings Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history, size: 20, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text("Previous Hearings & Timeline", style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...((summaryData['previous_hearings'] as List<dynamic>?) ?? []).map((h) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.event_note, color: Colors.indigo),
                              title: Text("${h['date']} - ${h['purpose']}", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              subtitle: Text("Status: ${h['status']}"),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 2. EVIDENCE BUNDLE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class EvidenceBundleScreen extends StatefulWidget {
  final String caseId;
  const EvidenceBundleScreen({super.key, required this.caseId});

  @override
  State<EvidenceBundleScreen> createState() => _EvidenceBundleScreenState();
}

class _EvidenceBundleScreenState extends State<EvidenceBundleScreen> {
  List<dynamic> evidenceList = [];
  bool isLoading = true;
  String selectedCategory = "All";

  final List<String> categories = ["All", "Witness statements", "Exhibits", "Images", "Documents", "Videos"];

  @override
  void initState() {
    super.initState();
    _fetchEvidence();
  }

  Future<void> _fetchEvidence() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/evidence/${widget.caseId}'));
      if (res.statusCode == 200) {
        setState(() {
          evidenceList = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'jpg', 'png', 'mp4'],
      );

      if (result != null && result.files.single.path != null) {
        String category = "General";
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text("Select Category"),
            children: categories.where((c) => c != "All").map((cat) {
              return SimpleDialogOption(
                onPressed: () {
                  category = cat;
                  Navigator.pop(ctx);
                },
                child: Text(cat),
              );
            }).toList(),
          ),
        );

        final request = http.MultipartRequest(
          "POST",
          Uri.parse('${ApiConfig.baseUrl}/api/evidence/upload'),
        );
        request.fields['case_id'] = widget.caseId;
        request.fields['category'] = category;
        request.fields['uploaded_by'] = 'lawyer@gmail.com';
        request.files.add(await http.MultipartFile.fromPath('file', result.files.single.path!));

        final response = await request.send();
        if (response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evidence uploaded successfully!")));
          _fetchEvidence();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error uploading evidence"), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteEvidence(int id) async {
    try {
      final res = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/evidence/$id'));
      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evidence deleted.")));
        _fetchEvidence();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed"), backgroundColor: Colors.red));
    }
  }

  void _previewFile(String filePath) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/uploads/$filePath');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch file preview")));
    }
  }

  IconData _getFileIcon(String ext) {
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (ext == 'jpg' || ext == 'png') return Icons.image;
    if (ext == 'mp4') return Icons.video_library;
    if (ext == 'docx' || ext == 'doc') return Icons.description;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = selectedCategory == "All"
        ? evidenceList
        : evidenceList.where((item) => item['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("Evidence Bundle (${widget.caseId})", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0B132B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadFile,
        backgroundColor: const Color(0xFF0B132B),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text("UPLOAD EVIDENCE", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: categories.map((cat) {
                final selected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: const Color(0xFF0B132B),
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    onSelected: (val) {
                      if (val) setState(() => selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(child: Text("No evidence uploaded yet.", style: GoogleFonts.inter(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _fetchEvidence,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (ctx, index) {
                            final item = filteredList[index];
                            final int id = item['id'];
                            final String fileName = item['file_name'] ?? 'File';
                            final String fileType = (item['file_type'] ?? '').toString().toLowerCase();
                            final String category = item['category'] ?? 'General';
                            final String status = item['status'] ?? 'Uploaded';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.indigo.withOpacity(0.1),
                                    child: Icon(_getFileIcon(fileType), color: Colors.indigo),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(fileName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                                              child: Text(category, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text("• $status", style: TextStyle(fontSize: 10, color: status == 'Verified' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue),
                                    onPressed: () => _previewFile(item['file_path']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteEvidence(id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 3. ARGUMENT NOTES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ArgumentNotesScreen extends StatefulWidget {
  final String caseId;
  const ArgumentNotesScreen({super.key, required this.caseId});

  @override
  State<ArgumentNotesScreen> createState() => _ArgumentNotesScreenState();
}

class _ArgumentNotesScreenState extends State<ArgumentNotesScreen> {
  List<dynamic> notesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/arguments/${widget.caseId}'));
      if (res.statusCode == 200) {
        setState(() {
          notesList = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      final res = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/arguments/$id'));
      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Argument note deleted.")));
        _fetchNotes();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error deleting note"), backgroundColor: Colors.red));
    }
  }

  void _openEditor({Map<String, dynamic>? noteData}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArgumentNoteEditorScreen(caseId: widget.caseId, noteData: noteData),
      ),
    );
    if (result == true) {
      _fetchNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("Argument Notes (${widget.caseId})", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0B132B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: const Color(0xFF0B132B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NEW ARGUMENT NOTE", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesList.isEmpty
              ? Center(child: Text("No argument notes created yet.", style: GoogleFonts.inter(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchNotes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notesList.length,
                    itemBuilder: (ctx, index) {
                      final note = notesList[index];
                      final int id = note['id'];
                      final String title = note['title'] ?? 'Argument Note';
                      final bool isPinned = note['is_pinned'] ?? false;
                      final String opening = note['opening_statement'] ?? '';

                      return GestureDetector(
                        onTap: () => _openEditor(noteData: note),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isPinned ? Border.all(color: Colors.orange, width: 1.5) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isPinned) const Icon(Icons.push_pin, size: 16, color: Colors.orange),
                                  if (isPinned) const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(title, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF0B132B))),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _deleteNote(id),
                                  ),
                                ],
                              ),
                              if (opening.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(opening, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


// argument editor with auto save
class ArgumentNoteEditorScreen extends StatefulWidget {
  final String caseId;
  final Map<String, dynamic>? noteData;
  const ArgumentNoteEditorScreen({super.key, required this.caseId, this.noteData});

  @override
  State<ArgumentNoteEditorScreen> createState() => _ArgumentNoteEditorScreenState();
}

class _ArgumentNoteEditorScreenState extends State<ArgumentNoteEditorScreen> {
  final titleCtrl = TextEditingController();
  final openingCtrl = TextEditingController();
  final factsCtrl = TextEditingController();
  final issuesCtrl = TextEditingController();
  final argsCtrl = TextEditingController();
  final counterCtrl = TextEditingController();
  final caseLawsCtrl = TextEditingController();
  final actsCtrl = TextEditingController();
  final closingCtrl = TextEditingController();

  bool isPinned = false;
  int? noteId;
  Timer? autoSaveTimer;

  @override
  void initState() {
    super.initState();
    if (widget.noteData != null) {
      noteId = widget.noteData!['id'];
      titleCtrl.text = widget.noteData!['title'] ?? '';
      openingCtrl.text = widget.noteData!['opening_statement'] ?? '';
      factsCtrl.text = widget.noteData!['facts'] ?? '';
      issuesCtrl.text = widget.noteData!['legal_issues'] ?? '';
      argsCtrl.text = widget.noteData!['arguments'] ?? '';
      counterCtrl.text = widget.noteData!['counter_arguments'] ?? '';
      caseLawsCtrl.text = widget.noteData!['case_laws'] ?? '';
      actsCtrl.text = widget.noteData!['acts_sections'] ?? '';
      closingCtrl.text = widget.noteData!['closing_statement'] ?? '';
      isPinned = widget.noteData!['is_pinned'] ?? false;
    }
    // Auto Save every 5 seconds
    autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveNote(silent: true));
  }

  @override
  void dispose() {
    autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveNote({bool silent = false}) async {
    if (titleCtrl.text.trim().isEmpty) return;

    final body = {
      "case_id": widget.caseId,
      "title": titleCtrl.text.trim(),
      "is_pinned": isPinned,
      "opening_statement": openingCtrl.text,
      "facts": factsCtrl.text,
      "legal_issues": issuesCtrl.text,
      "arguments": argsCtrl.text,
      "counter_arguments": counterCtrl.text,
      "case_laws": caseLawsCtrl.text,
      "acts_sections": actsCtrl.text,
      "closing_statement": closingCtrl.text,
      "lawyer_email": "lawyer@gmail.com"
    };

    try {
      if (noteId == null) {
        final res = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/arguments'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
        if (res.statusCode == 201) {
          final data = jsonDecode(res.body);
          noteId = data['id'];
          if (!silent && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note saved!")));
        }
      } else {
        final res = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/api/arguments/$noteId'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
        if (res.statusCode == 200 && !silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note updated!")));
        }
      }
    } catch (_) {}
  }

  Widget sectionField(String title, TextEditingController ctrl, {int lines = 3}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0B132B))),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: lines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(noteId == null ? "New Argument Note" : "Edit Note", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0B132B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: isPinned ? Colors.orange : Colors.white),
            onPressed: () {
              setState(() => isPinned = !isPinned);
              _saveNote(silent: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              await _saveNote();
              if (!mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            sectionField("Note Title", titleCtrl, lines: 1),
            sectionField("1. Opening Statement", openingCtrl),
            sectionField("2. Key Case Facts", factsCtrl),
            sectionField("3. Legal Issues Framed", issuesCtrl),
            sectionField("4. Primary Legal Arguments", argsCtrl),
            sectionField("5. Anticipated Counter Arguments", counterCtrl),
            sectionField("6. Case Laws & Precedents", caseLawsCtrl),
            sectionField("7. Statutory Acts & Sections", actsCtrl),
            sectionField("8. Closing Summary", closingCtrl),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 4. HEARING CHECKLIST SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HearingChecklistScreen extends StatefulWidget {
  final String caseId;
  const HearingChecklistScreen({super.key, required this.caseId});

  @override
  State<HearingChecklistScreen> createState() => _HearingChecklistScreenState();
}

class _HearingChecklistScreenState extends State<HearingChecklistScreen> {
  Map<String, dynamic> hearingInfo = {};
  List<dynamic> taskList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChecklist();
  }

  Future<void> _fetchChecklist() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/hearings/${widget.caseId}'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          hearingInfo = data['hearing'] ?? {};
          taskList = data['tasks'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleTask(int id, bool currentStatus) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/hearings/task/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"is_completed": !currentStatus}),
      );
      if (res.statusCode == 200) {
        _fetchChecklist();
      }
    } catch (_) {}
  }

  Future<void> _deleteTask(int id) async {
    try {
      final res = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/hearings/task/$id'));
      if (res.statusCode == 200) {
        _fetchChecklist();
      }
    } catch (_) {}
  }

  void _showAddTaskModal() {
    final taskCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: "2026-08-04");
    String category = "task";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Preparation Task", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: taskCtrl, decoration: const InputDecoration(labelText: "Task Description")),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Due Date (YYYY-MM-DD)")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: "Task Category"),
              items: const [
                DropdownMenuItem(value: "task", child: Text("General Task")),
                DropdownMenuItem(value: "document", child: Text("Required Document")),
                DropdownMenuItem(value: "evidence", child: Text("Pending Evidence")),
                DropdownMenuItem(value: "witness", child: Text("Witness List")),
              ],
              onChanged: (val) {
                if (val != null) category = val;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B132B)),
                onPressed: () async {
                  if (taskCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  await http.post(
                    Uri.parse('${ApiConfig.baseUrl}/api/hearings/task'),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "case_id": widget.caseId,
                      "task_name": taskCtrl.text.trim(),
                      "category": category,
                      "due_date": dateCtrl.text.trim(),
                    }),
                  );
                  _fetchChecklist();
                },
                child: const Text("ADD TASK", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _setReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reminder set! Notifications scheduled 24 hours prior to court hearing.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = taskList.where((t) => t['is_completed'] == true).length;
    final double progress = taskList.isEmpty ? 0 : completedCount / taskList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("Hearing Checklist (${widget.caseId})", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0B132B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _setReminder, icon: const Icon(Icons.notifications_active)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskModal,
        backgroundColor: const Color(0xFF0B132B),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text("ADD TASK", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hearing Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0B132B), Color(0xFF1C2C54)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text("Upcoming Court Hearing", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text("${hearingInfo['hearing_date']} • ${hearingInfo['hearing_time']}", style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text("${hearingInfo['court']} (${hearingInfo['judge']})", style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.greenAccent),
                        const SizedBox(height: 6),
                        Text("$completedCount of ${taskList.length} tasks completed", style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text("Preparation Tasks & Items", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                  const SizedBox(height: 12),

                  taskList.isEmpty
                      ? Center(child: Text("No checklist tasks found.", style: GoogleFonts.inter(color: Colors.grey)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: taskList.length,
                          itemBuilder: (ctx, index) {
                            final task = taskList[index];
                            final int id = task['id'];
                            final String taskName = task['task_name'] ?? 'Task';
                            final bool isDone = task['is_completed'] ?? false;
                            final String category = task['category'] ?? 'task';

                            Color catColor = Colors.blue;
                            if (category == 'document') catColor = Colors.orange;
                            if (category == 'evidence') catColor = Colors.purple;
                            if (category == 'witness') catColor = Colors.teal;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isDone,
                                  activeColor: const Color(0xFF0B132B),
                                  onChanged: (_) => _toggleTask(id, isDone),
                                ),
                                title: Text(
                                  taskName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone ? Colors.grey : const Color(0xFF0B132B),
                                  ),
                                ),
                                subtitle: Text("Due: ${task['due_date'] ?? 'N/A'}", style: const TextStyle(fontSize: 11)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                      child: Text(category.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: catColor)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      onPressed: () => _deleteTask(id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}