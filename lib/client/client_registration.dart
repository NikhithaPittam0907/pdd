import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() =>
      _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState
    extends State<ClientRegistrationScreen> {
  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController phoneController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  Widget topTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF0B132B),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B132B),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.grey,
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
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
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 34,
                backgroundColor:
                    Color(0xFFEAF0FF),
                child: Icon(
                  Icons.person_add,
                  size: 34,
                  color:
                      Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Client Registration",
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
              const SizedBox(height: 12),
              Text(
                "Create your secure account to access legal services and case tracking.",
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
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  topTag(Icons.security,
                      "Secure"),
                  topTag(Icons.folder,
                      "Cases"),
                  topTag(Icons.chat,
                      "AI Help"),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding:
                    const EdgeInsets.all(
                        20),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                              18),
                  boxShadow: const [
                    BoxShadow(
                      color:
                          Colors.black12,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    inputField(
                      "Full Name",
                      Icons.person,
                      nameController,
                    ),
                    const SizedBox(
                        height: 16),
                    inputField(
                      "Email Address",
                      Icons.email,
                      emailController,
                    ),
                    const SizedBox(
                        height: 16),
                    inputField(
                      "Phone Number",
                      Icons.phone,
                      phoneController,
                    ),
                    const SizedBox(
                        height: 16),
                    inputField(
                      "Password",
                      Icons.lock,
                      passwordController,
                      obscure: true,
                    ),
                    const SizedBox(
                        height: 22),
                    SizedBox(
                      width:
                          double.infinity,
                      height: 54,
                      child:
                          ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons
                              .arrow_forward,
                          color:
                              Colors.white,
                        ),
                        label: Text(
                          "CREATE ACCOUNT",
                          style:
                              GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color: Colors
                                .white,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF001A3A),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}