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
import 'domestic_violence_flow.dart';
import 'land_fraud_flow.dart';
import 'cyber_crime_flow.dart';
import 'traffic_issue_flow.dart';
import 'women_safety_flow.dart';
import 'employee_rights_flow.dart';
import 'tenant_issue_flow.dart';
import 'consumer_complaint_flow.dart';
import 'student_issue_flow.dart';
import 'accident_claim_flow.dart';
import '../screens/signin_screen.dart';

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
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
          return false;
        }
        // Prevents the app from closing to keep 'flutter run' active
        return false;
      },
      child: Scaffold(
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
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
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
  String userName = "Sarah";
  String searchQuery = "";

  final List<Map<String, dynamic>> categories = [
    {"name": "Domestic Violence", "icon": Icons.family_restroom, "color": const Color(0xFFE57373)},
    {"name": "Land Dispute", "icon": Icons.landscape, "color": const Color(0xFF81C784)},
    {"name": "Cyber Crime", "icon": Icons.computer, "color": const Color(0xFF64B5F6)},
    {"name": "Employee Rights", "icon": Icons.work_outline, "color": const Color(0xFF7986CB)},
    {"name": "Tenant Issue", "icon": Icons.house_outlined, "color": const Color(0xFFA1887F)},
    {"name": "Consumer Complaint", "icon": Icons.shopping_bag_outlined, "color": const Color(0xFF4DB6AC)},
  ];

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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _navigateToUpload(String category) {
    if (category == "Domestic Violence") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DomesticViolenceFlowScreen(),
        ),
      );
    } else if (category == "Land Dispute") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LandFraudFlowScreen(),
        ),
      );
    } else if (category == "Cyber Crime") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CyberCrimeFlowScreen(),
        ),
      );
    } else if (category == "Traffic Issue" || category == "Accident Claim") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TrafficIssueFlowScreen(),
        ),
      );
    } else if (category == "Women Safety") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WomenSafetyFlowScreen(),
        ),
      );
    } else if (category == "Employee Rights") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EmployeeRightsFlowScreen(),
        ),
      );
    } else if (category == "Tenant Issue") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TenantIssueFlowScreen(),
        ),
      );
    } else if (category == "Consumer Complaint") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ConsumerComplaintFlowScreen(),
        ),
      );
    } else if (category == "Student Issues") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentIssueFlowScreen(),
        ),
      );
    } else if (category == "Accident Claim") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AccidentClaimFlowScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadDocumentsScreen(category: category),
        ),
      );
    }
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
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'logout') {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Logout", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFEAF0FF),
                        child: Icon(Icons.person, size: 18, color: Color(0xFF0B132B)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Greeting
              Text(
                "$_greeting, $userName!",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "How can we help you legally today?",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search legal issues, categories...",
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Assistant Banner
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIChatScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B132B), Color(0xFF1C2C54)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B132B).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lexis AI Assistant",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Get instant legal guidance & document analysis.",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Categories Header
              Text(
                "Legal Categories",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 16),

              // Category Grid
              Builder(
                builder: (context) {
                  final filteredCategories = categories
                      .where((cat) => cat["name"]
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

                  if (filteredCategories.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "No categories found",
                          style: GoogleFonts.inter(
                              color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = filteredCategories[index];
                  return GestureDetector(
                    onTap: () => _navigateToUpload(cat["name"]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (cat["color"] as Color).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat["icon"] as IconData,
                              color: cat["color"] as Color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat["name"],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0B132B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                  );
                },
              ),
              const SizedBox(height: 80),
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
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0B132B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasActiveBadge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "ACTIVE",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                            letterSpacing: 1,
                          ),
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
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'logout') {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const SignInScreen()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Logout", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
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