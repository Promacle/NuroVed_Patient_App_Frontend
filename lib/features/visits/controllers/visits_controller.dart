import 'package:flutter/material.dart';

import '../../profile/controllers/profile_controller.dart';

class VisitsController extends ChangeNotifier {
  // Singleton pattern to share visit data between screens
  static final VisitsController _instance = VisitsController._internal();
  factory VisitsController() => _instance;

  VisitsController._internal() {
    // Initial dummy data
    _allVisits = [
      {
        "profile": "Fazilkhan Malek",
        "date": "10 january 2026",
        "title": "Visited Dr. Priya Mehta",
        "subtitle": "Routine diabetes checkup.\nHbA1c levels discussed.",
        "icon": Icons.local_hospital_rounded,
      },
      {
        "profile": "Fazilkhan Malek",
        "date": "10 january 2026",
        "title": "Blood sugar test",
        "subtitle": "Blood test report for sugar level",
        "icon": Icons.medical_services_outlined,
      },
    ];
  }

  final ProfileController _profileController = ProfileController();

  List<Map<String, dynamic>> _allVisits = [];
  List<Map<String, dynamic>> filteredVisits = [];

  void loadVisits() {
    final activeProfile = _profileController.activeProfileName;
    // Filter visits based on the selected family member
    filteredVisits = _allVisits
        .where((visit) => visit['profile'] == activeProfile)
        .toList();
    notifyListeners();
  }

  void addVisit(Map<String, dynamic> visit) {
    _allVisits.insert(0, visit); // Add new visits to the top of the timeline
    loadVisits();
  }
}
