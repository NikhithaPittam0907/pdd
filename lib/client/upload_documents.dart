import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadDocumentsScreen extends StatelessWidget {
  const UploadDocumentsScreen({super.key});

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
                categoryChip("Affidavit", true),
                categoryChip("Evidence", false),
                categoryChip("Contract", false),
                categoryChip("Pleading", false),
              ],
            ),

            const SizedBox(height: 32),

            // UPLOAD ZONE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                // Custom dotted border would be better but simple border is fine for now
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_upload, color: Color(0xFF0B132B), size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Tap to select files",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "or drag & drop files here",
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
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Evidence_v1.pdf",
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "2.4 MB • Ready",
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.delete_outline, color: Colors.black45),
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
                onPressed: () {},
                icon: const Icon(Icons.lock, color: Colors.white, size: 18),
                label: Text(
                  "Securely Upload",
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
    return Container(
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