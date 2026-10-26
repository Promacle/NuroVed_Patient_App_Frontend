import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
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
    final l10n = context.l10n;
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
                    _buildSectionHeader(l10n.notificationsSectionToday),
                    NotificationTile(
                      title: l10n.notificationsSampleMedicineTitle,
                      subtitle: l10n.notificationsSampleMedicineSub,
                      time: l10n.notificationsTimeJustNow,
                      iconPath: AppAssets.medicineIcon,
                      isUnread: !_allRead,
                    ),
                    NotificationTile(
                      title: l10n.notificationsSampleBloodTestTitle,
                      subtitle: l10n.notificationsSampleBloodTestSub,
                      time: l10n.notificationsTimeOneHourAgo,
                      iconPath: AppAssets.bloodTestIcon,
                      isUnread: !_allRead,
                    ),
                    NotificationTile(
                      title: l10n.notificationsSampleStreakTitle,
                      subtitle: l10n.notificationsSampleStreakSub,
                      time: l10n.notificationsTimeTwoHoursAgo,
                      iconPath: AppAssets.streakIcon,
                      isUnread: false,
                    ),
                    const SizedBox(height: 25),
                    _buildSectionHeader(l10n.notificationsSectionThisWeek),
                    NotificationTile(
                      title: l10n.notificationsSampleEncryptedTitle,
                      subtitle: l10n.notificationsSampleEncryptedSub,
                      time: l10n.notificationsTimeTuesday,
                      iconPath: AppAssets.encryptedIcon,
                    ),
                    NotificationTile(
                      title: l10n.notificationsSampleRecordTitle,
                      subtitle: l10n.notificationsSampleRecordSub,
                      time: l10n.notificationsTimeMonday,
                      iconPath: AppAssets.docIcon,
                    ),
                    NotificationTile(
                      title: l10n.notificationsSampleWelcomeTitle,
                      subtitle: l10n.notificationsSampleWelcomeSub,
                      time: l10n.notificationsTimeTwoHoursAgo,
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
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: l10n.commonBack,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_circle_left_rounded,
                size: 45,
                color: AppColors.kPrimary,
              ),
            ),
            Text(
              l10n.notificationsTitle,
              style: const TextStyle(
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
                SnackBar(
                  content: Text(l10n.notificationsAllMarkedRead),
                ),
              );
            },
            child: Text(
              l10n.notificationsMarkAllRead,
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
