import 'package:flutter/material.dart';

import '../../profile/controllers/profile_controller.dart';

class RecordsController extends ChangeNotifier {
  final ProfileController _profileController = ProfileController();

  // The list now stores dynamic maps to accommodate records saved from AddRecordScreen
  List<Map<String, dynamic>> filteredRecords = [];
  String selectedFilter = "All";

  // Returns the last record added (most recent)
  Map<String, dynamic>? get recentRecord {
    return filteredRecords.isNotEmpty ? filteredRecords.last : null;
  }

  void runFilter(String query) {
    // 1. Get the current active profile name
    final activeProfile = _profileController.activeProfileName;

    // 2. Find the family member matching the active profile
    final member = _profileController.familyMembers.firstWhere(
      (m) => m['name'] == activeProfile,
      orElse: () => <String, dynamic>{},
    );

    // 3. Get the records for this specific member
    final List<dynamic> allMemberRecords = member['records'] ?? [];

    // 4. Apply search and category filters
    filteredRecords = allMemberRecords
        .map((e) => Map<String, dynamic>.from(e))
        .where((record) {
          final bool matchesSearch =
              query.isEmpty ||
              (record["title"] ?? "").toLowerCase().contains(
                query.toLowerCase(),
              );

          final bool matchesFilter =
              selectedFilter == "All" || record["type"] == selectedFilter;

          return matchesSearch && matchesFilter;
        })
        .toList();

    notifyListeners();
  }

  void deleteRecord(Map<String, dynamic> record, String currentSearch) {
    final activeProfile = _profileController.activeProfileName;

    // Find the member in the ProfileController data
    final member = _profileController.familyMembers.firstWhere(
      (m) => m['name'] == activeProfile,
      orElse: () => <String, dynamic>{},
    );

    if (member.isNotEmpty && member['records'] != null) {
      // Remove by unique ID (or title/timestamp if ID isn't used)
      (member['records'] as List).removeWhere(
        (r) => r['title'] == record['title'] && r['date'] == record['date'],
      );
    }

    runFilter(currentSearch);
  }
}
