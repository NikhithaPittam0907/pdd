import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/signin_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    AdminHomePage(),
    UsersPage(),
    CasesPage(),
    ReportsPage(),
    AdminProfilePage(),
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
            icon: Icon(Icons.people),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
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

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Widget statCard(
      String title,
      String value,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                const Color(0xFFEAF0FF),
            child: Icon(
              icon,
              color: const Color(0xFF0B132B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style:
                GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
              color:
                  const Color(0xFF0B132B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
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
              Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color:
                        Color(0xFF0B132B),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Admin Panel",
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
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF0FF),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF0B132B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 28),
              Text(
                "Dashboard Overview",
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
                  height: 22),
              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing:
                    12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    1,
                children: [
                  statCard("Users",
                      "250", Icons.people),
                  statCard("Cases",
                      "148", Icons.folder),
                  statCard(
                      "Lawyers",
                      "38",
                      Icons.gavel),
                  statCard(
                      "Revenue",
                      "₹1.2L",
                      Icons.payment),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(
      BuildContext context) {
    return const SimplePage(
      title: "Manage Users",
      icon: Icons.people,
    );
  }
}

class CasesPage extends StatelessWidget {
  const CasesPage({super.key});

  @override
  Widget build(
      BuildContext context) {
    return const SimplePage(
      title: "Manage Cases",
      icon: Icons.folder,
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(
      BuildContext context) {
    return const SimplePage(
      title: "Reports",
      icon: Icons.bar_chart,
    );
  }
}

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String adminName = "System Admin";
  String adminEmail = "admin@email.com";
  String adminPhone = "+91 9876543213";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('name') ?? "System Admin";
      adminEmail = prefs.getString('email') ?? "admin@email.com";
      adminPhone = prefs.getString('phone') ?? "+91 9876543213";
    });
  }

  Widget infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF0FF),
            child: Icon(icon, color: const Color(0xFF0B132B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B132B),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text("Admin Profile", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B132B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFEAF0FF),
              child: Icon(Icons.person, size: 50, color: Color(0xFF0B132B)),
            ),
            const SizedBox(height: 18),
            Text(
              adminName,
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B)),
            ),
            const SizedBox(height: 6),
            Text(
              "System Administrator",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            infoTile(Icons.email, "Email", adminEmail),
            infoTile(Icons.phone, "Phone", adminPhone),
            infoTile(Icons.security, "Access Level", "Full Administrator"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "LOGOUT",
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const SimplePage({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FB),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color:
                  const Color(0xFF0B132B),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style:
                  GoogleFonts.playfairDisplay(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
                color: const Color(
                    0xFF0B132B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}