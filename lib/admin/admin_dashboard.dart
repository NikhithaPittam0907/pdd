import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../screens/signin_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF001A3A),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Overview",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            activeIcon: Icon(Icons.folder),
            label: "Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// ─── OVERVIEW HOME PAGE ──────────────────────────────────────────────────────────

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool isLoading = true;
  int totalUsers = 0;
  int totalCases = 0;
  int activeLawyers = 0;
  int activePolice = 0;
  List<dynamic> recentCases = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => isLoading = true);
    try {
      final usersRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/users'));
      final casesRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/all-cases'));

      if (usersRes.statusCode == 200 && casesRes.statusCode == 200) {
        final List<dynamic> users = jsonDecode(usersRes.body);
        final List<dynamic> cases = jsonDecode(casesRes.body);

        setState(() {
          totalUsers = users.length;
          totalCases = cases.length;
          activeLawyers = users.where((u) => u['role'] == 'lawyer').length;
          activePolice = users.where((u) => u['role'] == 'police').length;
          recentCases = cases.take(5).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.arrow_forward_outlined, color: Colors.grey, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF001A3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, color: Color(0xFF001A3A), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "LexisCore Admin",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF001A3A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _fetchStats,
                            icon: const Icon(Icons.refresh, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Welcome Section
                      Text(
                        "System Overview",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF001A3A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Real-time metrics, users, cases and operations tracking.",
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Grid of Stats
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.2,
                        children: [
                          statCard("Total Users", "$totalUsers", Icons.people, Colors.indigo),
                          statCard("Active Cases", "$totalCases", Icons.folder, Colors.teal),
                          statCard("Lawyers Pool", "$activeLawyers", Icons.gavel, Colors.amber.shade800),
                          statCard("Police Accounts", "$activePolice", Icons.local_police, Colors.red.shade700),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Recent Cases Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Case Activity",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF001A3A),
                            ),
                          ),
                          Text(
                            "Latest submissions",
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of Recent Cases
                      recentCases.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text("No cases available in database.", style: GoogleFonts.inter(color: Colors.grey)),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recentCases.length,
                              itemBuilder: (context, index) {
                                final c = recentCases[index];
                                final String caseId = c['case_id'] ?? 'N/A';
                                final String type = c['type'] ?? 'General';
                                final String client = c['email'] ?? 'Unknown';
                                final String status = c['status'] ?? 'Submitted';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFFEAF0FF),
                                        child: Icon(
                                          type == 'Domestic Violence'
                                              ? Icons.family_restroom
                                              : type == 'Cyber Crime'
                                                  ? Icons.computer
                                                  : Icons.folder,
                                          color: const Color(0xFF001A3A),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type,
                                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text("ID: $caseId • Client: $client", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: status == 'Resolved' ? Colors.green.shade50 : Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: status == 'Resolved' ? Colors.green.shade700 : Colors.amber.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── USERS MANAGEMENT PAGE ───────────────────────────────────────────────────────

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = "";
  String roleFilter = "all";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/users'));
      if (response.statusCode == 200) {
        final List<dynamic> fetched = jsonDecode(response.body);
        setState(() {
          users = fetched;
          _filterUsers();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = users.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final matchesSearch = name.contains(searchQuery.toLowerCase()) || email.contains(searchQuery.toLowerCase());
        final matchesRole = roleFilter == 'all' || u['role'] == roleFilter;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _deleteUser(String email) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete User?", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
            content: Text("Are you sure you want to delete the user $email from the platform? This cannot be undone."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/delete-user'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User deleted successfully")));
        _fetchUsers();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete user"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network Error"), backgroundColor: Colors.red));
    }
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = "lawyer";
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "Register New User",
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: "Role"),
                  items: const [
                    DropdownMenuItem(value: "lawyer", child: Text("Lawyer")),
                    DropdownMenuItem(value: "police", child: Text("Police")),
                    DropdownMenuItem(value: "client", child: Text("Client")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRole = val);
                    }
                  },
                ),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Email and Password required"), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      try {
                        final res = await http.post(
                          Uri.parse('${ApiConfig.baseUrl}/signup'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "email": emailCtrl.text.trim(),
                            "password": passCtrl.text.trim(),
                            "name": nameCtrl.text.trim(),
                            "phone": phoneCtrl.text.trim(),
                            "role": selectedRole,
                          }),
                        );

                        if (res.statusCode == 201 || res.statusCode == 200) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User created successfully")));
                          _fetchUsers();
                        } else {
                          final msg = jsonDecode(res.body)['message'] ?? "Error occurred";
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network error"), backgroundColor: Colors.red));
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001A3A)),
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF001A3A),
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User Management",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001A3A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        searchQuery = val;
                        _filterUsers();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search users by name, email...",
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Filter Role Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        roleFilterButton("All Users", "all"),
                        roleFilterButton("Clients", "client"),
                        roleFilterButton("Lawyers", "lawyer"),
                        roleFilterButton("Police", "police"),
                        roleFilterButton("Admins", "admin"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Users List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? Center(child: Text("No users found.", style: GoogleFonts.inter(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _fetchUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final u = filteredUsers[index];
                              final String name = u['name'] ?? 'No Name';
                              final String email = u['email'] ?? 'No Email';
                              final String phone = u['phone'] ?? '';
                              final String role = u['role'] ?? 'client';

                              Color roleColor = Colors.indigo;
                              if (role == 'lawyer') roleColor = Colors.amber.shade800;
                              if (role == 'police') roleColor = Colors.red.shade700;
                              if (role == 'admin') roleColor = Colors.teal;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: roleColor.withOpacity(0.12),
                                      child: Icon(
                                        role == 'lawyer'
                                            ? Icons.gavel
                                            : role == 'police'
                                                ? Icons.local_police
                                                : role == 'admin'
                                                    ? Icons.admin_panel_settings
                                                    : Icons.person,
                                        color: roleColor,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(email, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                          if (phone.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(phone, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: roleColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            role.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: roleColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (email != 'admin@gmail.com')
                                          GestureDetector(
                                            onTap: () => _deleteUser(email),
                                            child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget roleFilterButton(String label, String value) {
    final active = roleFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        selectedColor: const Color(0xFF001A3A),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : Colors.black87,
        ),
        onSelected: (val) {
          if (val) {
            setState(() {
              roleFilter = value;
              _filterUsers();
            });
          }
        },
      ),
    );
  }
}

// ─── CASES MONITOR & ALLOCATION PAGE ──────────────────────────────────────────────

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  List<dynamic> cases = [];
  List<dynamic> filteredCases = [];
  List<dynamic> lawyers = [];
  List<dynamic> police = [];
  bool isLoading = true;
  String selectedFilter = "all";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final casesRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/all-cases'));
      final usersRes = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/users'));

      if (casesRes.statusCode == 200 && usersRes.statusCode == 200) {
        final List<dynamic> fetchedCases = jsonDecode(casesRes.body);
        final List<dynamic> fetchedUsers = jsonDecode(usersRes.body);

        setState(() {
          cases = fetchedCases;
          lawyers = fetchedUsers.where((u) => u['role'] == 'lawyer').toList();
          police = fetchedUsers.where((u) => u['role'] == 'police').toList();
          _filterCases();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterCases() {
    setState(() {
      filteredCases = cases.where((c) {
        final caseId = (c['case_id'] ?? '').toString().toLowerCase();
        final client = (c['email'] ?? '').toString().toLowerCase();
        final type = (c['type'] ?? '').toString().toLowerCase();
        final matchesSearch = caseId.contains(searchQuery.toLowerCase()) ||
            client.contains(searchQuery.toLowerCase()) ||
            type.contains(searchQuery.toLowerCase());

        if (selectedFilter == 'all') return matchesSearch;
        if (selectedFilter == 'unassigned') {
          return matchesSearch &&
              (c['assigned_lawyer'] == null ||
                  c['assigned_lawyer'] == 'unassigned_lawyer_pool' ||
                  c['assigned_police'] == null ||
                  c['assigned_police'] == 'unassigned_police_pool');
        }
        if (selectedFilter == 'assigned') {
          return matchesSearch &&
              c['assigned_lawyer'] != null &&
              c['assigned_lawyer'] != 'unassigned_lawyer_pool';
        }
        if (selectedFilter == 'resolved') {
          return matchesSearch && c['status'] == 'Resolved';
        }
        return matchesSearch;
      }).toList();
    });
  }

  Future<void> _allocateCase(String caseId, String assignTo, String targetEmail) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/assign-case'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "case_id": caseId,
          "assign_to": assignTo,
          "email": targetEmail,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Case allocated successfully.")));
        _fetchData();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to allocate case."), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Network Error"), backgroundColor: Colors.red));
    }
  }

  void _showAllocateDialog(String caseId, String currentLawyer, String currentPolice) {
    String? selectedLawyer = lawyers.any((l) => l['email'] == currentLawyer) ? currentLawyer : null;
    String? selectedPolice = police.any((p) => p['email'] == currentPolice) ? currentPolice : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "Allocate Case",
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select professional resources to allocate to Case $caseId.", style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 20),
              // Lawyer select
              DropdownButtonFormField<String>(
                value: selectedLawyer,
                decoration: const InputDecoration(labelText: "Assign Legal Representative (Lawyer)"),
                hint: const Text("Select Lawyer"),
                items: lawyers
                    .map((l) => DropdownMenuItem<String>(
                          value: l['email'],
                          child: Text("${l['name']} (${l['email']})"),
                        ))
                    .toList(),
                onChanged: (val) {
                  setDialogState(() => selectedLawyer = val);
                },
              ),
              const SizedBox(height: 16),
              // Police select
              DropdownButtonFormField<String>(
                value: selectedPolice,
                decoration: const InputDecoration(labelText: "Assign Enforcement / Station (Police)"),
                hint: const Text("Select Police Officer"),
                items: police
                    .map((p) => DropdownMenuItem<String>(
                          value: p['email'],
                          child: Text("${p['name']} (${p['email']})"),
                        ))
                    .toList(),
                onChanged: (val) {
                  setDialogState(() => selectedPolice = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (selectedLawyer != null) {
                  await _allocateCase(caseId, "lawyer", selectedLawyer!);
                }
                if (selectedPolice != null) {
                  await _allocateCase(caseId, "police", selectedPolice!);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001A3A)),
              child: const Text("Confirm Allocation", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaseDetailsDialog(Map<String, dynamic> c) {
    final type = c['type'] ?? 'General Case';
    final caseId = c['case_id'] ?? 'N/A';
    final client = c['email'] ?? 'Unknown';
    final details = c['details'] ?? {};
    final analysis = c['analysis'] ?? {};
    final status = c['status'] ?? 'Submitted';
    final assignedLawyer = c['assigned_lawyer'] ?? 'None';
    final assignedPolice = c['assigned_police'] ?? 'None';
    final handlingStatus = c['handling_status'] ?? 'None';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                type,
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Case ID: $caseId • Complainant: $client", style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                const Divider(height: 24),

                // Description or details
                Text("CASE DETAIL SUBMISSION", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  details['description'] ?? details['case_type'] ?? 'No details provided.',
                  style: GoogleFonts.inter(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),

                // AI Risk assessment
                if (analysis.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "AI Risk: ${analysis['risk_level'] ?? 'MEDIUM'}",
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          analysis['risk_summary'] ?? analysis['case_summary'] ?? 'AI calculated risk assessment details are available.',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.brown.shade800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Professionals assignments
                Text("ASSIGNMENTS & STATUS", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.gavel, size: 16, color: Color(0xFF001A3A)),
                    const SizedBox(width: 8),
                    Text("Lawyer: ", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(assignedLawyer, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_police, size: 16, color: Color(0xFF001A3A)),
                    const SizedBox(width: 8),
                    Text("Police: ", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(assignedPolice, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.track_changes, size: 16, color: Color(0xFF001A3A)),
                    const SizedBox(width: 8),
                    Text("Operational Status: ", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(handlingStatus, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAllocateDialog(caseId, assignedLawyer, assignedPolice);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001A3A)),
            child: const Text("Allocate / Reallocate", style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Case Allocation Center",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001A3A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        searchQuery = val;
                        _filterCases();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search by Case ID, client, category...",
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Choice Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        filterChip("All Cases", "all"),
                        filterChip("Needs Allocation", "unassigned"),
                        filterChip("Assigned", "assigned"),
                        filterChip("Resolved", "resolved"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cases list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCases.isEmpty
                      ? Center(child: Text("No cases match your filters.", style: GoogleFonts.inter(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCases.length,
                            itemBuilder: (context, index) {
                              final c = filteredCases[index];
                              final String caseId = c['case_id'] ?? 'N/A';
                              final String type = c['type'] ?? 'General';
                              final String client = c['email'] ?? 'Unknown';
                              final String status = c['status'] ?? 'Submitted';
                              final String lawyer = c['assigned_lawyer'] ?? 'unassigned';
                              final String police = c['assigned_police'] ?? 'unassigned';
                              final String handle = c['handling_status'] ?? 'Submitted';

                              final bool needsLawyer = lawyer == 'unassigned' || lawyer == 'unassigned_lawyer_pool';
                              final bool needsPolice = police == 'unassigned' || police == 'unassigned_police_pool';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey.shade100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Category & status
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            type,
                                            style: GoogleFonts.playfairDisplay(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: status == 'Resolved' ? Colors.green.shade50 : Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: status == 'Resolved' ? Colors.green.shade700 : Colors.amber.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text("Case ID: $caseId", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                    const Divider(height: 20),

                                    // Assignment status indicators
                                    Row(
                                      children: [
                                        Icon(Icons.gavel, size: 16, color: needsLawyer ? Colors.orange : Colors.green),
                                        const SizedBox(width: 8),
                                        Text(
                                          needsLawyer ? "Lawyer: Pending Allocation" : "Lawyer: $lawyer",
                                          style: GoogleFonts.inter(fontSize: 12, color: needsLawyer ? Colors.orange.shade900 : Colors.green.shade900, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.local_police, size: 16, color: needsPolice ? Colors.orange : Colors.green),
                                        const SizedBox(width: 8),
                                        Text(
                                          needsPolice ? "Police: Pending Notification" : "Police: $police",
                                          style: GoogleFonts.inter(fontSize: 12, color: needsPolice ? Colors.orange.shade900 : Colors.green.shade900, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.circle, size: 10, color: Colors.blue),
                                        const SizedBox(width: 14),
                                        Text("Operation: $handle", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _showCaseDetailsDialog(c),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: Text("VIEW DOSSIER", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF001A3A))),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _showAllocateDialog(caseId, lawyer, police),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF001A3A),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: Text("ALLOCATE Resources", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChip(String label, String value) {
    final active = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        selectedColor: const Color(0xFF001A3A),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : Colors.black87,
        ),
        onSelected: (val) {
          if (val) {
            setState(() {
              selectedFilter = value;
              _filterCases();
            });
          }
        },
      ),
    );
  }
}

// ─── OPERATIONAL REPORTS & STATISTICS PAGE ─────────────────────────────────────────

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool isLoading = true;
  Map<String, int> typeCounts = {};
  Map<String, int> riskCounts = {};
  int unresolvedCount = 0;
  int resolvedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/admin/all-cases'));
      if (response.statusCode == 200) {
        final List<dynamic> cases = jsonDecode(response.body);

        final Map<String, int> types = {};
        final Map<String, int> risks = {};
        int unresolved = 0;
        int resolved = 0;

        for (var c in cases) {
          final String type = c['type'] ?? 'General Case';
          final analysis = c['analysis'] ?? {};
          final String risk = analysis['risk_level'] ?? 'MEDIUM';
          final String status = c['status'] ?? 'Submitted';

          types[type] = (types[type] ?? 0) + 1;
          risks[risk] = (risks[risk] ?? 0) + 1;

          if (status == 'Resolved') {
            resolved++;
          } else {
            unresolved++;
          }
        }

        setState(() {
          typeCounts = types;
          riskCounts = risks;
          unresolvedCount = unresolved;
          resolvedCount = resolved;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchReportData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Operational Reports",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF001A3A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Diagnostic overview of the platforms operations and load distribution.", style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 24),

                      // Section 1: Resolution Rate
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Case Resolution Progress", style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A))),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Active Claims", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                                      Text("$unresolvedCount cases", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 40, color: Colors.grey.shade200),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Resolved Claims", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                                      Text("$resolvedCount cases", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Simple Resolution progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (resolvedCount + unresolvedCount) > 0 ? resolvedCount / (resolvedCount + unresolvedCount) : 0,
                                minHeight: 10,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Resolution Rate: ${(resolvedCount + unresolvedCount) > 0 ? ((resolvedCount / (resolvedCount + unresolvedCount)) * 100).toStringAsFixed(1) : 0}%",
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Case distribution chart list
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Case Category Breakdowns", style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A))),
                            const SizedBox(height: 16),
                            typeCounts.isEmpty
                                ? Center(child: Text("No cases filed yet.", style: GoogleFonts.inter(color: Colors.grey)))
                                : Column(
                                    children: typeCounts.entries.map((e) {
                                      final maxVal = typeCounts.values.reduce((a, b) => a > b ? a : b);
                                      final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(e.key, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                                                Text("${e.value} cases", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: ratio,
                                                minHeight: 8,
                                                backgroundColor: Colors.grey.shade100,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF001A3A)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Risk levels distribution
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AI Risk Level Breakdown", style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A))),
                            const SizedBox(height: 16),
                            riskCounts.isEmpty
                                ? Center(child: Text("No data available.", style: GoogleFonts.inter(color: Colors.grey)))
                                : Column(
                                    children: riskCounts.entries.map((e) {
                                      final String risk = e.key;
                                      final int count = e.value;
                                      Color rColor = Colors.green;
                                      if (risk == 'HIGH') rColor = Colors.red.shade700;
                                      if (risk == 'MEDIUM') rColor = Colors.orange;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: rColor.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: rColor.withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.warning, color: rColor, size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "$risk Severity Cases",
                                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: rColor),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "$count cases",
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── ADMIN PROFILE PAGE ──────────────────────────────────────────────────────────

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
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF0FF),
            child: Icon(icon, color: const Color(0xFF001A3A)),
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
                    color: const Color(0xFF001A3A),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Admin Profile", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF001A3A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFEAF0FF),
              child: Icon(Icons.person, size: 50, color: Color(0xFF001A3A)),
            ),
            const SizedBox(height: 18),
            Text(
              adminName,
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF001A3A)),
            ),
            const SizedBox(height: 6),
            Text(
              "System Administrator",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            infoTile(Icons.email, "Email Address", adminEmail),
            infoTile(Icons.phone, "Phone Number", adminPhone),
            infoTile(Icons.security, "Access Level", "Full Administrator"),
            const SizedBox(height: 32),
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