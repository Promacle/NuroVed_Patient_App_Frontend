import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0 for Monthly, 1 for Yearly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildUpgradeCard(),
                  const SizedBox(height: 25),
                  _buildSectionDivider("Everything is Free, plus"),
                  const SizedBox(height: 15),
                  _buildFeatureCard(
                    icon: Icons.ios_share_outlined,
                    title: "Share with Doctors",
                    subtitle:
                        "Share your complete health profile with doctors in one tap.",
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.brain,
                    title: "AI Health Insights",
                    subtitle:
                        "Get intelligent insights and risk alerts from your health data.",
                  ),
                  _buildFeatureCard(
                    icon: Icons.trending_up_rounded,
                    title: "Advanced Timeline",
                    subtitle:
                        "Track trends and patterns with advanced health timeline.",
                  ),
                  _buildFeatureCard(
                    icon: Icons.groups_outlined,
                    title: "Family Profiles",
                    subtitle:
                        "Add and manage your family's health in one secure place.",
                  ),
                  _buildFeatureCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: "Unlimited Scanner",
                    subtitle:
                        "Scan and store unlimited reports with smart auto-tagging.",
                  ),
                  _buildFeatureCard(
                    icon: Icons.restaurant_menu_outlined,
                    title: "Context Aware Diet Plans",
                    subtitle:
                        "Personalized diet recommendations based on your goals.",
                  ),
                  const SizedBox(height: 20),
                  _buildSectionDivider("Limited Time Offer"),
                  const SizedBox(height: 15),
                  _buildOfferBanner(),
                  const SizedBox(height: 20),
                  _buildSectionDivider("Select your plan"),
                  const SizedBox(height: 15),
                  _buildPlanCard(
                    index: 0,
                    title: "Monthly Premium",
                    price: "₹89",
                    period: "/Month",
                    subtitle: "65% Off Offer",
                  ),
                  const SizedBox(height: 15),
                  _buildPlanCard(
                    index: 1,
                    title: "Yearly Premium",
                    price: "₹67",
                    period: "/Month",
                    subtitle: "₹804/Year",
                    isMostPopular: true,
                  ),
                  const SizedBox(height: 30),
                  _buildContinueButton(),
                  const SizedBox(height: 40),
                ],
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
        color: AppColors.kTopBg,
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
                  "Explore Premium",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  "Unlock The Full Potential Of Your Health",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EE),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upgrade to premium",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Unlock the full power of NuroVed and take control of your health.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shield,
                size: 80,
                color: const Color(0xFF7CB9A8).withValues(alpha: 0.6),
              ),
              const Icon(FontAwesomeIcons.crown, size: 30, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EEEA), // Updated to requested color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF397D71), size: 24),
          ),
          const SizedBox(width: 15),
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
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EE),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Limited Time Offer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              Text(
                "70% OFF On Yearly Plan",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              Text(
                "Take control of your health today",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black26),
              ),
              child: const Text(
                "Save ₹2100",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required String subtitle,
    bool isMostPopular = false,
  }) {
    bool isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD1EBE2)
                  : const Color(0xFFD1EBE2).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2C4E4E)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C4E4E),
                            ),
                          ),
                          Text(
                            period,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C4E4E),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2C4E4E)),
                    color: isSelected
                        ? const Color(0xFF2C4E4E)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
          if (isMostPopular)
            Positioned(
              top: -12,
              right: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Most Popular",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C4E4E).withValues(alpha: 0.35),
            blurRadius: 10, // Refined spread
            offset: const Offset(0, 8), // Refined depth
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          String planName = _selectedPlan == 1
              ? "Yearly Premium"
              : "Monthly Premium";
          String price = _selectedPlan == 1 ? "₹67" : "₹89";
          String period = "/Month";

          Navigator.pushNamed(
            context,
            AppRouter.purchase,
            arguments: {'planName': planName, 'price': price, 'period': period},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C4E4E),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Continue to Premium",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
