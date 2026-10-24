import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/widgets/section_header.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: "Preferences",
                    subtitle: "Customize your tracking experience",
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildSettingCard(
                    title: "App Settings",
                    subtitle: "Units, time format, and clinical display",
                    icon: Icons.tune_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.appSettings),
                  ),
                  _buildSettingCard(
                    title: "Data & Privacy",
                    subtitle: "Row Level Security, permissions & account data",
                    icon: Icons.shield_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.dataPrivacy),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: "Support & Feedback",
                    subtitle: "Assistance from care coordinators",
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildSettingCard(
                    title: "Customer Support",
                    subtitle: "Direct care coordination and helpdesk",
                    icon: Icons.support_agent_rounded,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.customerSupport),
                  ),
                  _buildSettingCard(
                    title: "Report a Problem",
                    subtitle: "Report bugs or sync anomalies",
                    icon: Icons.bug_report_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.reportProblem),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(
                    title: "Legal & Compliance",
                    subtitle: "Clinical boundaries and privacy safeguards",
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildSettingCard(
                    title: "Privacy Policy",
                    subtitle: "Zero third-party monetization & RLS sovereignty",
                    icon: Icons.policy_outlined,
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildSettingCard(
                    title: "Terms of Service",
                    subtitle:
                        "Continuity of care guidelines and emergency terms",
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
            label: "Back",
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Manage Your App Settings & Preferences",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
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

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terms of Service'),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
