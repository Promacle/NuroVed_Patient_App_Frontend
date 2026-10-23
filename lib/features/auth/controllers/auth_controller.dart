import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/failures.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';

/// Controller managing authentication state, input validation, and user session lifecycle.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  StreamSubscription<UserProfile?>? _authSubscription;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _acknowledgedTerms = false;
  int _signupStep = 0;

  // Text Controllers for Authentication Fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String selectedGender = 'Male';

  // Navigation PageControllers
  final PageController pageController = PageController();
  final PageController headerPageController = PageController();

  // Visibility States
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showPasswordError = false;

  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _currentUser = _authRepository.currentUser;
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get acknowledgedTerms => _acknowledgedTerms;
  int get signupStep => _signupStep;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get showPasswordError => _showPasswordError;

  void setAcknowledgedTerms(bool value) {
    _acknowledgedTerms = value;
    if (_errorMessage != null &&
        _errorMessage!.contains('terms and conditions')) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void setSelectedGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();
    dobController.clear();
    _acknowledgedTerms = false;
    _errorMessage = null;
    _showPasswordError = false;
    _signupStep = 0;
    notifyListeners();
  }

  void validatePasswords() {
    if (confirmPasswordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      _showPasswordError = true;
    } else {
      _showPasswordError = false;
    }
    notifyListeners();
  }

  /// Validates Step 1 of Sign Up (Email, Password, Confirm Password).
  bool validateStepOne() {
    _errorMessage = null;

    final emailError = AppValidators.email(emailController.text);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    if (passwordController.text.isEmpty) {
      _errorMessage = 'Password is required.';
      notifyListeners();
      return false;
    }

    if (passwordController.text.length < 8) {
      _errorMessage = 'Password must be at least 8 characters.';
      notifyListeners();
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showPasswordError = true;
      _errorMessage = 'Passwords do not match.';
      notifyListeners();
      return false;
    }

    _showPasswordError = false;
    notifyListeners();
    return true;
  }

  void nextStep() {
    if (!validateStepOne()) {
      return;
    }

    _signupStep = 1;
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    headerPageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void previousStep() {
    _signupStep = 0;
    const duration = Duration(milliseconds: 500);
    const curve = Curves.easeInOut;
    pageController.previousPage(duration: duration, curve: curve);
    headerPageController.previousPage(duration: duration, curve: curve);
    notifyListeners();
  }

  /// Genuine sign in with email and password.
  Future<bool> signIn([BuildContext? context]) async {
    _errorMessage = null;

    final emailError = AppValidators.email(emailController.text);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    if (passwordController.text.isEmpty) {
      _errorMessage = 'Password is required.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    AppLogger.info(
      'Attempting genuine sign in for email: ${emailController.text.trim()}',
    );

    final result = await _authRepository.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    _isLoading = false;

    return result.when(
      success: (user) {
        _currentUser = user;
        clearForm();
        if (context != null && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.home,
            (route) => false,
          );
        }
        return true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Genuine account registration with terms acknowledgement and validation.
  Future<bool> completeSignUp([BuildContext? context]) async {
    _errorMessage = null;

    // Validate step 1 again
    if (!validateStepOne()) {
      return false;
    }

    // Validate step 2 fields
    final nameError = AppValidators.requiredField(
      nameController.text,
      'Full name',
    );
    if (nameError != null) {
      _errorMessage = nameError;
      notifyListeners();
      return false;
    }

    if (dobController.text.trim().isNotEmpty) {
      final dobError = AppValidators.dateOfBirth(dobController.text.trim());
      if (dobError != null) {
        _errorMessage = dobError;
        notifyListeners();
        return false;
      }
    }

    if (phoneController.text.trim().isNotEmpty) {
      final phoneError = AppValidators.phone(phoneController.text.trim());
      if (phoneError != null) {
        _errorMessage = phoneError;
        notifyListeners();
        return false;
      }
    }

    if (!_acknowledgedTerms) {
      _errorMessage = 'Please read and acknowledge the terms and conditions.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    AppLogger.info(
      'Attempting genuine sign up for email: ${emailController.text.trim()}',
    );

    final result = await _authRepository.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      name: nameController.text.trim(),
      acknowledgedTerms: _acknowledgedTerms,
      phone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      dateOfBirth: dobController.text.trim().isEmpty
          ? null
          : dobController.text.trim(),
      gender: selectedGender,
    );

    _isLoading = false;

    return result.when(
      success: (user) {
        _currentUser = user;
        clearForm();
        if (context != null && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.home,
            (route) => false,
          );
        }
        return true;
      },
      failure: (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Restores active session on app startup.
  Future<bool> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.restoreSession();

    _isLoading = false;

    return result.when(
      success: (user) {
        _currentUser = user;
        notifyListeners();
        return user != null;
      },
      failure: (failure) {
        _currentUser = null;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Sends a genuine password reset email via auth provider.
  Future<Result<void>> sendPasswordReset(String email) async {
    final emailError = AppValidators.email(email);
    if (emailError != null) {
      return Result.failure(ValidationFailure(message: emailError));
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.resetPassword(email.trim());

    _isLoading = false;
    if (result.isFailure) {
      _errorMessage = result.failureOrNull?.message;
    }
    notifyListeners();
    return result;
  }

  /// Changes password requiring re-authentication with current password.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Current password is required.'),
      );
    }

    if (newPassword.length < 8) {
      return const Result.failure(
        ValidationFailure(
          message: 'New password must be at least 8 characters.',
        ),
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    if (result.isFailure) {
      _errorMessage = result.failureOrNull?.message;
    }
    notifyListeners();
    return result;
  }

  /// Updates email requiring password verification.
  Future<Result<void>> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    final emailError = AppValidators.email(newEmail);
    if (emailError != null) {
      return Result.failure(ValidationFailure(message: emailError));
    }

    if (password.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Password is required to verify identity.'),
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.changeEmail(
      newEmail: newEmail.trim(),
      password: password,
    );

    _isLoading = false;
    if (result.isFailure) {
      _errorMessage = result.failureOrNull?.message;
    }
    notifyListeners();
    return result;
  }

  /// Permanently deletes account via server-backed RPC flow after password confirmation.
  Future<Result<void>> deleteAccount({
    required String passwordConfirm,
    BuildContext? context,
  }) async {
    if (passwordConfirm.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Password confirmation is required.'),
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.deleteAccount(
      passwordConfirm: passwordConfirm,
    );

    _isLoading = false;

    if (result.isSuccess) {
      clearForm();
      _currentUser = null;
      if (context != null && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (route) => false,
        );
      }
    } else {
      _errorMessage = result.failureOrNull?.message;
    }

    notifyListeners();
    return result;
  }

  /// Logs out the user, clearing all local state and session tokens.
  Future<void> logout([BuildContext? context]) async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.signOut();

    _currentUser = null;
    clearForm();
    _isLoading = false;
    notifyListeners();

    if (context != null && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    pageController.dispose();
    headerPageController.dispose();
    super.dispose();
  }
}
