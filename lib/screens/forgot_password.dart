import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'signin_screen.dart';
import '../config/api_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;
  int currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  bool obscure = true;

  final String baseUrl = ApiConfig.baseUrl;

  Future<void> sendRecovery() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));

      if (response.statusCode == 200) {
        setState(() {
          currentStep = 1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection Error")));
    }

    setState(() => isLoading = false);
  }

  void verifyOtp() {
    if (otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP must be 6 digits")));
      return;
    }
    setState(() {
      currentStep = 2;
    });
  }

  Future<void> resetPassword() async {
    final pwd = passwordController.text;
    if (pwd.length < 8 ||
        !pwd.contains(RegExp(r'[A-Z]')) ||
        !pwd.contains(RegExp(r'[a-z]')) ||
        !pwd.contains(RegExp(r'[0-9]')) ||
        !pwd.contains(RegExp(r'[!@#\$&*~_]'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password must be at least 8 chars with uppercase, lowercase, number & special char."),
        duration: Duration(seconds: 4),
      ));
      return;
    }

    if (pwd != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "otp": otpController.text.trim(),
          "password": pwd,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));

      if (response.statusCode == 200) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection Error")));
    }

    setState(() => isLoading = false);
  }

  Widget buildField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    IconData? icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      keyboardType: type,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                onPressed: () => setState(() => obscure = !obscure),
              )
            : Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: Color(0xFF0B132B)),
                  const SizedBox(width: 10),
                  Text("LexisAI", style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                  const Spacer(),
                  const Icon(Icons.verified_user, color: Color(0xFF0B132B)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFEAF0FF), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.lock_reset, size: 48, color: Color(0xFF0B132B)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentStep == 0 ? "Password Recovery" : currentStep == 1 ? "Verify OTP" : "New Password",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(fontSize: 34, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentStep == 0 ? "Enter your registered email to receive a secure recovery link." 
                      : currentStep == 1 ? "Enter the 6-digit OTP sent to your email." 
                      : "Create a new secure password.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 16, color: Colors.black54, height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentStep == 0) ...[
                            Text("PROFESSIONAL EMAIL ADDRESS", style: GoogleFonts.inter(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                            const SizedBox(height: 12),
                            buildField(hint: "name@firm.com", controller: emailController, icon: Icons.email_outlined, type: TextInputType.emailAddress),
                          ] else if (currentStep == 1) ...[
                            Text("ONE-TIME PASSWORD", style: GoogleFonts.inter(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                            const SizedBox(height: 12),
                            buildField(hint: "123456", controller: otpController, icon: Icons.pin, type: TextInputType.number),
                          ] else ...[
                            Text("NEW PASSWORD", style: GoogleFonts.inter(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                            const SizedBox(height: 12),
                            buildField(hint: "••••••••", controller: passwordController, isPassword: true),
                            const SizedBox(height: 8),
                            Text("Must be 8+ chars with uppercase, lowercase, number & special char.", style: GoogleFonts.inter(fontSize: 11, color: Colors.black54)),
                            const SizedBox(height: 16),
                            Text("CONFIRM PASSWORD", style: GoogleFonts.inter(fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B))),
                            const SizedBox(height: 12),
                            buildField(hint: "••••••••", controller: confirmController, isPassword: true),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : (currentStep == 0 ? sendRecovery : currentStep == 1 ? verifyOtp : resetPassword),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001A3A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      currentStep == 0 ? "SEND RECOVERY LINK →" : currentStep == 1 ? "VERIFY OTP →" : "RESET PASSWORD →",
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (currentStep > 0) {
                                  setState(() => currentStep--);
                                } else {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                                }
                              },
                              child: Text(
                                currentStep > 0 ? "← Back" : "← Back to secure login",
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
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
          ],
        ),
      ),
    );
  }
}
