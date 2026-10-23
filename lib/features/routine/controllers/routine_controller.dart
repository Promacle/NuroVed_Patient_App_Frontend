import 'package:flutter/material.dart';

import '../../profile/controllers/profile_controller.dart';

class RoutineController extends ChangeNotifier {
  static final RoutineController _instance = RoutineController._internal();
  factory RoutineController() => _instance;

  RoutineController._internal() {
    _attachProfileListener();
    _initializeProfile(_profileController.activeSubjectId);
  }

  void _attachProfileListener() {
    ProfileController.instance.removeListener(_onProfileChanged);
    ProfileController.instance.addListener(_onProfileChanged);
  }

  static void resetForTesting() {
    _instance._medicinesPerSubject.clear();
    _instance._mealsPerSubject.clear();
    _instance._currentSubjectId = null;
    _instance.progress = 0.0;
    _instance.progressText = "0/0 Completed";
    _instance._attachProfileListener();
    _instance._initializeProfile(ProfileController.instance.activeSubjectId);
  }

  ProfileController get _profileController => ProfileController.instance;

  String selectedTab = "Routines";
  String? _currentSubjectId;

  // Data storage per subject UUID
  final Map<String, List<Map<String, dynamic>>> _medicinesPerSubject = {};
  final Map<String, List<Map<String, dynamic>>> _mealsPerSubject = {};

  double progress = 0.0;
  String progressText = "0/0 Completed";

  List<Map<String, dynamic>> get medicines =>
      _medicinesPerSubject[_currentSubjectId ?? _profileController.activeSubjectId] ??
      [];

  List<Map<String, dynamic>> get meals =>
      _mealsPerSubject[_currentSubjectId ?? _profileController.activeSubjectId] ??
      [];

  void _onProfileChanged() {
    final activeId = _profileController.activeSubjectId;
    if (_currentSubjectId != activeId) {
      setSubject(activeId);
    }
  }

  void _initializeProfile(String subjectId) {
    if (!_medicinesPerSubject.containsKey(subjectId)) {
      // Default diabetic routine only for primary user
      if (subjectId == _profileController.profile.id || _profileController.isMainPatientActive) {
        _medicinesPerSubject[subjectId] = [
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
            "name": "Metformin 500mg",
            "instruction": "1 tablet * 08:00 * Take with breakfast",
            "isCompleted": true,
          },
        ];
      } else {
        // Family members start with clean, isolated schedule
        _medicinesPerSubject[subjectId] = [];
      }
    }

    if (!_mealsPerSubject.containsKey(subjectId)) {
      if (subjectId == _profileController.profile.id || _profileController.isMainPatientActive) {
        _mealsPerSubject[subjectId] = [
          {
            "title": "Breakfast",
            "time": "Morning * 08:00 AM",
            "mealName": "Oatmeal with Almond Milk",
            "calories": "350 Calories",
            "ingredients": ["rolled oats", "almond milk"],
            "isCompleted": false,
          },
          {
            "title": "Lunch",
            "time": "Afternoon * 01:00 PM",
            "mealName": "Vegetable Salad & Lentils",
            "calories": "400 Calories",
            "ingredients": ["cucumber", "tomato", "boiled lentils"],
            "isCompleted": false,
          },
        ];
      } else {
        _mealsPerSubject[subjectId] = [];
      }
    }

    _recalculateProgress();
  }

  void setSubject(String subjectId) {
    _currentSubjectId = subjectId;
    _initializeProfile(subjectId);
    notifyListeners();
  }

  /// Backward-compatible setProfile by name
  void setProfile(String name) {
    _profileController.switchSubjectByName(name);
  }

  void toggleMedicine(int index) {
    final list = medicines;
    if (index >= 0 && index < list.length) {
      list[index]['isCompleted'] = !(list[index]['isCompleted'] == true);
      _recalculateProgress();
      notifyListeners();
    }
  }

  void addMedicine(dynamic nameOrMap, [String? instruction]) {
    final subjectId = _currentSubjectId ?? _profileController.activeSubjectId;
    if (!_medicinesPerSubject.containsKey(subjectId)) {
      _medicinesPerSubject[subjectId] = [];
    }
    if (nameOrMap is Map<String, dynamic>) {
      _medicinesPerSubject[subjectId]!.add(Map<String, dynamic>.from(nameOrMap));
    } else {
      _medicinesPerSubject[subjectId]!.add({
        "name": nameOrMap.toString(),
        "instruction": instruction ?? "",
        "isCompleted": false,
      });
    }
    _recalculateProgress();
    notifyListeners();
  }

  void intakeMeal(String title) {
    final index = meals.indexWhere((m) => m['title'] == title);
    if (index != -1 && !meals[index]['isCompleted']) {
      meals[index]['isCompleted'] = true;
      _recalculateProgress();
      notifyListeners();
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

  void updateTab(String tab) {
    selectedTab = tab;
    _recalculateProgress();
    notifyListeners();
  }

  void _recalculateProgress() {
    int completed = 0;
    int total = 0;

    if (selectedTab == "Medicines" || selectedTab == "Routines") {
      final list = medicines;
      total = list.length;
      completed = list.where((m) => m['isCompleted'] == true).length;
    } else {
      final list = meals;
      total = list.length;
      completed = list.where((m) => m['isCompleted'] == true).length;
    }

    progress = total == 0 ? 0.0 : completed / total;
    progressText = "$completed/$total Completed";
  }

  @override
  void dispose() {
    _profileController.removeListener(_onProfileChanged);
    super.dispose();
  }
}
