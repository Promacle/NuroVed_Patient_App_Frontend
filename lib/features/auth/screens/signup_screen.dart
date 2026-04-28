import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
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
  String selectedGender = 'Male';
  final TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  // Logic to show Calendar
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal, // Brand color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // 1. FIXED HEADER: Background and Dog stay still, Text slides
                Stack(
                  children: [
                    AuthHeader(
                      controller: authController.headerPageController,
                      titles: const ['Sign Up For Free!', 'Create Account'],
                      subTitles: const ['', 'Complete your profile'],
                      imageAsset: AppAssets.signUpDog,
                    ),
                    // Back Button only on second page
                    _buildStepBackButton(authController),
                  ],
                ),

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
      ),
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

  // STEP 2: Profile Details (Calendar & Country Code)
  Widget _buildStepTwo(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomTextField(
            label: 'Full Name',
            hint: 'Enter your name...',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Date of Birth with Calendar Popup
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Date of Birth",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: '',
                    controller: _dobController,
                    hint: 'DD/MM/YYYY',
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            "Gender",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _genderButton('Male'),
              const SizedBox(width: 10),
              _genderButton('Female'),
              const SizedBox(width: 10),
              _genderButton('Other'),
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

          const SizedBox(height: 30),
          _buildSignUpButton(controller),
          const SizedBox(height: 20),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _genderButton(String gender) {
    bool isSelected = selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = gender),
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
            gender,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(AuthController controller) {
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
            : () async {
                await controller.completeSignUp(context);
              },
        child: controller.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_right_alt, color: Colors.white, size: 28),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          child: const Text(
            "Sign In.",
            style: TextStyle(
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
