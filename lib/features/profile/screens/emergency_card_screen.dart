import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';

class EmergencyCardView extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmergencyCardView({super.key, required this.data});

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
    final blood = data['blood']?.toString();
    final displayBlood =
        (blood != null && blood.isNotEmpty && blood != 'Not provided')
        ? blood
        : 'Not provided';

    final allergies = data['allergies'] is List
        ? (data['allergies'] as List)
        : [];
    final displayAllergies = allergies
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty && e != 'None' && e != 'Not provided')
        .join(', ');
    final finalAllergies = displayAllergies.isEmpty
        ? 'Not provided'
        : displayAllergies;

    final conditions = data['chronicConditions'] is List
        ? (data['chronicConditions'] as List)
        : [];
    final displayConditions = conditions
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty && e != 'None' && e != 'Not provided')
        .join(', ');
    final finalConditions = displayConditions.isEmpty
        ? 'Not provided'
        : displayConditions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE57373), // Emergency Red
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 10),
          // Patient-entered, unverified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  "PATIENT-ENTERED, UNVERIFIED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoTile("Blood Group", displayBlood),
          _buildInfoTile("Allergies", finalAllergies),
          _buildInfoTile("Chronic Conditions", finalConditions),
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
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
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
        color: AppColors.kMainBg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
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
          _buildFamilyMemberRow(context),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.familyProfiles);
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

  Widget _buildFamilyMemberRow(BuildContext context) {
    final controller = ProfileController.instance;
    // Check for an explicit designated emergency contact
    final members = controller.familyMembersList;
    final emergencyMember = members
        .where((m) => m.isEmergencyContact)
        .firstOrNull;

    final contactName = emergencyMember?.name ?? "Not assigned";
    final contactRelation = emergencyMember != null
        ? "${emergencyMember.relation} (Emergency Contact)"
        : "Emergency Contact";
    final contactPhone =
        emergencyMember?.phone != null && emergencyMember!.phone!.isNotEmpty
        ? emergencyMember.phone!
        : "Phone not provided";

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.familyProfiles);
      },
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Icon(Icons.person, size: 35, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  contactRelation,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (emergencyMember != null)
                  Text(
                    contactPhone,
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D4D),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
