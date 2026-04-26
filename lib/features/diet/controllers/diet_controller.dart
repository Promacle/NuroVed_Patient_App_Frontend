import 'package:flutter/material.dart';

class DietController extends ChangeNotifier {
  static final DietController _instance = DietController._internal();
  factory DietController() => _instance;
  DietController._internal();

  Map<String, dynamic>? _savedDietPlan;
  Map<String, dynamic>? get savedDietPlan => _savedDietPlan;

  void saveDietPlan(Map<String, dynamic> plan) {
    _savedDietPlan = plan;
    notifyListeners();
  }

  void deleteDietPlan() {
    _savedDietPlan = null;
    notifyListeners();
  }

  bool get hasSavedPlan => _savedDietPlan != null;
}
