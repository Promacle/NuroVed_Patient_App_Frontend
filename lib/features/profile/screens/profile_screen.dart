import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../settings/controllers/app_settings_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/allergy_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_widgets.dart'; // Import the new widgets
import 'emergency_card_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();
  final AppSettingsController _settingsController = AppSettingsController();
  bool isProfileSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            // FIXED: Using the new Toggle Widget
            ProfileToggle(
              isProfileSelected: isProfileSelected,
              onToggle: (val) => setState(() => isProfileSelected = val),
            ),
            const SizedBox(height: 25),
            _buildAnimatedContent(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: isProfileSelected
          ? _buildMainProfileCard()
          : EmergencyCardView(
              key: const ValueKey('emergency'),
              data: _controller.userData,
            ),
    );
  }

  // lib/features/profile/screens/profile_screen.dart

  Widget _buildMainProfileCard() {
    final data = _controller.userData;
    return Container(
      key: const ValueKey('profile'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1ED),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(
            imageFile: data['imageFile'],
            onEdit: () => _controller.navigateToEdit(context, () {
              if (mounted) setState(() {});
            }),
          ),
          const SizedBox(height: 15),
          Text(
            data['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          Text(
            "${_controller.calculateAge()} old",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            "User id: 23802839490",
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 15),
          // Email in white container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                data['email'],
                style: const TextStyle(
                  color: Color(0xFF2C4E4E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          _buildMetricsRow(data),
          const SizedBox(height: 25),
          AllergyCard(allergies: List<String>.from(data['allergies'])),
          const SizedBox(height: 25),
          LogoutButton(onLogout: () => _controller.logout()),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(Map<String, dynamic> data) {
    return ListenableBuilder(
      listenable: _settingsController,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.water_drop_outlined,
                value: data['blood'],
                label: "Blood",
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.straighten_rounded,
                // USES formatHeight
                value:
                    "${_settingsController.formatHeight(data['height'])} ${_settingsController.heightUnit}",
                label: "Height",
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.scale_outlined,
                // USES formatWeight
                value:
                    "${_settingsController.formatWeight(data['weight'])} ${_settingsController.weightUnit}",
                label: "Weight",
                color: AppColors.primaryTeal,
              ),
            ),
          ],
        );
      },
    );
  }
}
