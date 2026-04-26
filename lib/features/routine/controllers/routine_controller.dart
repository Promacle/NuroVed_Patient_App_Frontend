import 'package:flutter/material.dart';

class RoutineController extends ChangeNotifier {
  static final RoutineController _instance = RoutineController._internal();
  factory RoutineController() => _instance;
  RoutineController._internal() {
    // Initialize default data for the main user
    _initializeProfile("Fazilkhan Malek");
  }

  String selectedTab = "Routines";
  String _currentProfile = "Fazilkhan Malek";

  // Data storage per profile
  final Map<String, List<Map<String, dynamic>>> _medicinesPerProfile = {};
  final Map<String, List<Map<String, dynamic>>> _mealsPerProfile = {};

  double progress = 0.0;
  String progressText = "0/0 Completed";

  // Getters for the current profile's data
  List<Map<String, dynamic>> get medicines =>
      _medicinesPerProfile[_currentProfile] ?? [];
  List<Map<String, dynamic>> get meals =>
      _mealsPerProfile[_currentProfile] ?? [];

  void _initializeProfile(String name) {
    if (!_medicinesPerProfile.containsKey(name)) {
      _medicinesPerProfile[name] = [
        {
          "name": "Atorvastatin 10mg",
          "instruction": "1 tablet * 09:00 * Take Before bed",
          "isCompleted": false,
        },
        {
          "name": "Aspirin 75mg",
          "instruction": "1 tablet * 09:00 * Take after lunch",
          "isCompleted": false,
        },
        {
          "name": "Atorvastatin 10mg",
          "instruction": "2 tablet * 09:00 * Take before breakfast",
          "isCompleted": true,
        },
      ];
    }
    if (!_mealsPerProfile.containsKey(name)) {
      _mealsPerProfile[name] = [
        {
          "title": "Breakfast",
          "time": "Morning * 08:00 AM",
          "mealName": "Oatmeal with Banana and Almond Milk",
          "calories": "350 Calories",
          "ingredients": ["rolled oats", "banana", "almond milk"],
          "isCompleted": false,
        },
        {
          "title": "Lunch",
          "time": "Afternoon * 01:00 PM",
          "mealName": "Vegetable Wrap",
          "calories": "400 Calories",
          "ingredients": [
            "whole wheat wrap",
            "cucumber",
            "tomato",
            "boiled potato",
            "onion",
          ],
          "isCompleted": false,
        },
        {
          "title": "Dinner",
          "time": "Dinner * 08:00 PM",
          "mealName": "Quinoa and Vegetable Stir-Fry",
          "calories": "500 Calories",
          "ingredients": ["quinoa", "broccoli", "carrots", "onions", "potato"],
          "isCompleted": false,
        },
      ];
    }
    _recalculateProgress();
  }

  void setProfile(String name) {
    _currentProfile = name;
    _initializeProfile(name); // Ensure data exists for this profile
    notifyListeners();
  }

  void toggleMedicine(int index) {
    if (index < medicines.length) {
      medicines[index]['isCompleted'] = !medicines[index]['isCompleted'];
      _recalculateProgress();
    }
  }

  void updateTab(String tab) {
    selectedTab = tab;
    notifyListeners();
  }

  void intakeMeal(String title) {
    final index = meals.indexWhere((m) => m['title'] == title);
    if (index != -1 && !meals[index]['isCompleted']) {
      meals[index]['isCompleted'] = true;
      _recalculateProgress();
    }
  }

  void updateMeal(
    String title,
    String newMealName,
    List<String> newIngredients,
  ) {
    final index = meals.indexWhere((m) => m['title'] == title);
    if (index != -1) {
      meals[index]['mealName'] = newMealName;
      meals[index]['ingredients'] = newIngredients;
      notifyListeners();
    }
  }

  void addMedicine(String name, String instruction) {
    if (!_medicinesPerProfile.containsKey(_currentProfile)) {
      _medicinesPerProfile[_currentProfile] = [];
    }
    _medicinesPerProfile[_currentProfile]!.add({
      "name": name,
      "instruction": instruction,
      "isCompleted": false,
    });
    _recalculateProgress();
  }

  void _recalculateProgress() {
    // Select the list based on the current tab
    final targetItems = selectedTab == "Medicines" ? medicines : meals;
    final totalCount = targetItems.length;

    if (totalCount == 0) {
      progress = 0.0;
      progressText = "0/0 Completed";
    } else {
      int completedCount = targetItems
          .where((item) => item['isCompleted'] == true)
          .length;

      // Calculate progress percentage based on the selected tab's items
      progress = completedCount / totalCount;

      // Update text to show "completed/total" for the selected tab
      progressText = "$completedCount/$totalCount Completed";
    }
    notifyListeners();
  }
}
