import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

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

  Widget invoiceCard({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor:
                    Color(0xFFEAF0FF),
                child: Icon(
                  Icons.receipt_long,
                  color:
                      Color(0xFF0B132B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style:
                      GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        const Color(0xFF0B132B),
                  ),
                ),
              ),
              Text(
                amount,
                style:
                    GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      const Color(
                          0xFF001A3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.event,
                  size: 18,
                  color:
                      Color(0xFF0B132B)),
              const SizedBox(width: 8),
              Text(
                date,
                style:
                    GoogleFonts.inter(
                  fontSize: 13,
                  color:
                      Colors.black54,
                ),
              ),
              const Spacer(),
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
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.payment,
                color: Colors.white,
              ),
              label: Text(
                "PAY NOW",
                style:
                    GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
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
                      BorderRadius
                          .circular(12),
                ),
              ),
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
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(
                    Icons.gavel,
                    color:
                        Color(0xFF0B132B),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "LexisAI",
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
                  const Icon(
                    Icons.account_balance_wallet,
                    color:
                        Color(0xFF0B132B),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                        20),
                child: Column(
                  children: [
                    Text(
                      "Billing",
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            const Color(
                                0xFF0B132B),
                      ),
                    ),
                    const SizedBox(
                        height: 12),
                    Text(
                      "View invoices, pending payments and transaction history.",
                      textAlign:
                          TextAlign.center,
                      style:
                          GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors
                            .black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        topTag(Icons.payment,
                            "Payments"),
                        topTag(Icons.receipt,
                            "Invoices"),
                        topTag(Icons.security,
                            "Secure"),
                      ],
                    ),
                    const SizedBox(
                        height: 24),
                    invoiceCard(
                      title:
                          "Consultation Fee",
                      date:
                          "20 Apr 2026",
                      amount:
                          "₹2,000",
                      status:
                          "Pending",
                      color: Colors.red,
                    ),
                    invoiceCard(
                      title:
                          "Case Filing Fee",
                      date:
                          "12 Apr 2026",
                      amount:
                          "₹5,500",
                      status:
                          "Paid",
                      color: Colors.green,
                    ),
                    invoiceCard(
                      title:
                          "Draft Agreement",
                      date:
                          "05 Apr 2026",
                      amount:
                          "₹3,000",
                      status:
                          "Paid",
                      color: Colors.green,
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