import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.appSettings),
                    child: _buildSettingCard(
                      "App Settings",
                      "Personalize Your Health Management",
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.dataPrivacy),
                    child: _buildSettingCard(
                      "Data & Privacy",
                      "Set Permission For Your Important Analysis",
                    ),
                  ),

                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.customerSupport),
                    child: _buildSettingCard(
                      "Customer Support",
                      "How Can We Help You ?",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: _buildSettingCard(
                      "Privacy Policy",
                      "Must check our Privacy policy.",
                    ),
                  ),

                  GestureDetector(
                    onTap: () {},
                    child: _buildSettingCard(
                      "Terms of Service",
                      "Must check our terms of service.",
                    ),
                  ),

                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.reportProblem),
                    child: _buildSettingCard(
                      "Report a problem",
                      "How Can We Help You ?",
                    ),
                  ),
                ],
              ),
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
        color: Color(0xFFF3F3F3), // Updated color
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF769E93),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Setting",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  "Manage Your App Setting",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // lib/features/settings/screens/settings_screen.dart

  // ... update the _buildSettingCard method:
  Widget _buildSettingCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3), // Tile color
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12), // Deeper shadow
            blurRadius: 12,
            offset: const Offset(0, 10), // More depth
            spreadRadius: -5, // Less spread
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xFF2C4E4E),
            size: 18,
          ),
        ],
      ),
    );
  }
}
