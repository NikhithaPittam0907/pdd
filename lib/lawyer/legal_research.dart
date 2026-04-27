import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalResearchScreen extends StatefulWidget {
  const LegalResearchScreen({super.key});

  @override
  State<LegalResearchScreen> createState() =>
      _LegalResearchScreenState();
}

class _LegalResearchScreenState
    extends State<LegalResearchScreen> {
  final TextEditingController searchController =
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
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF0B132B),
          ),
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

  Widget resultCard({
    required String title,
    required String category,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFEAF0FF),
            child: Icon(
              Icons.gavel,
              color: Color(0xFF0B132B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(0xFF0B132B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                      color: const Color(
                          0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.search,
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
                      "Legal Research",
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
                      "Search acts, judgments, precedents and legal references instantly.",
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
                        topTag(Icons.book,
                            "Acts"),
                        topTag(Icons.gavel,
                            "Judgments"),
                        topTag(Icons.search,
                            "Research"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    TextField(
                      controller:
                          searchController,
                      style:
                          GoogleFonts.inter(),
                      decoration:
                          InputDecoration(
                        hintText:
                            "Search legal topic...",
                        hintStyle:
                            GoogleFonts.inter(
                          color:
                              Colors.grey,
                        ),
                        filled: true,
                        fillColor:
                            Colors.white,
                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 24),
                    resultCard(
                      title:
                          "Indian Contract Act, 1872",
                      category:
                          "Statute",
                      desc:
                          "Defines rules for agreements, contracts, obligations and breach remedies.",
                    ),
                    resultCard(
                      title:
                          "Consumer Protection vs XYZ Ltd",
                      category:
                          "Judgment",
                      desc:
                          "Landmark ruling on deficiency of service and compensation rights.",
                    ),
                    resultCard(
                      title:
                          "Property Transfer Rules",
                      category:
                          "Reference",
                      desc:
                          "Legal framework for sale deed, ownership transfer and registration process.",
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