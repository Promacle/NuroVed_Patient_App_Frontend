import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/backend_status_banner.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_form.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Future<void> _selectDate(
    BuildContext context,
    AuthController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // 1. FIXED HEADER
              Stack(
                children: [
                  AuthHeader(
                    controller: authController.headerPageController,
                    titles: [
                      context.l10n.signupSubtitle,
                      context.l10n.signupTitle,
                    ],
                    subTitles: const ['', 'Complete your profile'],
                    imageAsset: AppAssets.signUpDog,
                  ),
                  _buildStepBackButton(authController),
                ],
              ),
              const BackendStatusBanner(),

              // 2. SLIDING BODY
              Expanded(
                child: PageView(
                  controller: authController.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStepOne(context),
                    _buildStepTwo(context, authController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepBackButton(AuthController controller) {
    return ListenableBuilder(
      listenable: controller.pageController,
      builder: (context, child) {
        double page = controller.pageController.hasClients
            ? controller.pageController.page ?? 0
            : 0;
        if (page < 0.5) return const SizedBox.shrink();

        return Positioned(
          top: 50,
          left: 15,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF334155),
            ),
            onPressed: () => controller.previousStep(),
          ),
        );
      },
    );
  }

  // STEP 1: Email & Password
  Widget _buildStepOne(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const AuthForm(isSignUp: true),
          const SizedBox(height: 20),
          _buildFooter(context),
        ],
      ),
    );
  }

  // STEP 2: Profile Details
  Widget _buildStepTwo(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: context.l10n.signupFullNameLabel,
            hint: context.l10n.signupFullNameHint,
            prefixIcon: Icons.person_outline,
            controller: controller.nameController,
          ),
          const SizedBox(height: 20),

          // Date of Birth with Calendar Popup
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.familyFieldDob,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context, controller),
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: '',
                    controller: controller.dobController,
                    hint: 'DD/MM/YYYY',
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            context.l10n.familyFieldGender,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _genderButton('Male', controller),
              const SizedBox(width: 10),
              _genderButton('Female', controller),
              const SizedBox(width: 10),
              _genderButton('Other', controller),
            ],
          ),
          const SizedBox(height: 20),

          // Contact Number with Country Code
          const Text(
            "Contact Number",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          IntlPhoneField(
            initialCountryCode: 'IN',
            dropdownIconPosition: IconPosition.trailing,
            controller: controller.phoneController,
            decoration: InputDecoration(
              hintText: 'Enter your number...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.primaryTeal,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Terms and Conditions Acknowledgement Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: controller.acknowledgedTerms,
                  activeColor: AppColors.primaryTeal,
                  onChanged: (val) =>
                      controller.setAcknowledgedTerms(val ?? false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: context.l10n.signupTermsAgreement,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(
                        text: context.l10n.signupTermsLink,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: context.l10n.signupAndWord),
                      TextSpan(
                        text: context.l10n.signupPrivacyLink,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Color(0xFFE11D48), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.errorMessage!,
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

          const SizedBox(height: 30),
          _buildSignUpButton(context, controller),
          const SizedBox(height: 20),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _genderButton(String gender, AuthController controller) {
    bool isSelected = controller.selectedGender == gender;
    final displayLabel = gender == 'Male'
        ? context.l10n.dietFieldGenderMale
        : (gender == 'Female'
              ? context.l10n.dietFieldGenderFemale
              : context.l10n.dietFieldGenderOther);

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSelectedGender(gender),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF004445)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            displayLabel,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, AuthController controller) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004445),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: controller.isLoading
            ? null
            : () => controller.completeSignUp(context),
        child: controller.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.signupButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_right_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${context.l10n.signupAlreadyHaveAccount} ",
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          child: Text(
            "${context.l10n.signupSignInLink}.",
            style: const TextStyle(
              color: Color(0xFFE11D48),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
