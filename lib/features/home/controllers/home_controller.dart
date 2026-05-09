import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  // 1. Create a Singleton
  static final HomeController _instance = HomeController._internal();
  factory HomeController() => _instance;
  HomeController._internal();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // 2. Method to switch tabs
  void setTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners(); // This triggers the UI update
    }
  }
}
