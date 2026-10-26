import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/widgets/section_header.dart';

import '../../../app/app_router.dart';
import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/localization/locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeController = LocaleController.instance;

    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l10n.settingsSectionPreferences,
                    subtitle: l10n.settingsSubtitle,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsLanguageCard,
                    subtitle: localeController.currentLanguageNativeName,
                    icon: Icons.language_rounded,
                    onTap: () => _showLanguageSelection(context),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsAppSettingsCard,
                    subtitle: l10n.settingsAppSettingsSubtitle,
                    icon: Icons.tune_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.appSettings),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsDataPrivacyCard,
                    subtitle: l10n.settingsDataPrivacySubtitle,
                    icon: Icons.shield_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.dataPrivacy),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: l10n.settingsSectionSupport,
                    subtitle: l10n.settingsCustomerSupportSubtitle,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsCustomerSupportCard,
                    subtitle: l10n.settingsCustomerSupportSubtitle,
                    icon: Icons.support_agent_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.customerSupport),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsReportProblemCard,
                    subtitle: l10n.settingsReportProblemSubtitle,
                    icon: Icons.bug_report_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.reportProblem),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: l10n.settingsSectionLegal,
                    subtitle: l10n.settingsTermsSubtitle,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsPrivacyPolicyCard,
                    subtitle: l10n.settingsPrivacyPolicySubtitle,
                    icon: Icons.policy_outlined,
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildSettingCard(
                    title: l10n.settingsTermsCard,
                    subtitle: l10n.settingsTermsSubtitle,
                    icon: Icons.gavel_outlined,
                    onTap: () => _showTermsOfService(context),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            button: true,
            label: l10n.semanticsBack,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primaryTeal,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.settingsTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.settingsSubtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryTeal, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    final l10n = context.l10n;
    final controller = LocaleController.instance;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.settingsLanguageSelectTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ...LocaleController.supportedLocales.map((loc) {
                final code = loc.languageCode;
                final isSelected = controller.currentLanguageCode == code;
                final nativeName = LocaleController.getNativeName(code);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryTeal
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Material(
                    color: isSelected
                        ? AppColors.surfaceMint
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        nativeName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryTeal
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryTeal,
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await controller.setLocale(loc);
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.privacyPolicyTitle),
        content: const SingleChildScrollView(
          child: Text(
            'NuroVed Privacy & Data Protection\n\n'
            '1. Patient Data Sovereignty: You own and control your health records, glucose logs, and medical history.\n\n'
            '2. Access Control: Patient data is protected by Row Level Security (RLS) policies. Only you and explicitly authorized caregivers can view or edit your records.\n\n'
            '3. Medical Records Security: Uploaded clinical documents are stored in private cloud storage and accessed solely through short-lived signed URLs.\n\n'
            '4. No Data Monetization: NuroVed does not sell, rent, or share personal health information with third parties or advertisers.\n\n'
            '5. Account Erasure: You may delete your account and all associated health data at any time from App Settings.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.termsOfServiceTitle),
        content: const SingleChildScrollView(
          child: Text(
            'NuroVed Terms of Service\n\n'
            '1. Continuity of Care Companion: NuroVed is designed as a patient tracking and continuity-of-care tool. It does not replace professional medical advice, diagnosis, or clinical judgment.\n\n'
            '2. Medication & Routine Tracking: Medicine reminders and schedule entries are patient-entered tools. Always follow your prescribing clinician\'s instructions and verified prescription labels.\n\n'
            '3. Emergency Situations: If you experience a medical emergency, acute hypoglycaemia, or any severe symptoms, contact emergency medical services or visit the nearest emergency facility immediately.\n\n'
            '4. Caregiver Authorization: Delegated access grants permit appointed caregivers to view or manage records on your behalf. You retain full authority to revoke delegated access at any time.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }
}
