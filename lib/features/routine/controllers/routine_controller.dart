import 'package:flutter/material.dart';

import '../../../core/models/medicine_routine.dart';
import '../../../core/services/fake_notification_scheduler.dart';
import '../../../core/services/notification_scheduler.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../profile/controllers/profile_controller.dart';

class RoutineController extends ChangeNotifier {
  static final RoutineController _instance = RoutineController._internal();
  factory RoutineController() => _instance;

  NotificationScheduler _scheduler = FakeNotificationScheduler();
  NotificationScheduler get scheduler => _scheduler;

  void setScheduler(NotificationScheduler scheduler) {
    _scheduler = scheduler;
  }

  RoutineController._internal() {
    _attachProfileListener();
    _initializeProfile(_profileController.activeSubjectId);
  }

  void _attachProfileListener() {
    ProfileController.instance.removeListener(_onProfileChanged);
    ProfileController.instance.addListener(_onProfileChanged);
  }

  static void resetForTesting({NotificationScheduler? scheduler}) {
    _instance._medicinesPerSubject.clear();
    _instance._mealsPerSubject.clear();
    _instance._currentSubjectId = null;
    _instance.progress = 0.0;
    _instance.progressText = "0/0 Completed";
    _instance._scheduler = scheduler ?? FakeNotificationScheduler();
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
      _medicinesPerSubject[_currentSubjectId ??
          _profileController.activeSubjectId] ??
      [];

  List<Map<String, dynamic>> get meals =>
      _mealsPerSubject[_currentSubjectId ??
          _profileController.activeSubjectId] ??
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
      if (subjectId == _profileController.profile.id) {
        _medicinesPerSubject[subjectId] = [
          {
            "id": "med-default-1",
            "subjectId": subjectId,
            "name": "Atorvastatin 10mg",
            "dosage": "10mg",
            "instruction": "1 tablet * 09:00 * Take Before bed",
            "source": RoutineSource.verifiedPrescription.name,
            "source_display": "Verified Prescription",
            "isCompleted": false,
          },
          {
            "id": "med-default-2",
            "subjectId": subjectId,
            "name": "Aspirin 75mg",
            "dosage": "75mg",
            "instruction": "1 tablet * 09:00 * Take after lunch",
            "source": RoutineSource.verifiedPrescription.name,
            "source_display": "Verified Prescription",
            "isCompleted": false,
          },
          {
            "id": "med-default-3",
            "subjectId": subjectId,
            "name": "Metformin 500mg",
            "dosage": "500mg",
            "instruction": "1 tablet * 08:00 * Take with breakfast",
            "source": RoutineSource.verifiedPrescription.name,
            "source_display": "Verified Prescription",
            "isCompleted": true,
          },
        ];
      } else {
        // Family members start with clean, isolated schedule
        _medicinesPerSubject[subjectId] = [];
      }
    }

    if (!_mealsPerSubject.containsKey(subjectId)) {
      if (subjectId == _profileController.profile.id) {
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
      final map = Map<String, dynamic>.from(nameOrMap);
      map['id'] ??= UuidGenerator.v4();
      map['subjectId'] = subjectId;
      map['source'] ??= RoutineSource.selfEntered.name;
      map['source_display'] ??=
          (map['source'] == RoutineSource.verifiedPrescription.name
          ? "Verified Prescription"
          : "Self-Entered");
      map['isCompleted'] ??= false;
      _medicinesPerSubject[subjectId]!.add(map);
    } else {
      _medicinesPerSubject[subjectId]!.add({
        "id": UuidGenerator.v4(),
        "subjectId": subjectId,
        "name": nameOrMap.toString(),
        "instruction": instruction ?? "",
        "source": RoutineSource.selfEntered.name,
        "source_display": "Self-Entered",
        "isCompleted": false,
      });
    }

    _recalculateProgress();
    notifyListeners();
  }

  void updateMedicine(int index, Map<String, dynamic> updated) {
    final subjectId = _currentSubjectId ?? _profileController.activeSubjectId;
    final list = _medicinesPerSubject[subjectId];
    if (list != null && index >= 0 && index < list.length) {
      final existing = list[index];
      list[index] = {...existing, ...updated, 'subjectId': subjectId};
      _recalculateProgress();
      notifyListeners();
    }
  }

  void deleteMedicine(int index) {
    final subjectId = _currentSubjectId ?? _profileController.activeSubjectId;
    final list = _medicinesPerSubject[subjectId];
    if (list != null && index >= 0 && index < list.length) {
      list.removeAt(index);
      _recalculateProgress();
      notifyListeners();
    }
  }

  void deleteMedicineById(String id) {
    final subjectId = _currentSubjectId ?? _profileController.activeSubjectId;
    final list = _medicinesPerSubject[subjectId];
    if (list != null) {
      list.removeWhere((m) => m['id'] == id);
      _recalculateProgress();
      notifyListeners();
    }
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

  /// Purges in-memory medicine and meal routines upon user sign out or account deletion.
  void clear() {
    _medicinesPerSubject.clear();
    _mealsPerSubject.clear();
    _currentSubjectId = null;
    progress = 0.0;
    progressText = "0/0 Completed";
    notifyListeners();
  }

  @override
  void dispose() {
    _profileController.removeListener(_onProfileChanged);
    super.dispose();
  }
}
