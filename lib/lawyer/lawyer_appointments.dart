import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class LawyerAppointmentsScreen extends StatefulWidget {
  const LawyerAppointmentsScreen({super.key});

  @override
  State<LawyerAppointmentsScreen> createState() => _LawyerAppointmentsScreenState();
}

class _LawyerAppointmentsScreenState extends State<LawyerAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/get-appointments?email=$email&role=lawyer'),
      );
      if (res.statusCode == 200) {
        setState(() {
          _appointments = jsonDecode(res.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/update-appointment-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'status': status}),
      );
      if (res.statusCode == 200) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Appointment $status'),
            backgroundColor: status == 'Confirmed' ? Colors.green : Colors.red,
          ),
        );
        _fetchAppointments();
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    }
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
    final pending = _appointments.where((a) => a['status'] == 'Pending').toList();
    final others = _appointments.where((a) => a['status'] != 'Pending').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: Color(0xFF0B132B)),
                  const SizedBox(width: 10),
                  Text('LexisAI',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                  const Spacer(),
                  const Icon(Icons.calendar_month, color: Color(0xFF0B132B)),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No appointments yet.',
                                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black45)),
                              const SizedBox(height: 6),
                              Text('Clients will book appointments with you here.',
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchAppointments,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Appointments',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                                const SizedBox(height: 4),
                                Text('Manage client consultation requests.',
                                    style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
                                const SizedBox(height: 24),

                                // Pending requests
                                if (pending.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Container(width: 4, height: 18, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                                      const SizedBox(width: 8),
                                      Text('Pending Requests (${pending.length})',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...pending.map((a) => _buildCard(a, isPending: true)),
                                  const SizedBox(height: 20),
                                ],

                                // Past / confirmed / declined
                                if (others.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(2))),
                                      const SizedBox(width: 8),
                                      Text('All Appointments',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...others.map((a) => _buildCard(a, isPending: false)),
                                ],
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> a, {required bool isPending}) {
    final statusColor = _statusColor(a['status'] ?? 'Pending');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: isPending ? Border.all(color: Colors.orange.withOpacity(0.4)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFEAF0FF), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Color(0xFF0B132B), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['client_name'] ?? a['client_email'] ?? 'Client',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                    Text(a['client_email'] ?? '',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                  ],
                ),
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
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _infoChip(Icons.calendar_today, a['date'] ?? ''),
              const SizedBox(width: 12),
              _infoChip(Icons.access_time, a['time_slot'] ?? ''),
            ],
          ),
          if ((a['reason'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes, size: 15, color: Colors.black45),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(a['reason'],
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.black54, height: 1.4)),
                ),
              ],
            ),
          ],

          // Action buttons only for pending
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(a['id'], 'Declined'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Decline',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(a['id'], 'Confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Confirm',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 5),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
      ],
    );
  }
}
