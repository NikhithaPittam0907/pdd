import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseSubmissionScreen extends StatefulWidget {
  const CaseSubmissionScreen({super.key});

  @override
  State<CaseSubmissionScreen> createState() =>
      _CaseSubmissionScreenState();
}

class _CaseSubmissionScreenState
    extends State<CaseSubmissionScreen> {
  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController typeController =
      TextEditingController();
  final TextEditingController descController =
      TextEditingController();

  Widget topTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: const Color(0xFF0B132B)),
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

  Widget inputField(
    String label,
    String hint,
    TextEditingController controller,
    int lines,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B132B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: lines,
          style: GoogleFonts.inter(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.inter(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(
                    Icons.gavel,
                    color:
                        Color(0xFF0B132B),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "LexisAI",
                    style:
                        GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          const Color(
                              0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.note_add,
                    color:
                        Color(0xFF0B132B),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                        20),
                child: Column(
                  children: [
                    Text(
                      "Case Submission",
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            const Color(
                                0xFF0B132B),
                      ),
                    ),
                    const SizedBox(
                        height: 12),
                    Text(
                      "Submit your legal issue with complete details for quick review.",
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors
                            .black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        topTag(Icons.note,
                            "New Case"),
                        topTag(Icons.upload,
                            "Submit"),
                        topTag(Icons.security,
                            "Secure"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    Container(
                      padding:
                          const EdgeInsets.all(
                              20),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius:
                                8,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          inputField(
                            "Case Title",
                            "Enter title",
                            titleController,
                            1,
                          ),
                          const SizedBox(
                              height: 18),
                          inputField(
                            "Case Type",
                            "Civil / Criminal / Family...",
                            typeController,
                            1,
                          ),
                          const SizedBox(
                              height: 18),
                          inputField(
                            "Description",
                            "Explain your issue...",
                            descController,
                            6,
                          ),
                          const SizedBox(
                              height: 22),
                          SizedBox(
                            width: double
                                .infinity,
                            height: 54,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  () {},
                              icon:
                                  const Icon(
                                Icons.send,
                                color: Colors
                                    .white,
                              ),
                              label: Text(
                                "SUBMIT CASE",
                                style:
                                    GoogleFonts.inter(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight.w700,
                                  color: Colors
                                      .white,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                        0xFF001A3A),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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