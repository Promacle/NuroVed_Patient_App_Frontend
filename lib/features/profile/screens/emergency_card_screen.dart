import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

class EmergencyCardView extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmergencyCardView({super.key, required this.data});

  final String? familyImage = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEmergencyRedCard(),
        const SizedBox(height: 25),
        _buildFamilyProfilesSection(context),
      ],
    );
  }

  Widget _buildEmergencyRedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE57373), // Emergency Red
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8), // Deep 3D Shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Emergency Card",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoTile("Blood Group", data['blood'] ?? "B+"),
          _buildInfoTile(
            "Allergies",
            (data['allergies'] as List? ?? ["None"]).join(", "),
          ),
          _buildInfoTile(
            "Chronic Conditions",
            (data['chronicConditions'] as List? ?? ["None"]).join(", "),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        // Frosted Glass Effect: White with low opacity
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyProfilesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kMainBg, // Consistent with theme
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Family Profiles",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const SizedBox(height: 20),
          _buildFamilyMemberRow(),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen, // Using Common Colors
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/family-profiles');
              },
              child: const Text(
                "View all family profiles",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberRow() {
    return Row(
      children: [
        Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            color: Colors.white, // Background for the icon
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: familyImage != null
                ? Image.network(familyImage!, fit: BoxFit.cover)
                : Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.grey.shade400,
                  ), // Default Person Icon
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Umar chk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
            Text(
              "Friend",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E4D4D), // Dark Teal Button
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}
