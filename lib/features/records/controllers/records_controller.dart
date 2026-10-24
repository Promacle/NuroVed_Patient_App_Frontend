import 'package:flutter/material.dart';

import '../../../core/errors/failures.dart';
import '../../../core/models/medical_record.dart';
import '../../../core/repositories/fake/fake_records_repository.dart';
import '../../../core/repositories/records_repository.dart';
import '../../../core/utils/platform_file.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../../core/utils/validators.dart';
import '../../profile/controllers/profile_controller.dart';

class RecordsController extends ChangeNotifier {
  static RecordsController _instance = RecordsController._internal();
  static RecordsController get instance => _instance;
  factory RecordsController({RecordsRepository? repository}) {
    if (repository != null) {
      _instance._repository = repository;
    }
    return _instance;
  }

  RecordsRepository _repository;
  RecordsRepository get repository => _repository;

  RecordsController._internal({RecordsRepository? repository})
      : _repository = repository ?? FakeRecordsRepository() {
    _attachProfileListener();
    loadRecords();
  }

  static void resetForTesting({RecordsRepository? repository}) {
    ProfileController.instance.removeListener(_instance._onProfileChanged);
    _instance = RecordsController._internal(
      repository: repository ?? FakeRecordsRepository(),
    );
  }

  void _attachProfileListener() {
    ProfileController.instance.removeListener(_onProfileChanged);
    ProfileController.instance.addListener(_onProfileChanged);
  }

  ProfileController get _profileController => ProfileController.instance;

  final List<MedicalRecord> _allRecords = [];
  final List<MedicalRecord> _records = [];
  String selectedFilter = "All";
  RecordSortOrder selectedSortOrder = RecordSortOrder.newestFirst;
  String _currentSearch = "";
  String? _currentSubjectId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _uploadError;
  String? get uploadError => _uploadError;

  UploadCancelToken? _cancelToken;

  /// Canonical records typed list
  List<MedicalRecord> get records => List.unmodifiable(_records);

  /// Backward-compatible list of maps for existing UI widgets
  List<Map<String, dynamic>> get filteredRecords {
    return _records.map((r) {
      final map = r.toMap();
      map['sub'] = r.description ?? r.recordType;
      return map;
    }).toList();
  }

  Map<String, dynamic>? get recentRecord {
    if (filteredRecords.isNotEmpty) {
      return filteredRecords.first;
    }
    return null;
  }

  void _filterRecordsSynchronously() {
    final activeId = _profileController.activeSubjectId;
    _currentSubjectId = activeId;
    _records.clear();
    _records.addAll(_allRecords.where((r) {
      if (r.isDeleted) return false;
      if (r.subjectId == activeId) return true;
      if (_profileController.isMainPatientActive &&
          (r.profileName.toLowerCase() == 'self' || r.subjectId.isEmpty)) {
        return true;
      }
      return false;
    }));
    notifyListeners();
  }

  void _onProfileChanged() {
    final activeId = _profileController.activeSubjectId;
    if (_currentSubjectId != activeId) {
      _filterRecordsSynchronously();
      loadRecords();
    }
  }

  /// Loads records from the repository for the active subject ID
  Future<void> loadRecords([String query = ""]) async {
    final activeId = _profileController.activeSubjectId;
    _currentSubjectId = activeId;
    _currentSearch = query;
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getRecords(
      subjectId: activeId,
      profileName: _profileController.activeProfileName,
      searchQuery: query,
      recordType: selectedFilter == "All" ? null : selectedFilter,
      sortOrder: selectedSortOrder,
    );

    _isLoading = false;
    result.when(
      success: (data) {
        _records.clear();
        _records.addAll(data);
        for (final d in data) {
          if (!_allRecords.any((r) => r.id == d.id)) {
            _allRecords.add(d);
          }
        }
        notifyListeners();
      },
      failure: (f) {
        notifyListeners();
      },
    );
  }

  void runFilter(String query) {
    loadRecords(query);
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    loadRecords(_currentSearch);
  }

  void setSortOrder(RecordSortOrder sortOrder) {
    selectedSortOrder = sortOrder;
    loadRecords(_currentSearch);
  }

  /// Cancels in-flight upload
  void cancelUpload() {
    _cancelToken?.cancel();
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  /// Uploads file to private storage bucket `medical-records` with progress/cancel/retry/duplicate protection,
  /// then persists record metadata only after upload succeeds.
  /// Cleans up orphaned storage file if metadata persistence fails.
  Future<Result<MedicalRecord>> uploadAndSaveRecord({
    required String title,
    required String recordType,
    required String date,
    String? doctorName,
    String? hospitalName,
    String? description,
    required AppPlatformFile file,
  }) async {
    // 1. Duplicate-submission protection
    if (_isUploading) {
      return const Result.failure(
        ValidationFailure(message: 'Upload already in progress. Please wait.'),
      );
    }

    // 2. Validate file (type, size <= 10MB, and magic bytes content signature)
    final validationError = Validators.validateMedicalDocument(
      fileName: file.name,
      byteLength: file.size,
      bytes: file.bytes,
    );
    if (validationError != null) {
      return Result.failure(ValidationFailure(message: validationError));
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadError = null;
    _cancelToken = UploadCancelToken();
    notifyListeners();

    final ownerId = _profileController.profile.id.isNotEmpty
        ? _profileController.profile.id
        : 'patient-primary-uuid';
    final subjectId = _profileController.activeSubjectId;
    final recordId = UuidGenerator.v4();

    // 3. Upload file to private storage bucket
    final uploadResult = await _repository.uploadFile(
      ownerId: ownerId,
      subjectId: subjectId,
      recordId: recordId,
      file: file,
      onProgress: (p) {
        _uploadProgress = p;
        notifyListeners();
      },
      isCancelled: () => _cancelToken?.isCancelled ?? false,
    );

    if (uploadResult.isFailure) {
      _isUploading = false;
      _uploadError = uploadResult.failureOrNull?.message ?? 'Upload failed';
      notifyListeners();
      return Result.failure(uploadResult.failureOrNull!);
    }

    final storagePath = uploadResult.dataOrNull!;

    // 4. Construct canonical record metadata (NO local file paths stored)
    final record = MedicalRecord(
      id: recordId,
      userId: ownerId,
      subjectId: subjectId,
      profileName: _profileController.activeProfileName,
      title: title.trim().isEmpty ? 'Untitled Record' : title.trim(),
      recordType: recordType.trim().isEmpty ? 'Other' : recordType.trim(),
      date: date.isNotEmpty ? date : DateTime.now().toIso8601String().split('T')[0],
      doctorName: doctorName?.trim(),
      hospitalName: hospitalName?.trim(),
      description: description?.trim(),
      storagePath: storagePath,
      fileName: file.name,
      mimeType: file.mimeType,
      fileSize: file.size,
      createdAt: DateTime.now(),
    );

    // 5. Persist record metadata
    final saveResult = await _repository.addRecord(record);

    if (saveResult.isFailure) {
      // Clean up orphaned storage object on partial failure
      await _repository.deleteStorageFile(storagePath);
      _isUploading = false;
      _uploadError = saveResult.failureOrNull?.message ?? 'Failed to save record metadata';
      notifyListeners();
      return Result.failure(saveResult.failureOrNull!);
    }

    final savedRecord = saveResult.dataOrNull!;
    _isUploading = false;
    _uploadProgress = 1.0;
    _allRecords.insert(0, savedRecord);
    _records.insert(0, savedRecord);
    notifyListeners();

    return Result.success(savedRecord);
  }

  /// Backward-compatible addRecord method
  void addRecord(Map<String, dynamic> recordMap, [String currentSearch = ""]) {
    final record = MedicalRecord.fromMap(recordMap).copyWith(
      subjectId: _profileController.activeSubjectId,
      profileName: _profileController.activeProfileName,
    );
    _allRecords.insert(0, record);
    _records.insert(0, record);
    _repository.addRecord(record);
    notifyListeners();
  }

  /// Soft deletes record by ID and refreshes view
  Future<Result<void>> softDeleteRecord(String recordId) async {
    final result = await _repository.deleteRecord(recordId);
    if (result.isSuccess) {
      _allRecords.removeWhere((r) => r.id == recordId);
      _records.removeWhere((r) => r.id == recordId);
      notifyListeners();
    }
    return result;
  }

  /// Alias for softDeleteRecord
  Future<Result<void>> deleteRecordById(String recordId) => softDeleteRecord(recordId);

  /// Updates an existing medical record's metadata
  Future<Result<MedicalRecord>> updateRecord(MedicalRecord record) async {
    final result = await _repository.updateRecord(record);
    if (result.isSuccess) {
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = result.dataOrNull!;
        notifyListeners();
      }
    }
    return result;
  }

  /// Backward-compatible deleteRecord method
  void deleteRecord(Map<String, dynamic> recordMap, String currentSearch) {
    final id = recordMap['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      softDeleteRecord(id);
    }
  }

  /// Retrieves short-lived signed URL for file preview or download
  Future<Result<String>> getSignedUrl(String recordId) async {
    return _repository.getSignedUrl(recordId);
  }

  MedicalRecord? getRecordById(String id) {
    return _records.where((r) => r.id == id).firstOrNull;
  }

  @override
  void dispose() {
    _profileController.removeListener(_onProfileChanged);
    super.dispose();
  }
}

