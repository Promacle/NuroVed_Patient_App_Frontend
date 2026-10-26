import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations_extension.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  bool isContactUs = true;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedFaqs = {};

  List<Map<String, dynamic>> _getFaqs(BuildContext context) {
    final l10n = context.l10n;
    return [
      {
        "question": l10n.customerSupportFaqQ1,
        "answer": l10n.customerSupportFaqA1,
      },
      {
        "question": l10n.customerSupportFaqQ2,
        "answer": l10n.customerSupportFaqA2,
      },
      {
        "question": l10n.customerSupportFaqQ3,
        "answer": l10n.customerSupportFaqA3,
      },
      {
        "question": l10n.customerSupportFaqQ4,
        "answer": l10n.customerSupportFaqA4,
      },
    ];
  }

  List<Map<String, dynamic>> _getContactOptions(BuildContext context) {
    final l10n = context.l10n;
    return [
      {
        "key": "customer_service",
        "icon": const Icon(
          Icons.headset_mic_outlined,
          color: Color(0xFF2C4E4E),
          size: 22,
        ),
        "title": l10n.customerSupportService,
      },
      {
        "key": "website",
        "icon": const Icon(Icons.language, color: Color(0xFF2C4E4E), size: 22),
        "title": l10n.customerSupportWebsite,
      },
      {
        "key": "whatsapp",
        "icon": const FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Color(0xFF2C4E4E),
          size: 22,
        ),
        "title": l10n.customerSupportWhatsapp,
      },
      {
        "key": "facebook",
        "icon": const FaIcon(
          FontAwesomeIcons.facebook,
          color: Color(0xFF2C4E4E),
          size: 22,
        ),
        "title": l10n.customerSupportFacebook,
      },
      {
        "key": "instagram",
        "icon": const FaIcon(
          FontAwesomeIcons.instagram,
          color: Color(0xFF2C4E4E),
          size: 22,
        ),
        "title": l10n.customerSupportInstagram,
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.kMainBg,
        body: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 25),
            _buildToggle(context),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    isContactUs ? _buildContactUsList() : _buildFAQList(),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              Semantics(
                button: true,
                label: context.l10n.commonBack,
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF769E93),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.customerSupportTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    Text(
                      context.l10n.customerSupportAboutUs,
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
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
              decoration: InputDecoration(
                hintText: context.l10n.customerSupportSearchHint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2C4E4E)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
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
                    context.l10n.customerSupportContactUs,
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
                    context.l10n.customerSupportFaq,
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
    final filteredOptions = _getContactOptions(context).where((option) {
      return option['title'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    if (filteredOptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          context.l10n.customerSupportNoContactMatch,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      );
    }

    return Column(
      children: filteredOptions.map((option) {
        return _buildExpandableTile(option['icon'], option['title'], option['key'] as String);
      }).toList(),
    );
  }

  Widget _buildFAQList() {
    final faqs = _getFaqs(context);
    final filteredFaqs = faqs.asMap().entries.where((entry) {
      final faq = entry.value;
      return faq['question'].toString().toLowerCase().contains(searchQuery) ||
          faq['answer'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    if (filteredFaqs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          context.l10n.customerSupportNoFaqMatch,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      );
    }

    return Column(
      children: filteredFaqs.map((entry) {
        final index = entry.key;
        final faq = entry.value;
        return _buildFAQTile(faq, index);
      }).toList(),
    );
  }

  Widget _buildFAQTile(Map<String, dynamic> faq, int index) {
    bool isExpanded = _expandedFaqs.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedFaqs.remove(index);
          } else {
            _expandedFaqs.add(index);
          }
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
              color: Colors.black.withValues(alpha: 0.12),
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

  Widget _buildExpandableTile(dynamic icon, String title, String key) {
    Widget iconWidget;
    if (icon is Widget) {
      iconWidget = icon;
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: const Color(0xFF2C4E4E), size: 22);
    } else {
      iconWidget = const Icon(
        Icons.help_outline,
        color: Color(0xFF2C4E4E),
        size: 22,
      );
    }

    return GestureDetector(
      onTap: () => _handleContactAction(context, key, title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2C4E4E), width: 1.5),
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF2C4E4E),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContactAction(BuildContext context, String key, String title) async {
    final l10n = context.l10n;
    switch (key) {
      case "customer_service":
        _showChannelDialog(
          context,
          title,
          l10n.customerSupportPhoneNotConfigured,
        );
        break;
      case "website":
        final uri = Uri.parse("https://nuroved.com");
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else if (context.mounted) {
            _showChannelDialog(
              context,
              title,
              l10n.customerSupportWebsiteDialog,
            );
          }
        } catch (_) {
          if (context.mounted) {
            _showChannelDialog(
              context,
              title,
              l10n.customerSupportWebsiteDialog,
            );
          }
        }
        break;
      case "whatsapp":
        _showChannelDialog(
          context,
          title,
          l10n.customerSupportWhatsappNotConfigured,
        );
        break;
      default:
        _showChannelDialog(
          context,
          title,
          l10n.customerSupportChannelNotActive(title),
        );
        break;
    }
  }

  void _showChannelDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonOk),
          ),
        ],
      ),
    );
  }
}
