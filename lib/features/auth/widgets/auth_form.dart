import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_router.dart';
import '../controllers/auth_controller.dart';
import 'custom_text_field.dart';

class AuthForm extends StatelessWidget {
  final bool isSignUp;

  const AuthForm({super.key, this.isSignUp = false});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Column(
      children: [
        // 1. Email Field
        CustomTextField(
          label: 'Email Address',
          hint: isSignUp
              ? 'Enter your email address...'
              : 'elementary221b@gmail.co',
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),

        // 2. Password Field
        CustomTextField(
          label: 'Password',
          hint: '*******************',
          prefixIcon: Icons.lock_outline,
          isPassword: !authController.isPasswordVisible,
          controller: authController.passwordController,
          onChanged: (_) => authController.validatePasswords(),
          suffixIcon: IconButton(
            icon: Icon(
              authController.isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.withOpacity(0.6),
            ),
            onPressed: authController.togglePasswordVisibility,
          ),
        ),

        // 3. Forget Password Link (Only for Login Screen)
        if (!isSignUp) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.forgotPassword),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(top: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forget password?',
                style: TextStyle(
                  color: Color(0xFFE11D48), // Precise red from your photo
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline, // Underline from photo
                ),
              ),
            ),
          ),
        ],

        // 4. Password Confirmation (Only for Sign Up Screen)
        if (isSignUp) ...[
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Password Confirmation',
            hint: '*******************',
            prefixIcon: Icons.lock_outline,
            isPassword: !authController.isPasswordVisible,
            controller: authController.confirmPasswordController,
            onChanged: (_) => authController.validatePasswords(),
            borderColor: authController.showPasswordError
                ? const Color(0xFFFDA4AF)
                : null,
            suffixIcon: Icon(
              authController.isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          if (authController.showPasswordError) ...[
            const SizedBox(height: 12),
            _buildErrorBox('ERROR: Password do not match!'),
          ],
        ],

        const SizedBox(height: 30),

        // 5. Action Button (Sign In or Continue)
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004445), // Deep teal
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            onPressed: authController.showPasswordError
                ? null
                : () {
                    if (isSignUp) {
                      authController.nextStep();
                    } else {
                      authController.signIn(context);
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSignUp ? 'Continue' : 'Sign In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
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
          Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
