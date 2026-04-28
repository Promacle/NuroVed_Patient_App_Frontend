import 'package:flutter/material.dart';

import '../../../app/app_router.dart';

class AuthController extends ChangeNotifier {
  final PageController pageController = PageController();
  final PageController headerPageController = PageController();
  // Text Controllers for Fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password Visibility State
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // Password Mismatch Error State
  bool _showPasswordError = false;
  bool get showPasswordError => _showPasswordError;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    // At least 8 characters, one uppercase, one lowercase, one digit
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Handle Sign In / Continue logic
  Future<void> signIn(BuildContext context) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Validate inputs
      if (!_isValidEmail(emailController.text.trim())) {
        throw 'Invalid email format';
      }
      if (passwordController.text.length < 8) {
        throw 'Password must be at least 8 characters';
      }

      // Frontend-only demo auth: no backend required
      if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
        throw 'Invalid credentials';
      }

      navigateToHome(context);
    } catch (e) {
      _errorMessage = 'Invalid credentials. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeSignUp(BuildContext context) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Validate inputs
      if (!_isValidEmail(emailController.text.trim())) {
        throw 'Invalid email format';
      }
      if (!_isValidPassword(passwordController.text)) {
        throw 'Password must be at least 8 characters with uppercase, lowercase, and digit';
      }
      if (passwordController.text != confirmPasswordController.text) {
        throw 'Passwords do not match';
      }

      // Frontend-only demo signup: no backend required
      navigateToHome(context);
    } catch (e) {
      _errorMessage = 'Sign up failed. Please check your details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
