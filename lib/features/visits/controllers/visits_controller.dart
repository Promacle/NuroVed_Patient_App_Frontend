import 'package:flutter/material.dart';

import '../../../core/errors/failures.dart';
import '../../../core/models/medical_record.dart';
import '../../../core/models/visit.dart';
import '../../../core/repositories/fake/fake_visits_repository.dart';
import '../../../core/repositories/visits_repository.dart';
import '../../../core/utils/date_parser.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../records/controllers/records_controller.dart';

enum TimelineItemType { visit, record }

/// Unified timeline entry combining clinical visits and diagnostic records.
class TimelineItem {
  final String id;
  final TimelineItemType type;
  final DateTime date;
  final String displayDate;
  final String title;
  final String subtitle;
  final IconData icon;
  final Visit? visit;
  final MedicalRecord? record;

  const TimelineItem({
    required this.id,
    required this.type,
    required this.date,
    required this.displayDate,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.visit,
    this.record,
  });
}

class VisitsController extends ChangeNotifier {
  static VisitsController _instance = VisitsController._internal();
  static VisitsController get instance => _instance;
  factory VisitsController({VisitsRepository? repository}) {
    if (repository != null) {
      _instance._repository = repository;
    }
    return _instance;
  }

  VisitsRepository _repository;
  VisitsRepository get repository => _repository;

  VisitsController._internal({VisitsRepository? repository, bool empty = false})
      : _repository = repository ??
            FakeVisitsRepository(
              recordsRepository: RecordsController.instance.repository,
            ) {
    _attachProfileListener();
    if (!empty) {
      _initializeDefaultVisits();
    }
  }

  static void resetForTesting({VisitsRepository? repository, bool empty = false}) {
    ProfileController.instance.removeListener(_instance._onProfileChanged);
    _instance = VisitsController._internal(
      repository: repository ??
          FakeVisitsRepository(
            recordsRepository: RecordsController.instance.repository,
          ),
      empty: empty,
    );
  }

  void _attachProfileListener() {
    ProfileController.instance.removeListener(_onProfileChanged);
    ProfileController.instance.addListener(_onProfileChanged);
  }

  ProfileController get _profileController => ProfileController.instance;

  final List<Visit> _allVisits = [];
  final List<Visit> _visits = [];
  String? _currentSubjectId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  VisitSortOrder _sortOrder = VisitSortOrder.newestFirst;

  /// Strongly-typed immutable visits list for the active subject
  List<Visit> get visits => List.unmodifiable(_visits);

  /// Backward-compatible list of maps for legacy UI widgets
  List<Map<String, dynamic>> get filteredVisits {
    return _visits.map((v) {
      final map = v.toMap();
      map['icon'] = Icons.local_hospital_rounded;
      map['visit'] = v;
      return map;
    }).toList();
  }

  void _initializeDefaultVisits() {
    final selfId = _profileController.profile.id;
    final now = DateTime.now();

    // Default visits for self
    final initialVisits = [
      Visit(
        id: "visit-1",
        userId: _profileController.profile.id,
        subjectId: selfId,
        profileName: "Self",
        date: "10 january 2026",
        visitDate: DateTime(2026, 1, 10, 10, 0),
        title: "Visited Dr. Priya Mehta",
        subtitle: "Routine diabetes checkup.\nHbA1c levels discussed.",
        doctorName: "Dr. Priya Mehta",
        specialty: "Endocrinologist",
        hospitalName: "Apollo Hospitals",
        notes: "Routine diabetes checkup. HbA1c levels discussed.",
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Visit(
        id: "visit-2",
        userId: _profileController.profile.id,
        subjectId: selfId,
        profileName: "Self",
        date: "10 january 2026",
        visitDate: DateTime(2026, 1, 10, 14, 30),
        title: "Blood sugar test",
        subtitle: "Blood test report for sugar level",
        doctorName: "Dr. Priya Mehta",
        specialty: "Pathologist",
        hospitalName: "Apollo Diagnostic Lab",
        notes: "Fasting blood sugar 128 mg/dL. Post-prandial 164 mg/dL.",
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    _allVisits.addAll(initialVisits);
    for (final v in initialVisits) {
      _repository.addVisit(v);
    }
    _filterVisitsSynchronously();
  }

  void _filterVisitsSynchronously() {
    final activeId = _profileController.activeSubjectId;
    _currentSubjectId = activeId;
    _visits.clear();
    final matching = _allVisits.where((v) {
      if (v.isDeleted) return false;
      if (v.subjectId == activeId) return true;
      if (_profileController.isMainPatientActive &&
          (v.profileName.toLowerCase() == 'self' || v.subjectId.isEmpty)) {
        return true;
      }
      return false;
    }).toList();

    matching.sort((a, b) {
      final dateA = a.safeVisitDate;
      final dateB = b.safeVisitDate;
      if (_sortOrder == VisitSortOrder.newestFirst) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    _visits.addAll(matching);
    notifyListeners();
  }

  void _onProfileChanged() {
    final activeId = _profileController.activeSubjectId;
    if (_currentSubjectId != activeId) {
      _filterVisitsSynchronously();
      loadVisits();
    }
  }

  /// Loads visits for the active profile subject with timezone-safe ordering
  Future<void> loadVisits({
    VisitSortOrder sortOrder = VisitSortOrder.newestFirst,
  }) async {
    final activeId = _profileController.activeSubjectId;
    _currentSubjectId = activeId;
    _sortOrder = sortOrder;
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getVisits(
      subjectId: activeId,
      profileName: _profileController.activeProfileName,
      sortOrder: _sortOrder,
    );

    _isLoading = false;
    result.when(
      success: (data) {
        for (final v in data) {
          final idx = _allVisits.indexWhere((existing) => existing.id == v.id);
          if (idx != -1) {
            _allVisits[idx] = v;
          } else {
            _allVisits.add(v);
          }
        }
        _filterVisitsSynchronously();
      },
      failure: (f) {
        notifyListeners();
      },
    );
  }

  /// Adds a new visit with canonical deduplication of related records
  Future<Result<Visit>> addVisit(dynamic visitInput) async {
    final activeId = _profileController.activeSubjectId;
    Visit visit;

    if (visitInput is Visit) {
      visit = visitInput.copyWith(
        subjectId: visitInput.subjectId.isEmpty ? activeId : visitInput.subjectId,
        profileName: _profileController.activeProfileName,
        userId: _profileController.profile.id,
        relatedRecordIds: visitInput.relatedRecordIds.toSet().toList(),
      );
    } else if (visitInput is Map<String, dynamic>) {
      final parsedDate = DateParser.parse(visitInput['date']) ??
          (visitInput['visit_date'] != null
              ? DateParser.parse(visitInput['visit_date'])
              : DateTime.now());

      final rawRelated = visitInput['relatedRecordIds'] ??
          visitInput['related_record_ids'] ??
          visitInput['relatedRecord'];
      List<String> relatedList = [];
      if (rawRelated is List) {
        relatedList = rawRelated.map((e) => e.toString()).toList();
      } else if (rawRelated is String && rawRelated.isNotEmpty) {
        relatedList = [rawRelated];
      }

      visit = Visit(
        id: visitInput['id']?.toString() ?? UuidGenerator.v4(),
        userId: _profileController.profile.id,
        subjectId: activeId,
        profileName: _profileController.activeProfileName,
        date: visitInput['date']?.toString() ?? DateParser.formatDisplay(parsedDate),
        visitDate: parsedDate,
        title: visitInput['title']?.toString() ?? 'Doctor Visit',
        subtitle: visitInput['subtitle']?.toString() ?? '',
        doctorName: visitInput['doctor']?.toString() ?? visitInput['doctor_name']?.toString(),
        specialty: visitInput['specialty']?.toString(),
        hospitalName: visitInput['hospital']?.toString() ?? visitInput['hospital_name']?.toString(),
        notes: visitInput['notes']?.toString() ?? visitInput['subtitle']?.toString(),
        followUpDate: DateParser.parse(visitInput['follow_up_date'] ?? visitInput['followUpDate']),
        relatedRecordIds: relatedList.toSet().toList(),
        createdAt: DateTime.now(),
      );
    } else {
      return const Result.failure(
        ValidationFailure(message: 'Invalid visit input type'),
      );
    }

    // Synchronously insert into _allVisits and filter immediately so callers see the new visit right away
    _allVisits.removeWhere((v) => v.id == visit.id);
    _allVisits.insert(0, visit);
    _filterVisitsSynchronously();

    final result = await _repository.addVisit(visit);
    if (result.isSuccess) {
      final saved = result.dataOrNull!;
      final idx = _allVisits.indexWhere((v) => v.id == visit.id);
      if (idx != -1) {
        _allVisits[idx] = saved;
      }
      _filterVisitsSynchronously();
    } else {
      _allVisits.removeWhere((v) => v.id == visit.id);
      _filterVisitsSynchronously();
    }
    return result;
  }

  /// Updates an existing visit
  Future<Result<Visit>> updateVisit(Visit visit) async {
    final deduped = visit.copyWith(
      relatedRecordIds: visit.relatedRecordIds.toSet().toList(),
    );
    final result = await _repository.updateVisit(deduped);
    if (result.isSuccess) {
      final saved = result.dataOrNull!;
      final idx = _allVisits.indexWhere((v) => v.id == saved.id);
      if (idx != -1) _allVisits[idx] = saved;
      final vIdx = _visits.indexWhere((v) => v.id == saved.id);
      if (vIdx != -1) _visits[vIdx] = saved;
      notifyListeners();
      await loadVisits(sortOrder: _sortOrder);
    }
    return result;
  }

  /// Soft deletes a visit
  Future<Result<void>> deleteVisit(String visitId) async {
    final result = await _repository.deleteVisit(visitId);
    if (result.isSuccess) {
      _allVisits.removeWhere((v) => v.id == visitId);
      _visits.removeWhere((v) => v.id == visitId);
      notifyListeners();
      await loadVisits(sortOrder: _sortOrder);
    }
    return result;
  }

  /// Fetches canonical MedicalRecord entities linked to a visit
  Future<List<MedicalRecord>> getRelatedRecords(String visitId) async {
    final result = await _repository.getRelatedRecords(visitId);
    return result.dataOrNull ?? [];
  }

  /// Produces a unified chronological timeline merging visits and medical records
  /// for the active subject, strictly sorted newest first (timezone-safe).
  List<TimelineItem> getTimelineItems({RecordsController? recordsController}) {
    final recCtrl = recordsController ?? RecordsController.instance;
    final List<TimelineItem> items = [];

    // 1. Convert active subject visits
    for (final visit in _visits) {
      items.add(
        TimelineItem(
          id: visit.id,
          type: TimelineItemType.visit,
          date: visit.safeVisitDate,
          displayDate: DateParser.formatDisplay(visit.safeVisitDate),
          title: visit.title,
          subtitle: visit.subtitle,
          icon: Icons.local_hospital_rounded,
          visit: visit,
        ),
      );
    }

    // 2. Convert active subject medical records
    for (final record in recCtrl.records) {
      items.add(
        TimelineItem(
          id: record.id,
          type: TimelineItemType.record,
          date: record.safeRecordDate,
          displayDate: DateParser.formatDisplay(record.safeRecordDate),
          title: record.title,
          subtitle: record.recordType,
          icon: Icons.folder_open_outlined,
          record: record,
        ),
      );
    }

    // 3. Sort chronologically newest first
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  void dispose() {
    _profileController.removeListener(_onProfileChanged);
    super.dispose();
  }
}

