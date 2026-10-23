import 'package:flutter/material.dart';

import '../../profile/controllers/profile_controller.dart';

class VisitsController extends ChangeNotifier {
  static final VisitsController _instance = VisitsController._internal();
  factory VisitsController() => _instance;

  VisitsController._internal() {
    _attachProfileListener();
    _initializeDefaultVisits();
  }

  void _attachProfileListener() {
    ProfileController.instance.removeListener(_onProfileChanged);
    ProfileController.instance.addListener(_onProfileChanged);
  }

  static void resetForTesting() {
    _instance._allVisits.clear();
    _instance.filteredVisits = [];
    _instance._currentSubjectId = null;
    _instance._attachProfileListener();
  }

  ProfileController get _profileController => ProfileController.instance;

  final List<Map<String, dynamic>> _allVisits = [];
  List<Map<String, dynamic>> filteredVisits = [];
  String? _currentSubjectId;

  void _initializeDefaultVisits() {
    final selfId = _profileController.profile.id;
    _allVisits.addAll([
      {
        "id": "visit-1",
        "subjectId": selfId,
        "profile": "Self",
        "date": "10 january 2026",
        "title": "Visited Dr. Priya Mehta",
        "subtitle": "Routine diabetes checkup.\nHbA1c levels discussed.",
        "icon": Icons.local_hospital_rounded,
      },
      {
        "id": "visit-2",
        "subjectId": selfId,
        "profile": "Self",
        "date": "10 january 2026",
        "title": "Blood sugar test",
        "subtitle": "Blood test report for sugar level",
        "icon": Icons.medical_services_outlined,
      },
    ]);
    loadVisits();
  }

  void _onProfileChanged() {
    final activeId = _profileController.activeSubjectId;
    if (_currentSubjectId != activeId) {
      // Immediately purge previous visits to prevent stale data display
      filteredVisits = [];
      _currentSubjectId = activeId;
      loadVisits();
    }
  }

  void loadVisits() {
    final activeId = _profileController.activeSubjectId;
    _currentSubjectId = activeId;

    // Filter visits strictly for this active subject UUID
    filteredVisits = _allVisits.where((visit) {
      final subjectId = visit['subjectId']?.toString();
      if (subjectId == activeId) return true;
      // Fallback for default data before profile ID was assigned
      if (_profileController.isMainPatientActive &&
          (visit['profile'] == 'Self' || subjectId == null)) {
        return true;
      }
      return false;
    }).toList();

    notifyListeners();
  }

  void addVisit(Map<String, dynamic> visit) {
    final activeId = _profileController.activeSubjectId;
    final newVisit = Map<String, dynamic>.from(visit);
    newVisit['subjectId'] = activeId;
    newVisit['profile'] = _profileController.activeProfileName;

    _allVisits.insert(0, newVisit);
    loadVisits();
  }

  @override
  void dispose() {
    _profileController.removeListener(_onProfileChanged);
    super.dispose();
  }
}
