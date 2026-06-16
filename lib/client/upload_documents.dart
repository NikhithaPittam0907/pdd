import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'ai_chat.dart';

class UploadDocumentsScreen extends StatefulWidget {
  final String? category;
  const UploadDocumentsScreen({super.key, this.category});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  String? selectedCategory;
  PlatformFile? selectedFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category ?? "Affidavit";
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  Future<void> uploadAndAnalyze() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/extract-text"),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          selectedFile!.path!,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIChatScreen(analysisData: data),
          ),
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? "Error analyzing document")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B132B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Upload Document",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0B132B),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF14243B),
              radius: 16,
              child: Text(
                "LP",
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // ACTIVE CASE
            Text(
              "ACTIVE CASE",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A6A00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder, color: Color(0xFF8A6A00), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Anderson vs. TechFlow Ltd.",
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Civil Litigation • 2024-CV-892",
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // DOCUMENT CATEGORY
            Text(
              "DOCUMENT CATEGORY",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (widget.category != null && !["Affidavit", "Evidence", "Contract", "Pleading"].contains(widget.category))
                  categoryChip(widget.category!, selectedCategory == widget.category),
                categoryChip("Affidavit", selectedCategory == "Affidavit"),
                categoryChip("Evidence", selectedCategory == "Evidence"),
                categoryChip("Contract", selectedCategory == "Contract"),
                categoryChip("Pleading", selectedCategory == "Pleading"),
              ],
            ),

            const SizedBox(height: 32),

            // UPLOAD ZONE
            GestureDetector(
              onTap: pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedFile != null ? const Color(0xFF0B132B) : Colors.grey.shade200,
                    width: selectedFile != null ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
                        color: const Color(0xFF0B132B),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      selectedFile != null ? selectedFile!.name : "Tap to select files",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedFile != null ? "${(selectedFile!.size / 1024).toStringAsFixed(2)} KB" : "or drag & drop files here",
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        formatIcon(Icons.description, "PDF"),
                        const SizedBox(width: 16),
                        formatIcon(Icons.description, "DOCX"),
                        const SizedBox(width: 16),
                        formatIcon(Icons.image, "JPG"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Classification Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF3B5998), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Classification",
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B5998)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Auto-classify and extract key dates, parties, and entities for the case timeline.",
                          style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF3B5998).withOpacity(0.7), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: const Color(0xFF0B132B),
                    activeTrackColor: const Color(0xFF0B132B).withOpacity(0.2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // QUEUED FILES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "QUEUED FILES",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "1 file added",
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF0B132B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedFile != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        selectedFile!.name.toLowerCase().endsWith(".pdf") ? Icons.picture_as_pdf : Icons.description,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFile!.name,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${(selectedFile!.size / 1024).toStringAsFixed(2)} KB • Ready",
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.black45),
                      onPressed: () {
                        setState(() {
                          selectedFile = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // SECURE UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07142A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                onPressed: isLoading ? null : uploadAndAnalyze,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.lock, color: Colors.white, size: 18),
                label: Text(
                  isLoading ? "Analyzing Case..." : "Securely Upload & Analyze",
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user, size: 12, color: Color(0xFF8A6A00)),
                  const SizedBox(width: 6),
                  Text(
                    "256-BIT AES ENCRYPTION ACTIVE",
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A6A00),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget categoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B132B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF0B132B),
          ),
        ),
      ),
    );
  }

  Widget formatIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black45)),
      ],
    );
  }
}