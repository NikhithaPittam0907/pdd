import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';

class LegalResearchScreen extends StatefulWidget {
  const LegalResearchScreen({super.key});

  @override
  State<LegalResearchScreen> createState() => _LegalResearchScreenState();
}

class _LegalResearchScreenState extends State<LegalResearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _baseUrl = ApiConfig.baseUrl;

  List<dynamic> _articles = [];
  List<dynamic> _savedArticles = [];
  bool _isLoading = true;
  bool _isSavedLoading = false;
  String? _errorMessage;
  String _selectedCategory = "All";
  int _activeTabIndex = 0; // 0: Latest Updates, 1: Saved Research
  String _userEmail = "";

  final List<String> _categories = [
    "All",
    "Supreme Court",
    "High Court",
    "Criminal",
    "Civil",
    "Constitutional",
    "Corporate",
    "Cyber Law",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email') ?? "lawyer@gmail.com";
    });
    _fetchLegalUpdates();
    _fetchSavedArticles();
  }

  Future<void> _fetchLegalUpdates({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String endpoint = (query != null && query.trim().isNotEmpty)
          ? "$_baseUrl/api/legal-search?q=${Uri.encodeComponent(query.trim())}"
          : "$_baseUrl/api/legal-updates";

      final response = await http.get(Uri.parse(endpoint)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _articles = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Legal research service is currently unavailable.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Unable to load legal updates. Please check your network connection.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSavedArticles() async {
    if (_userEmail.isEmpty) return;
    setState(() => _isSavedLoading = true);
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/api/legal-research/saved?email=$_userEmail"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _savedArticles = data;
            _isSavedLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isSavedLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isSavedLoading = false);
    }
  }

  Future<void> _openArticleUrl(String urlString) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Original article URL is not available.")),
      );
      return;
    }

    final Uri? uri = Uri.tryParse(urlString);
    if (uri != null) {
      try {
        final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open article URL.")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error opening URL: $e")),
          );
        }
      }
    }
  }

  Future<void> _saveArticle(Map<String, dynamic> article) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/legal-research/save"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _userEmail,
          "title": article["title"],
          "description": article["description"],
          "source": article["source"],
          "url": article["url"],
          "image": article["image"],
          "category": article["category"],
          "publishedAt": article["publishedAt"],
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Article saved successfully")),
      );
      _fetchSavedArticles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save article. Connection error.")),
      );
    }
  }

  Future<void> _removeSavedArticle(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/api/legal-research/saved/$id?email=$_userEmail"),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Removed from saved library")),
      );
      _fetchSavedArticles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error removing saved item.")),
      );
    }
  }

  void _showAIAnalyseModal(Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return FutureBuilder<http.Response>(
              future: http.post(
                Uri.parse("$_baseUrl/api/legal-research/analyse"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "title": article["title"],
                  "description": article["description"],
                  "content": article["content"],
                  "category": article["category"],
                }),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF001A3A)),
                        const SizedBox(height: 20),
                        Text(
                          "Analyzing Legal Update with AI...",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF001A3A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Extracting ratio decidendi, relevant sections and legal principles.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                Map<String, dynamic> analysis = {};
                if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                  try {
                    analysis = jsonDecode(snapshot.data!.body);
                  } catch (_) {}
                }

                final String disclaimer = analysis["disclaimer"] ??
                    "AI-generated legal analysis. Verify with the original legal source before relying on it.";

                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Modal Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF001A3A).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, color: Color(0xFF001A3A), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CASE / LEGAL UPDATE ANALYSIS",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF001A3A),
                                  ),
                                ),
                                Text(
                                  article["title"] ?? "Legal Analysis",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0B132B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mandatory Disclaimer Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                disclaimer,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Structured Sections
                      _buildAnalysisSection("Summary", analysis["summary"] ?? article["description"] ?? "Summary unavailable."),
                      _buildAnalysisSection("Key Legal Issue", analysis["key_legal_issue"] ?? "Information unavailable in article text."),
                      _buildAnalysisSection("Relevant Acts / Sections", analysis["relevant_acts_sections"] ?? "Information unavailable in article text."),
                      _buildAnalysisSection("Court / Authority", analysis["court_authority"] ?? article["category"] ?? "Judicial Authority"),
                      _buildAnalysisSection("Important Legal Principles", analysis["important_legal_principles"] ?? "Information unavailable in article text."),
                      _buildAnalysisSection("Potential Impact", analysis["potential_impact"] ?? "Information unavailable in article text."),
                      _buildAnalysisSection("Key Takeaways", analysis["key_takeaways"] ?? "Information unavailable in article text."),

                      const SizedBox(height: 16),
                      // Source link button
                      if ((article["url"] ?? "").isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openArticleUrl(article["url"]),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text("View Original Publisher Source"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAnalysisSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF001A3A),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> get _filteredArticles {
    if (_selectedCategory == "All") return _articles;
    return _articles
        .where((a) => (a["category"] ?? "").toString().toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  Widget _buildArticleCard(Map<String, dynamic> article, {bool isSavedView = false, int? savedId}) {
    final String title = article["title"] ?? "Legal Update";
    final String desc = article["description"] ?? "";
    final String source = article["source"] ?? "Indian Legal News";
    final String category = article["category"] ?? "Legal";
    final String imageUrl = article["image"] ?? "";
    final String publishedAt = article["publishedAt"] ?? article["published_at"] ?? "";
    final String dateStr = publishedAt.isNotEmpty ? publishedAt.split('T')[0] : "";

    Color categoryColor = Colors.indigo;
    if (category == "Supreme Court") categoryColor = Colors.red.shade700;
    if (category == "High Court") categoryColor = Colors.amber.shade800;
    if (category == "Cyber Law") categoryColor = Colors.teal;
    if (category == "Criminal") categoryColor = Colors.deepOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image (if available)
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: const Color(0xFFEAF0FF),
                  alignment: Alignment.center,
                  child: const Icon(Icons.gavel, color: Color(0xFF001A3A), size: 36),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Date Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (dateStr.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(dateStr, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B132B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Short Description
                if (desc.isNotEmpty)
                  Text(
                    desc,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 12),

                // Publisher Source
                Row(
                  children: [
                    const Icon(Icons.newspaper, size: 14, color: Colors.black45),
                    const SizedBox(width: 6),
                    Text(
                      source,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Action Buttons Row
                Row(
                  children: [
                    // Read More Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openArticleUrl(article["url"] ?? ""),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: Text(
                          "Read More",
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // AI Analyse Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAIAnalyseModal(article),
                        icon: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                        label: Text(
                          "AI Analyse",
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001A3A),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Save / Delete Icon Button
                    if (!isSavedView)
                      IconButton(
                        onPressed: () => _saveArticle(article),
                        icon: const Icon(Icons.bookmark_border, color: Color(0xFF001A3A)),
                        tooltip: "Save to Library",
                      )
                    else if (savedId != null)
                      IconButton(
                        onPressed: () => _removeSavedArticle(savedId),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: "Remove from Saved",
                      ),
                  ],
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0B132B)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.gavel, color: Color(0xFF001A3A)),
                  const SizedBox(width: 10),
                  Text(
                    "LexisAI",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001A3A),
                    ),
                  ),
                  const Spacer(),
                  // Toggle View Buttons (Latest vs Saved)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _activeTabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _activeTabIndex == 0 ? const Color(0xFF001A3A) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Latest",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _activeTabIndex == 0 ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _activeTabIndex = 1);
                            _fetchSavedArticles();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _activeTabIndex == 1 ? const Color(0xFF001A3A) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark,
                                  size: 14,
                                  color: _activeTabIndex == 1 ? Colors.white : Colors.black87,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Saved",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _activeTabIndex == 1 ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Body Content
            Expanded(
              child: _activeTabIndex == 1
                  ? _buildSavedResearchView()
                  : RefreshIndicator(
                      onRefresh: () => _fetchLegalUpdates(query: _searchController.text),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth > 900 ? 900 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Screen Header
                              Text(
                                "Legal Research",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF001A3A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Stay updated with the latest legal developments",
                                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 20),

                              // Search Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onSubmitted: (query) => _fetchLegalUpdates(query: query),
                                  style: GoogleFonts.inter(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "Search cases, judgments, Acts or legal topics...",
                                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF001A3A)),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send, color: Color(0xFF001A3A), size: 20),
                                      onPressed: () => _fetchLegalUpdates(query: _searchController.text),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Category Filters (Horizontal Scroll)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _categories.map((cat) {
                                    final bool active = _selectedCategory == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(cat),
                                        selected: active,
                                        selectedColor: const Color(0xFF001A3A),
                                        backgroundColor: Colors.white,
                                        labelStyle: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: active ? Colors.white : Colors.black87,
                                        ),
                                        onSelected: (val) {
                                          if (val) {
                                            setState(() => _selectedCategory = cat);
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Loading / Error / Content states
                              if (_isLoading)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 60),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const CircularProgressIndicator(color: Color(0xFF001A3A)),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Fetching latest legal updates...",
                                          style: GoogleFonts.inter(color: Colors.black54, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 60),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                                        const SizedBox(height: 16),
                                        Text(
                                          _errorMessage!,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          onPressed: () => _fetchLegalUpdates(query: _searchController.text),
                                          icon: const Icon(Icons.refresh, color: Colors.white),
                                          label: const Text("Retry"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF001A3A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (_filteredArticles.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 60),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                        const SizedBox(height: 16),
                                        Text(
                                          "No legal updates found.",
                                          style: GoogleFonts.inter(color: Colors.black54, fontSize: 15),
                                        ),
                                        const SizedBox(height: 12),
                                        TextButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _selectedCategory = "All");
                                            _fetchLegalUpdates();
                                          },
                                          child: const Text("Reset Filters"),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _filteredArticles.length,
                                  itemBuilder: (context, index) {
                                    return _buildArticleCard(_filteredArticles[index]);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedResearchView() {
    return RefreshIndicator(
      onRefresh: _fetchSavedArticles,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Saved Research Library",
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001A3A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Access your bookmarked legal articles and court updates.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            if (_isSavedLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF001A3A))),
              )
            else if (_savedArticles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.bookmark_border, size: 54, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "No saved legal research items found.",
                        style: GoogleFonts.inter(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bookmark articles from the 'Latest' tab to access them anytime.",
                        style: GoogleFonts.inter(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedArticles.length,
                itemBuilder: (context, index) {
                  final item = _savedArticles[index];
                  return _buildArticleCard(
                    item,
                    isSavedView: true,
                    savedId: item["id"],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}