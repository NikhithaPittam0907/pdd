import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerManagementScreen extends StatelessWidget {
  const LawyerManagementScreen({super.key});

  Widget lawyerCard({
    required String name,
    required String field,
    required String email,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor:
                Color(0xFFEAF0FF),
            child: Icon(
              Icons.person,
              size: 28,
              color:
                  Color(0xFF0B132B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(0xFF0B132B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  field,
                  style:
                      GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style:
                      GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit,
                  color:
                      Color(0xFF0B132B),
                ),
              ),
            ],
          )
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Lawyer Management",
          style:
              GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight:
                FontWeight.bold,
            color:
                const Color(0xFF0B132B),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF0B132B),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFF001A3A),
        onPressed: () {},
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            lawyerCard(
              name: "Adv. Rahul Sharma",
              field: "Civil Law",
              email: "rahul@email.com",
              status: "Active",
              color: Colors.green,
            ),
            lawyerCard(
              name: "Adv. Priya Menon",
              field: "Corporate Law",
              email: "priya@email.com",
              status: "Active",
              color: Colors.green,
            ),
            lawyerCard(
              name: "Adv. Arjun Rao",
              field: "Family Law",
              email: "arjun@email.com",
              status: "Inactive",
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}