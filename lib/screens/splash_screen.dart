import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'signin_screen.dart';
import '../client/client_dashboard.dart';
import '../lawyer/lawyer_dashboard.dart';
import '../police/police_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../config/api_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? role = prefs.getString('role');

    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (email != null && email.isNotEmpty && role != null && role.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse("${ApiConfig.baseUrl}/verify-user?email=$email"),
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['valid'] == true) {
            final verifiedRole = data['role'] ?? role;
            if (verifiedRole == 'lawyer') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LawyerDashboard()),
              );
            } else if (verifiedRole == 'police') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PoliceDashboard()),
              );
            } else if (verifiedRole == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ClientDashboard()),
              );
            }
            return;
          }
        }
      } catch (_) {
        // Fallback or network error handling
      }
      
      // If user is not found in DB or verification failed, clear session
      await prefs.clear();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: const Icon(
                    Icons.gavel,
                    size: 70,
                    color: Color(0xFF0B132B),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "LexisAI",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B132B),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "AI Powered Legal Assistant",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF001A3A),
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
