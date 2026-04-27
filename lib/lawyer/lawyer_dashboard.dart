import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'assigned_cases.dart';
import 'case_analysis.dart';
import 'court_prep.dart';
import 'document_draft.dart';
import 'hearings.dart';
import 'legal_research.dart';
import 'strategy.dart';

class LawyerDashboard extends StatefulWidget {
  const LawyerDashboard({super.key});

  @override
  State<LawyerDashboard> createState() =>
      _LawyerDashboardState();
}

class _LawyerDashboardState
    extends State<LawyerDashboard> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    LawyerHome(),
    AssignedCasesScreen(),
    LegalResearchScreen(),
    HearingsScreen(),
    LawyerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: currentIndex,
        type:
            BottomNavigationBarType.fixed,
        backgroundColor:
            Colors.white,
        selectedItemColor:
            const Color(0xFF001A3A),
        unselectedItemColor:
            Colors.grey,
        selectedLabelStyle:
            GoogleFonts.inter(
          fontWeight:
              FontWeight.w600,
        ),
        unselectedLabelStyle:
            GoogleFonts.inter(),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Research",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Hearings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class LawyerHome extends StatelessWidget {
  const LawyerHome({super.key});

  Widget topTag(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFEAF0FF),
        borderRadius:
            BorderRadius.circular(
                14),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                const Color(0xFF0B132B),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color: const Color(
                  0xFF0B132B),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
                  18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  const Color(
                      0xFFEAF0FF),
              child: Icon(
                icon,
                color: const Color(
                    0xFF0B132B),
              ),
            ),
            const SizedBox(
                height: 12),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color: const Color(
                    0xFF0B132B),
              ),
            ),
            const SizedBox(
                height: 8),
            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style:
                  GoogleFonts.inter(
                fontSize: 12,
                color:
                    Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
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
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
                  20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.gavel,
                    color: Color(
                        0xFF0B132B),
                  ),
                  const SizedBox(
                      width: 10),
                  Text(
                    "LexisAI",
                    style:
                        GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight:
                          FontWeight
                              .bold,
                      color: const Color(
                          0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    backgroundColor:
                        Color(
                            0xFFEAF0FF),
                    child: Icon(
                      Icons.person,
                      color: Color(
                          0xFF0B132B),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 28),

              Text(
                "Lawyer Dashboard",
                textAlign:
                    TextAlign.center,
                style:
                    GoogleFonts.playfairDisplay(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                  color: const Color(
                      0xFF0B132B),
                ),
              ),

              const SizedBox(
                  height: 12),

              Text(
                "Manage cases, hearings, drafting and AI-powered legal workflow.",
                textAlign:
                    TextAlign.center,
                style:
                    GoogleFonts.inter(
                  fontSize: 15,
                  color:
                      Colors.black54,
                  height: 1.6,
                ),
              ),

              const SizedBox(
                  height: 20),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  topTag(Icons.work,
                      "Cases"),
                  topTag(Icons
                      .psychology,
                      "AI Tools"),
                  topTag(Icons.event,
                      "Hearings"),
                ],
              ),

              const SizedBox(
                  height: 24),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing:
                    12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    0.88,
                children: [
                  menuCard(
                    context,
                    Icons.folder,
                    "Assigned Cases",
                    "Track active legal matters.",
                    const AssignedCasesScreen(),
                  ),
                  menuCard(
                    context,
                    Icons.analytics,
                    "Case Analysis",
                    "AI insights & probability.",
                    const CaseAnalysisScreen(),
                  ),
                  menuCard(
                    context,
                    Icons.description,
                    "Document Draft",
                    "Create legal drafts fast.",
                    const DocumentDraftScreen(),
                  ),
                  menuCard(
                    context,
                    Icons.account_balance,
                    "Court Prep",
                    "Prepare for hearings.",
                    const CourtPrepScreen(),
                  ),
                  menuCard(
                    context,
                    Icons.search,
                    "Research",
                    "Find legal references.",
                    const LegalResearchScreen(),
                  ),
                  menuCard(
                    context,
                    Icons.psychology,
                    "Strategy",
                    "AI legal strategy help.",
                    const StrategyScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LawyerProfilePage
    extends StatelessWidget {
  const LawyerProfilePage(
      {super.key});

  Widget infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 14),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                const Color(
                    0xFFEAF0FF),
            child: Icon(
              icon,
              color: const Color(
                  0xFF0B132B),
            ),
          ),
          const SizedBox(
              width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors
                        .black54,
                  ),
                ),
                const SizedBox(
                    height: 4),
                Text(
                  value,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight:
                        FontWeight
                            .bold,
                    color: const Color(
                        0xFF0B132B),
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
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
                  20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor:
                    Color(0xFFEAF0FF),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Color(
                      0xFF0B132B),
                ),
              ),
              const SizedBox(
                  height: 18),
              Text(
                "Adv. Rahul Sharma",
                style:
                    GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                  color: const Color(
                      0xFF0B132B),
                ),
              ),
              const SizedBox(
                  height: 6),
              Text(
                "Senior Legal Consultant",
                style:
                    GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      Colors.black54,
                ),
              ),
              const SizedBox(
                  height: 24),
              infoTile(
                Icons.email,
                "Email",
                "lawyer@email.com",
              ),
              infoTile(
                Icons.phone,
                "Phone",
                "+91 9876543210",
              ),
              infoTile(
                Icons.gavel,
                "Specialization",
                "Civil & Corporate",
              ),
              infoTile(
                Icons.folder,
                "Handled Cases",
                "128 Cases",
              ),
            ],
          ),
        ),
      ),
    );
  }
}