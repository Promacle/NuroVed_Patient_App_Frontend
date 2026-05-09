import 'package:flutter/material.dart';

class SplashController extends ChangeNotifier {
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  void toggleCheckbox(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }

  void handleGetStarted(BuildContext context) {
    if (_isChecked) {
      // Navigate to Login
    }
  }
}
