import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_chat.dart';
import 'appointments.dart';
import 'upload_documents.dart';
import 'my_cases.dart';
import 'billing.dart';
import 'case_submission.dart';
import 'edit_profile.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    ClientHomePage(),
    MyCasesScreen(),
    AIChatScreen(),
    AppointmentsScreen(),
    ClientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF001A3A),
        onPressed: () {
          setState(() {
            currentIndex = 2;
          });
        },
        elevation: 4,
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF001A3A),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.snippet_folder),
            label: "Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "AI Strategy",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  String userName = "Sarah"; // Default to Sarah from image if not found

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    if (name != null && name.isNotEmpty) {
      setState(() {
        userName = name.split(' ')[0];
      });
    }
  }

  Widget quickActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color bgColor,
    bool hasBorder = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B132B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activityListTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String titleText,
    required String titleBold,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF0B132B),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: titleText),
                      TextSpan(
                        text: titleBold,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget caseStatusRow({
    required Color dotColor,
    required String label,
    required String count,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFEef2ff) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: dotColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B132B),
            ),
          ),
          const Spacer(),
          Text(
            count,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar
              Row(
                children: [
                  const Icon(
                    Icons.account_balance,
                    color: Color(0xFF0B132B),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "LexisCore AI",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.security,
                    color: Color(0xFF0B132B),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Greeting
              Text(
                "Good morning,\n$userName",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              Text(
                "Your legal landscape is evolving. Here is the latest intelligence regarding your active matters and document progress.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // AI Strategic Insight Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF07142A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFD4AF37),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "AI STRATEGIC INSIGHT",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Regulatory shift may impact Case #2024-88",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "LexisCore AI has detected a recent appellate ruling in the 9th Circuit that mirrors your current dispute with Global Logistics. This precedent strengthens our argument regarding section 4.2 of your service agreement.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A6A00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Review Precedent",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Case Status
              Text(
                "Case Status",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    caseStatusRow(
                      dotColor: const Color(0xFF8A6A00),
                      label: "Active Matters",
                      count: "03",
                      highlight: true,
                    ),
                    caseStatusRow(
                      dotColor: Colors.grey,
                      label: "Pending Review",
                      count: "08",
                    ),
                    caseStatusRow(
                      dotColor: Colors.grey.shade300,
                      label: "Closed Files",
                      count: "42",
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyCasesScreen()),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            "View Complete Portfolio  ›",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8A6A00),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Quick Actions
              Text(
                "Quick Actions",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 16),
              quickActionCard(
                icon: Icons.chat_bubble,
                iconColor: const Color(0xFF0B132B),
                title: "Ask AI Assistant",
                subtitle: "Draft queries or analyze clauses",
                bgColor: const Color(0xFFEef2ff),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIChatScreen()),
                  );
                },
              ),
              quickActionCard(
                icon: Icons.note_add_rounded,
                iconColor: const Color(0xFF8A6A00),
                title: "Upload Document",
                subtitle: "Securely ingest new evidence",
                bgColor: Colors.white,
                hasBorder: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadDocumentsScreen()),
                  );
                },
              ),
              quickActionCard(
                icon: Icons.calendar_today,
                iconColor: Colors.grey.shade600,
                title: "Schedule Meeting",
                subtitle: "Connect with your counsel",
                bgColor: Colors.white,
                hasBorder: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Recent Activity
              Row(
                children: [
                  Text(
                    "Recent\nActivity",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B132B),
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEef2ff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 10,
                          color: Color(0xFF3B5998),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "ENCRYPTED\nFEED",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3B5998),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    activityListTile(
                      icon: Icons.description,
                      iconBg: const Color(0xFFEef2ff),
                      iconColor: const Color(0xFF3B5998),
                      titleText: "Updated draft:\n",
                      titleBold: "Shareholder_Agreement_v4.pdf",
                      subtitle: "Modified by LexisCore AI • 2 hours ago",
                    ),
                    activityListTile(
                      icon: Icons.gavel,
                      iconBg: const Color(0xFFFFF4E5),
                      iconColor: const Color(0xFFD48806),
                      titleText: "New court filing detected:\n",
                      titleBold: "Case #2024-LH-992",
                      subtitle: "Superior Court Registry • 5 hours ago",
                    ),
                    activityListTile(
                      icon: Icons.forum,
                      iconBg: const Color(0xFFF4F6FB),
                      iconColor: const Color(0xFF5A6679),
                      titleText: "Meeting Recap available:\n",
                      titleBold: "Discovery Review with Arthur Pierce",
                      subtitle: "Meeting AI Transcript • Yesterday",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Fab spacing
            ],
          ),
        ),
      ),
    );
  }
}

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  String userName = "Client User";
  String userEmail = "client@email.com";
  String userPhone = "+91 9876543210";
  String userRole = "CLIENT";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "Client User";
      userEmail = prefs.getString('email') ?? "client@email.com";
      userPhone = prefs.getString('phone') ?? "+91 9876543210";
      userRole = (prefs.getString('role') ?? "CLIENT").toUpperCase();
    });
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              color: const Color(0xFF0B132B),
            ),
          ),
        ],
      ),
    );
  }

  Widget securityTile(IconData icon, String title, String subtitle, {bool hasActiveBadge = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEef2ff),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF3B5998), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    if (hasActiveBadge) ...[
                      const SizedBox(width: 8),
                      Text(
                        "ACTIVE",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: Color(0xFF0B132B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "LexAssist",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFFEAF0FF),
                        child: Icon(Icons.person, size: 14, color: Color(0xFF0B132B)),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    // Dark top half
                    Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C3E50),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                    // Content
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar row
                          Transform.translate(
                            offset: const Offset(0, -50),
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          color: const Color(0xFF0B132B),
                                          child: const Icon(Icons.person, size: 40, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -5,
                                      right: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF7C873),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Name and title
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0B132B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.work, size: 12, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Verified Client • LexisCore Platform",
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B132B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const EditProfileScreen(),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadProfile();
                                      }
                                    },
                                    child: Text(
                                      "Edit Profile",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
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
                  ],
                ),
              ),

              // Credentials Section (Replaced with Personal Details)
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.contact_mail, size: 16, color: Color(0xFF0B132B)),
                          const SizedBox(width: 8),
                          Text(
                            "PERSONAL DETAILS",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: const Color(0xFF0B132B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      detailRow("FULL NAME", userName),
                      detailRow("CONTACT EMAIL", userEmail),
                      detailRow("PHONE NUMBER", userPhone),
                      detailRow("ACCOUNT ROLE", userRole),
                      
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF0FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info, size: 16, color: Color(0xFF8A6A00)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Your contact details are securely stored. Changes to these fields require email verification.",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                  height: 1.4,
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

              // Verified Status Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF051937),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -10,
                      child: Icon(
                        Icons.security,
                        size: 100,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock, size: 14, color: Color(0xFF8DB6F3)),
                            const SizedBox(width: 8),
                            Text(
                              "STATUS",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: const Color(0xFF8DB6F3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Verified Client",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Active platform access confirmed for the current billing cycle.",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Color(0xFFD4AF37)),
                            const SizedBox(width: 8),
                            Text(
                              "SECURE PROFILE LEVEL 4",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 1,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Security & Privacy
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gpp_good, size: 16, color: Color(0xFF0B132B)),
                        const SizedBox(width: 8),
                        Text(
                          "SECURITY & PRIVACY",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: const Color(0xFF0B132B),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7C873),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "ENCRYPTED",
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8A6A00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    securityTile(
                      Icons.vpn_key,
                      "Manage Encryption",
                      "Update PGP keys and end-to-end encryption protocols.",
                    ),
                    securityTile(
                      Icons.fingerprint,
                      "Biometric Login",
                      "Configure FaceID or TouchID for rapid secure access.",
                      hasActiveBadge: true,
                    ),
                    securityTile(
                      Icons.history,
                      "Access Log",
                      "Review recent login attempts and session locations.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Footer
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, size: 14, color: Color(0xFF0B132B)),
                      const SizedBox(width: 8),
                      Text(
                        "LexAssist Advanced Encryption Standard (AES-256) Active",
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("PRIVACY POLICY", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(width: 20),
                      Text("TERMS OF SERVICE", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(width: 20),
                      Text("SECURITY AUDIT", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}