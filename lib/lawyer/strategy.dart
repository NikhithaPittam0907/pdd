import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StrategyScreen extends StatefulWidget {
  const StrategyScreen({super.key});

  @override
  State<StrategyScreen> createState() =>
      _StrategyScreenState();
}

class _StrategyScreenState
    extends State<StrategyScreen> {
  final TextEditingController caseController =
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

  Widget strategyCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
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
          CircleAvatar(
            radius: 24,
            backgroundColor:
                color.withOpacity(0.12),
            child: Icon(
              icon,
              color: color,
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
                    Icons.psychology,
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
                      "Legal Strategy",
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
                      "AI-assisted strategy recommendations for stronger legal outcomes.",
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
                        topTag(Icons.psychology,
                            "AI"),
                        topTag(Icons.gavel,
                            "Strategy"),
                        topTag(Icons.analytics,
                            "Insights"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    TextField(
                      controller:
                          caseController,
                      maxLines: 5,
                      style:
                          GoogleFonts.inter(),
                      decoration:
                          InputDecoration(
                        hintText:
                            "Describe case details...",
                        hintStyle:
                            GoogleFonts.inter(
                          color:
                              Colors.grey,
                        ),
                        filled: true,
                        fillColor:
                            Colors.white,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                        label: Text(
                          "GENERATE STRATEGY",
                          style:
                              GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Colors.white,
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
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 24),
                    strategyCard(
                      title:
                          "Evidence Focus",
                      desc:
                          "Prioritize documentary proof and timeline consistency.",
                      icon: Icons.folder,
                      color: Colors.blue,
                    ),
                    strategyCard(
                      title:
                          "Witness Handling",
                      desc:
                          "Prepare key witness statements with clear sequence of events.",
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                    strategyCard(
                      title:
                          "Risk Assessment",
                      desc:
                          "Address weak points before cross-examination begins.",
                      icon: Icons.warning,
                      color: Colors.orange,
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