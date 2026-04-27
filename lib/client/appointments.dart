import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, color: Color(0xFF0B132B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "LexisCore AI",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.verified_user, color: Color(0xFF0B132B), size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Appointments",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: Colors.black45, size: 20),
                    hintText: "Search lawyers bar",
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Filter Pills
              Row(
                children: [
                  filterPill("All", true),
                  const SizedBox(width: 10),
                  filterPill("Available Today", false),
                  const SizedBox(width: 10),
                  filterPill("Top Rated", false),
                ],
              ),
              const SizedBox(height: 32),

              // Upcoming Appointments Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Upcoming\nAppointments",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B132B),
                        height: 1.1,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 14, color: Color(0xFF8A6A00)),
                      const SizedBox(width: 8),
                      Text(
                        "Attorney-Client\nPrivileged",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A6A00),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Upcoming Appointment Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A3E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sarah Jenkins",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  "Oct 25, 10:00 AM",
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A6A00),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Join",
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Reschedule",
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Specialists for You
              Text(
                "Specialists for You",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B132B),
                ),
              ),
              const SizedBox(height: 16),

              // Specialist 1
              lawyerCard(
                name: "Marcus Thorne, Esq.",
                specialty: "Corporate & Intellectual Property",
                rating: "4.9",
                reviews: "120+",
                exp: "12 Years Exp",
                price: "\$250",
                slots: ["02:00 PM", "03:30 PM", "05:00 PM"],
                imageUrl: "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=200",
                isTopRated: true,
              ),
              const SizedBox(height: 16),

              // Specialist 2
              lawyerCard(
                name: "Elena Rodriguez, Esq.",
                specialty: "Family & Estate Planning",
                rating: "5.0",
                reviews: "84",
                exp: "15 Years Exp",
                price: "\$320",
                slots: ["09:00 AM", "11:30 AM", "04:15 PM"],
                imageUrl: "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=200",
                isTopRated: false,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterPill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0B132B) : const Color(0xFFEef2ff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? Colors.white : const Color(0xFF0B132B),
        ),
      ),
    );
  }

  Widget lawyerCard({
    required String name,
    required String specialty,
    required String rating,
    required String reviews,
    required String exp,
    required String price,
    required List<String> slots,
    required String imageUrl,
    required bool isTopRated,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
                        if (isTopRated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFDE9B6), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              "Top\nRated",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF8A6A00)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(specialty, style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFF8A6A00)),
                        const SizedBox(width: 4),
                        Text("$rating ($reviews reviews)", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Text(exp, style: GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Available Slots", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0B132B))),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: price, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w400, color: const Color(0xFF0B132B))),
                    TextSpan(text: "/hr", style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: slots.map((slot) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(slot, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07142A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {},
              child: Text(
                "Book Appointment",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}