import 'package:flutter/material.dart';

import '../../../app/app_router.dart';

class AuthController extends ChangeNotifier {
  final PageController pageController = PageController();
  final PageController headerPageController = PageController();
  // Text Controllers for Fields
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password Visibility State
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // Password Mismatch Error State
  bool _showPasswordError = false;
  bool get showPasswordError => _showPasswordError;

  void navigateToHome(BuildContext context) {
    // pushNamedAndRemoveUntil ensures the user can't go back to Login/Signup
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.home,
      (route) => false,
    );
  }

  void nextStep() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    headerPageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  /// Toggles the eye icon for showing/hiding password text
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Compares password and confirm password fields
  void validatePasswords() {
    if (passwordController.text != confirmPasswordController.text &&
        confirmPasswordController.text.isNotEmpty) {
      _showPasswordError = true;
    } else {
      _showPasswordError = false;
    }
    notifyListeners();
  }

  /// Handle Sign In / Continue logic
  void signIn(BuildContext context) {
    // Add your validation logic here
    debugPrint("Signing In...");
    navigateToHome(context);
  }

  void completeSignUp(BuildContext context) {
    debugPrint("Completing Sign Up...");
    navigateToHome(context);
  }

  void previousStep() {
    const duration = Duration(milliseconds: 500);
    const curve = Curves.easeInOut;
    pageController.previousPage(duration: duration, curve: curve);
    headerPageController.previousPage(duration: duration, curve: curve);
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
