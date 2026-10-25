import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isCurrentPassVisible = false;
  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _errorMessage = null;
    });

    final currentPass = _currentPassController.text;
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (currentPass.isEmpty) {
      setState(() {
        _errorMessage = 'Current password is required.';
      });
      return;
    }

    if (newPass.length < 8) {
      setState(() {
        _errorMessage = 'New password must be at least 8 characters.';
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = 'New passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authController = context.read<AuthController>();
    final result = await authController.changePassword(
      currentPassword: currentPass,
      newPassword: newPass,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully.'),
            backgroundColor: AppColors.primaryTeal,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      },
      failure: (failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
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
                  const SizedBox(height: 30),
                  _buildInputField(
                    controller: _currentPassController,
                    hintText: "Enter current password",
                    isVisible: _isCurrentPassVisible,
                    onToggle: () => setState(
                      () => _isCurrentPassVisible = !_isCurrentPassVisible,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _newPassController,
                    hintText: "Enter new password (min. 8 characters)",
                    isVisible: _isNewPassVisible,
                    onToggle: () =>
                        setState(() => _isNewPassVisible = !_isNewPassVisible),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _confirmPassController,
                    hintText: "Re-enter new password",
                    isVisible: _isConfirmPassVisible,
                    onToggle: () => setState(
                      () => _isConfirmPassVisible = !_isConfirmPassVisible,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Color(0xFFE11D48),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 60),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF769E93),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  "Re-authenticate and set your new password",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C4E4E),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF769E93),
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black38,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChangePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                "Save New Password",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}
