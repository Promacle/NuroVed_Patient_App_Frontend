import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller managing in-memory and local SharedPreferences persistence
/// of the patient's weekly nutritional diet plan.
class DietController extends ChangeNotifier {
  static DietController _instance = DietController._internal();
  factory DietController() => _instance;
  DietController._internal();

  static const String _defaultStorageKey = 'nuroved_saved_diet_plan_default';

  Map<String, dynamic>? _savedDietPlan;
  Map<String, dynamic>? get savedDietPlan => _savedDietPlan;

  String _currentStorageKey = _defaultStorageKey;

  /// Reset singleton for hermetic unit and widget testing
  static void resetForTesting({Map<String, dynamic>? initialPlan}) {
    _instance.dispose();
    _instance = DietController._internal();
    if (initialPlan != null) {
      _instance._savedDietPlan = Map<String, dynamic>.from(initialPlan);
    }
  }

  /// Sets the active health subject key and restores any persisted plan
  Future<void> setSubject(String subjectId) async {
    _currentStorageKey = 'nuroved_saved_diet_plan_$subjectId';
    await loadPersistedPlan();
  }

  /// Loads persisted plan from SharedPreferences into in-memory state
  Future<void> loadPersistedPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_currentStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _savedDietPlan = decoded;
        notifyListeners();
      }
    } catch (_) {
      // Graceful fallback to null if storage is unreadable or corrupt
    }
  }

  /// Synchronously updates in-memory plan and triggers background persistence
  void saveDietPlan(Map<String, dynamic> plan) {
    _savedDietPlan = plan;
    notifyListeners();
    _persistToDisk(plan);
  }

  /// Asynchronous plan persistence with completion guarantee
  Future<bool> saveDietPlanAsync(
    Map<String, dynamic> plan, {
    String? subjectId,
  }) async {
    _savedDietPlan = plan;
    notifyListeners();
    final key = subjectId != null
        ? 'nuroved_saved_diet_plan_$subjectId'
        : _currentStorageKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, jsonEncode(plan));
    } catch (_) {
      return false;
    }
  }

  /// Purges in-memory plan and deletes from disk
  void deleteDietPlan() {
    _savedDietPlan = null;
    notifyListeners();
    _deleteFromDisk();
  }

  /// Purges in-memory diet plan upon user sign out or account deletion.
  void clear() => deleteDietPlan();

  bool get hasSavedPlan => _savedDietPlan != null;

  Future<void> _persistToDisk(Map<String, dynamic> plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentStorageKey, jsonEncode(plan));
    } catch (_) {}
  }

  Future<void> _deleteFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentStorageKey);
    } catch (_) {}
  }
}
