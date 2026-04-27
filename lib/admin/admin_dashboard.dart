import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class AdminProfilePage
    extends StatelessWidget {
  const AdminProfilePage(
      {super.key});

  @override
  Widget build(
      BuildContext context) {
    return const SimplePage(
      title: "Admin Profile",
      icon: Icons.person,
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