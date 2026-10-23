import 'package:flutter/material.dart';

import '../../profile/controllers/profile_controller.dart';

class RecordsController extends ChangeNotifier {
  static final RecordsController _instance = RecordsController._internal();
  factory RecordsController() => _instance;

  RecordsController._internal() {
    _attachProfileListener();
  }

  void _attachProfileListener() {
    ProfileController.instance.removeListener(_onProfileChanged);
    ProfileController.instance.addListener(_onProfileChanged);
  }

  static void resetForTesting() {
    _instance.filteredRecords = [];
    _instance._recordsBySubjectId.clear();
    _instance.selectedFilter = "All";
    _instance._currentSubjectId = null;
    _instance._attachProfileListener();
  }

  ProfileController get _profileController => ProfileController.instance;

  // Records isolated strictly by subject UUID
  final Map<String, List<Map<String, dynamic>>> _recordsBySubjectId = {};

  List<Map<String, dynamic>> filteredRecords = [];
  String selectedFilter = "All";
  String? _currentSubjectId;

  Map<String, dynamic>? get recentRecord {
    return filteredRecords.isNotEmpty ? filteredRecords.last : null;
  }

  void _onProfileChanged() {
    final activeId = _profileController.activeSubjectId;
    if (_currentSubjectId != activeId) {
      // Immediately purge previous subject's records to prevent stale data flash
      filteredRecords = [];
      _currentSubjectId = activeId;
      runFilter("");
    }
  }

  /// Reloads records strictly for the active subject ID
  void runFilter(String query) {
    final activeId = _profileController.activeSubjectId;

    if (_currentSubjectId != activeId) {
      // Purge previous subject records
      filteredRecords = [];
      _currentSubjectId = activeId;
    }

    final allSubjectRecords = _recordsBySubjectId[activeId] ?? [];

    filteredRecords = allSubjectRecords
        .map((e) => Map<String, dynamic>.from(e))
        .where((record) {
          final bool matchesSearch = query.isEmpty ||
              (record["title"] ?? "").toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              (record["sub"] ?? "").toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );

          final bool matchesFilter =
              selectedFilter == "All" || record["type"] == selectedFilter;

          return matchesSearch && matchesFilter;
        })
        .toList();

    notifyListeners();
  }

  void addRecord(Map<String, dynamic> record, [String currentSearch = ""]) {
    final activeId = _profileController.activeSubjectId;
    if (!_recordsBySubjectId.containsKey(activeId)) {
      _recordsBySubjectId[activeId] = [];
    }
    final newRecord = Map<String, dynamic>.from(record);
    newRecord['subjectId'] = activeId;
    _recordsBySubjectId[activeId]!.add(newRecord);
    runFilter(currentSearch);
  }

  void deleteRecord(Map<String, dynamic> record, String currentSearch) {
    final activeId = _profileController.activeSubjectId;
    final records = _recordsBySubjectId[activeId];
    if (records != null) {
      records.removeWhere(
        (r) =>
            r['id'] == record['id'] ||
            (r['title'] == record['title'] && r['date'] == record['date']),
      );
    }
    runFilter(currentSearch);
  }

  @override
  void dispose() {
    _profileController.removeListener(_onProfileChanged);
    super.dispose();
  }
}
