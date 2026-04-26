import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  bool isContactUs = true;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> faqs = [
    {
      "question": "What is NuroVed and how does it work?",
      "answer":
          "NuroVed is an AI-powered health companion that understands your lifestyle, preferences, and medical context to provide personalized diet plans, insights, and health guidance—all in one place.",
      "isExpanded": false,
    },
    {
      "question": "How is NuroVed different from other health apps?",
      "answer":
          "Unlike generic trackers, NuroVed adapts to you. It combines AI, real-time analysis, and behavior-focused design to deliver recommendations that actually fit your daily life.",
      "isExpanded": false,
    },
    {
      "question": "Is my health data safe with NuroVed?",
      "answer":
          "Yes. Your data is securely stored and handled with strict privacy measures. NuroVed is built with a strong focus on protecting your personal and medical information.",
      "isExpanded": false,
    },
    {
      "question":
          "Can NuroVed handle specific needs like allergies or medical conditions?",
      "answer":
          "Absolutely. NuroVed considers your allergies, dietary restrictions, and health conditions to provide safe and personalized recommendations.",
      "isExpanded": false,
    },
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {"icon": Icons.headset_mic_outlined, "title": "Customer Service"},
    {"icon": Icons.language, "title": "Website"},
    {"icon": FontAwesomeIcons.whatsapp, "title": "Whatsapp"},
    {"icon": FontAwesomeIcons.facebook, "title": "Facebook"},
    {"icon": FontAwesomeIcons.instagram, "title": "Instagram"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 25),
          _buildToggle(),
          const SizedBox(height: 25),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isContactUs ? _buildContactUsList() : _buildFAQList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFE1ECE7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF769E93),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Support",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    Text(
                      "About Us",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Color(0xFF2C4E4E)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E6E4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isContactUs = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isContactUs ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    "Contact Us",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isContactUs
                          ? const Color(0xFF2C4E4E)
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isContactUs = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isContactUs ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    "FAQ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isContactUs
                          ? const Color(0xFF2C4E4E)
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUsList() {
    final filteredOptions = contactOptions.where((option) {
      return option['title'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    return Column(
      children: filteredOptions.map((option) {
        return _buildExpandableTile(option['icon'], option['title']);
      }).toList(),
    );
  }

  Widget _buildFAQList() {
    final filteredFaqs = faqs.where((faq) {
      return faq['question'].toString().toLowerCase().contains(searchQuery) ||
          faq['answer'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    return Column(
      children: filteredFaqs.asMap().entries.map((entry) {
        final index = entry.key;
        final faq = entry.value;
        return _buildFAQTile(faq, index);
      }).toList(),
    );
  }

  Widget _buildFAQTile(Map<String, dynamic> faq, int index) {
    bool isExpanded = faq['isExpanded'];
    return GestureDetector(
      onTap: () {
        setState(() {
          faq['isExpanded'] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFFF9F9F9) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq['question'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 15),
              Text(
                faq['answer'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2C4E4E), width: 1.5),
            ),
            child: Icon(icon, color: const Color(0xFF2C4E4E), size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF2C4E4E),
            size: 30,
          ),
        ],
      ),
    );
  }
}
