import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = context.l10n;
    final passwordController = TextEditingController();
    bool isDeleting = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.dataPrivacyDeleteTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE11D48),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dataPrivacyDeleteMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.dataPrivacyConfirmPassword,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.dataPrivacyEnterPassword,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    dialogError!,
                    style: const TextStyle(
                      color: Color(0xFFE11D48),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(dialogCtx),
                child: Text(
                  l10n.commonCancel,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isDeleting
                    ? null
                    : () async {
                        final pwd = passwordController.text;
                        if (pwd.isEmpty) {
                          setDialogState(() {
                            dialogError = l10n.dataPrivacyPasswordRequired;
                          });
                          return;
                        }

                        setDialogState(() {
                          isDeleting = true;
                          dialogError = null;
                        });

                        final authController = dialogCtx.read<AuthController>();
                        final result = await authController.deleteAccount(
                          passwordConfirm: pwd,
                          context: dialogCtx,
                        );

                        if (result.isFailure) {
                          setDialogState(() {
                            isDeleting = false;
                            dialogError =
                                result.failureOrNull?.message ??
                                l10n.dataPrivacyDeleteFailed;
                          });
                        } else {
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                        }
                      },
                child: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        l10n.dataPrivacyPermanentlyDelete,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _triggerResetPassword(BuildContext context) async {
    final l10n = context.l10n;
    final authController = context.read<AuthController>();
    final email = authController.currentUser?.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dataPrivacyNoActiveEmail),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dataPrivacySendingReset)),
    );

    final result = await authController.sendPasswordReset(email);

    if (context.mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.dataPrivacyResetSent(email)),
              backgroundColor: AppColors.primaryTeal,
            ),
          );
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: const Color(0xFFE11D48),
            ),
          );
        },
      );
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.dataPrivacyPolicyDialogTitle),
        content: const SingleChildScrollView(
          child: Text(
            'NuroVed places patient privacy and health data sovereignty at its core.\n\n'
            '1. Patient Data Ownership: You own your health records, blood sugar logs, and clinical timelines.\n'
            '2. Transit & Storage Protection: Data in transit is protected via HTTPS/TLS 1.3, and database access is governed by authenticated Row Level Security policies.\n'
            '3. Zero Credential Leakage: Authentication is verified directly with security-hardened tokens.\n'
            '4. Permanent Account Deletion: You have the right to permanently erase your account and all associated health records at any time.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE1ECE7,
                            ).withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Image.asset(AppAssets.encryptedIcon, height: 80),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildOptionCard(
                    title: context.l10n.dataPrivacyChangeEmail,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.changeEmail),
                  ),
                  _buildOptionCard(
                    title: context.l10n.dataPrivacyChangePassword,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.changePassword),
                  ),
                  _buildOptionCard(
                    title: context.l10n.dataPrivacyResetPassword,
                    onTap: () => _triggerResetPassword(context),
                  ),
                  _buildOptionCard(
                    title: context.l10n.dataPrivacyPolicy,
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  const SizedBox(height: 60),
                  _buildDeleteAccountButton(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFE1ECE7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: context.l10n.commonBack,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF769E93),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.dataPrivacyTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  context.l10n.dataPrivacySubtitle,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF2C4E4E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Center(
          child: Text(
            context.l10n.dataPrivacyDeleteMyAccount,
            style: const TextStyle(
              color: Color(0xFFE11D48),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
