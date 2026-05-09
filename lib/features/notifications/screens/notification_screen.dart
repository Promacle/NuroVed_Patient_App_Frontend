import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Logic to track read state locally for this demo
  bool _allRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildAppBar(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildSectionHeader("Today"),
                    NotificationTile(
                      title: "Time For Mom's Medicine",
                      subtitle: "It's time to take Mom's BP medicine....",
                      time: "Just now",
                      iconPath: AppAssets.medicineIcon,
                      isUnread: !_allRead,
                    ),
                    NotificationTile(
                      title: "Blood test Reminder",
                      subtitle: "Remember your upcoming blood test tomorrow...",
                      time: "1 hr ago",
                      iconPath: AppAssets.bloodTestIcon,
                      isUnread: !_allRead,
                    ),
                    NotificationTile(
                      title: "5-day Streak! Great Job!",
                      subtitle:
                          "You have logged in for 5 days consecutively...",
                      time: "2 hr ago",
                      iconPath: AppAssets.streakIcon,
                      isUnread: false,
                    ),
                    const SizedBox(height: 25),
                    _buildSectionHeader("This week"),
                    const NotificationTile(
                      title: "Your Data is Encrypted",
                      subtitle:
                          "Your health records are securely encrypted & protected",
                      time: "Tuesday",
                      iconPath: AppAssets.encryptedIcon,
                    ),
                    const NotificationTile(
                      title: "First record has been added",
                      subtitle:
                          "Your first health records has been added successfully.....",
                      time: "Monday",
                      iconPath: AppAssets.docIcon,
                    ),
                    const NotificationTile(
                      title: "Thank you for joining us",
                      subtitle:
                          "Welcome to new revolutionary step towards your health....",
                      time: "2 hr ago",
                      iconPath: AppAssets.heartIcon,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_circle_left_rounded,
                size: 45,
                color: AppColors.kPrimary,
              ),
            ),
            const Text(
              "Notification",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.kDarkText,
              ),
            ),
            const SizedBox(width: 45), // Equalize spacing
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _allRead = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All notifications marked as read"),
                ),
              );
            },
            child: Text(
              "Mark all as read",
              style: TextStyle(
                color: _allRead ? Colors.grey : AppColors.kPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.kDarkText,
        ),
      ),
    );
  }
}
