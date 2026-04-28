import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../app/app_router.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFE1ECE7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              // Find the Row containing "Profile" and the Icon
              // Replace the Icon with:
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.settingsRoute),
                child: const Icon(Icons.settings_outlined, size: 28),
              ),
            ],
          ),
          const Text(
            "Manage Your And Your Families Personal Information",
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
