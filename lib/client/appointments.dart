import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _lawyers = [];
  List<dynamic> _myAppointments = [];
  bool _loadingLawyers = true;
  bool _loadingAppts = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLawyers();
    _fetchMyAppointments();
  }

  Future<void> _fetchLawyers() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/get-lawyers'));
      if (res.statusCode == 200) {
        setState(() {
          _lawyers = jsonDecode(res.body);
          _loadingLawyers = false;
        });
      } else {
        setState(() => _loadingLawyers = false);
      }
    } catch (_) {
      setState(() => _loadingLawyers = false);
    }
  }

  Future<void> _fetchMyAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/get-appointments?email=$email&role=client'),
      );
      if (res.statusCode == 200) {
        setState(() {
          _myAppointments = jsonDecode(res.body);
          _loadingAppts = false;
        });
      } else {
        setState(() => _loadingAppts = false);
      }
    } catch (_) {
      setState(() => _loadingAppts = false);
    }
  }

  void _showBookingDialog(Map<String, dynamic> lawyer) {
    DateTime? selectedDate;
    String? selectedSlot;
    final reasonCtrl = TextEditingController();
    final List<String> slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];
    bool booking = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Book Appointment',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                const SizedBox(height: 6),
                Text('with ${lawyer['name']}',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 24),

                // Date picker
                Text('SELECT DATE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black45)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: selectedDate != null ? const Color(0xFF0B132B) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                      color: selectedDate != null ? const Color(0xFFEAF0FF) : Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF0B132B)),
                        const SizedBox(width: 10),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Tap to select a date',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: selectedDate != null ? const Color(0xFF0B132B) : Colors.black45,
                            fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time slots
                Text('SELECT TIME SLOT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black45)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((slot) {
                    final isSelected = selectedSlot == slot;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedSlot = slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0B132B) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? const Color(0xFF0B132B) : Colors.grey.shade200),
                        ),
                        child: Text(
                          slot,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Reason
                Text('REASON (OPTIONAL)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black45)),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Briefly describe your legal concern...',
                    hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: booking
                        ? null
                        : () async {
                            if (selectedDate == null || selectedSlot == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a date and time slot.')),
                              );
                              return;
                            }
                            setModalState(() => booking = true);
                            final prefs = await SharedPreferences.getInstance();
                            final clientEmail = prefs.getString('email') ?? '';
                            final clientName = prefs.getString('name') ?? '';
                            final dateStr = '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
                            final res = await http.post(
                              Uri.parse('${ApiConfig.baseUrl}/book-appointment'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'client_email': clientEmail,
                                'client_name': clientName,
                                'lawyer_email': lawyer['email'],
                                'lawyer_name': lawyer['name'],
                                'date': dateStr,
                                'time_slot': selectedSlot,
                                'reason': reasonCtrl.text,
                              }),
                            );
                            setModalState(() => booking = false);
                            if (!ctx.mounted) return;
                            final nav = Navigator.of(ctx);
                            final messenger = ScaffoldMessenger.of(context);
                            if (res.statusCode == 200) {
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Appointment booked successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _fetchMyAppointments();
                              _tabController.animateTo(1);
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Failed to book appointment.')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B132B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: booking
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text('Confirm Booking',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed': return Colors.green;
      case 'Declined': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLawyers = _lawyers
        .where((l) => (l['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: Color(0xFF0B132B), size: 18),
                  const SizedBox(width: 8),
                  Text('LexisAI', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                  const Spacer(),
                  const Icon(Icons.verified_user, color: Color(0xFF0B132B), size: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Appointments', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
            ),
            const SizedBox(height: 16),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF0B132B),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                tabs: const [Tab(text: 'Find Lawyers'), Tab(text: 'My Appointments')],
              ),
            ),
            const SizedBox(height: 16),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- FIND LAWYERS TAB ---
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.search, color: Colors.black45),
                              hintText: 'Search lawyers by name...',
                              hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _loadingLawyers
                            ? const Center(child: CircularProgressIndicator())
                            : filteredLawyers.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_search, size: 60, color: Colors.grey.shade300),
                                        const SizedBox(height: 16),
                                        Text('No lawyers registered yet.', style: GoogleFonts.inter(color: Colors.black45)),
                                        const SizedBox(height: 6),
                                        Text('Lawyers need to sign up with the Lawyer role.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _fetchLawyers,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: filteredLawyers.length,
                                      itemBuilder: (_, i) {
                                        final l = filteredLawyers[i];
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 14),
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 52,
                                                height: 52,
                                                decoration: const BoxDecoration(color: Color(0xFFEAF0FF), shape: BoxShape.circle),
                                                child: const Icon(Icons.person, color: Color(0xFF0B132B), size: 28),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(l['name'] ?? '', style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                                                    const SizedBox(height: 4),
                                                    Text(l['email'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                                      child: Text('Available', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => _showBookingDialog(l),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF0B132B),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                ),
                                                child: Text('Book', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
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

                  // --- MY APPOINTMENTS TAB ---
                  _loadingAppts
                      ? const Center(child: CircularProgressIndicator())
                      : _myAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, size: 60, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text('No appointments booked yet.', style: GoogleFonts.inter(color: Colors.black45)),
                                  const SizedBox(height: 6),
                                  Text('Find a lawyer and book a consultation.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchMyAppointments,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _myAppointments.length,
                                itemBuilder: (_, i) {
                                  final a = _myAppointments[i];
                                  final statusColor = _statusColor(a['status'] ?? 'Pending');
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text('Appt. with ${a['lawyer_name'] ?? a['lawyer_email']}',
                                                  style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(a['status'] ?? 'Pending',
                                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _apptRow(Icons.calendar_today, '${a['date']}'),
                                        const SizedBox(height: 6),
                                        _apptRow(Icons.access_time, '${a['time_slot']}'),
                                        if ((a['reason'] ?? '').isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          _apptRow(Icons.notes, a['reason']),
                                        ],
                                      ],
                                    ),
                                  );
                                },
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

  Widget _apptRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54))),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}