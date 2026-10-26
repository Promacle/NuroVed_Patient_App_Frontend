import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';

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
              Text(
                context.l10n.profileTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              Semantics(
                button: true,
                label: context.l10n.settingsTitle,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRouter.settingsRoute),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: const Center(
                      child: Icon(Icons.settings_outlined, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            context.l10n.profileSubtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
