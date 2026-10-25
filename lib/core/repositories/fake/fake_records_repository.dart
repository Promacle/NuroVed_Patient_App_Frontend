import '../../errors/failures.dart';
import '../../models/medical_record.dart';
import '../../utils/platform_file.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../records_repository.dart';

/// In-memory fake implementation of [RecordsRepository] for unit and widget tests.
class FakeRecordsRepository implements RecordsRepository {
  final List<MedicalRecord> _records = [];
  final Map<String, List<int>> _storageObjects = {}; // storagePath -> bytes

  bool shouldFail = false;
  bool shouldFailUpload = false;
  bool shouldFailSaveMetadata = false;
  int uploadDelayMs = 0;

  bool get shouldFailRecordSave => shouldFailSaveMetadata;
  set shouldFailRecordSave(bool val) => shouldFailSaveMetadata = val;

  Map<String, List<int>> get storageFiles => _storageObjects;

  FakeRecordsRepository({List<MedicalRecord>? initialRecords}) {
    if (initialRecords != null) {
      _records.addAll(initialRecords);
    }
  }

  List<MedicalRecord> get internalRecords => List.unmodifiable(_records);
  Map<String, List<int>> get internalStorage =>
      Map.unmodifiable(_storageObjects);

  @override
  Future<Result<String>> uploadFile({
    required String ownerId,
    required String subjectId,
    required String recordId,
    required AppPlatformFile file,
    void Function(double progress)? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (shouldFail || shouldFailUpload) {
      return const Result.failure(
        ServerFailure(message: 'Storage upload failed: network error'),
      );
    }

    // Simulate progress updates
    for (double p = 0.25; p <= 1.0; p += 0.25) {
      if (isCancelled?.call() == true) {
        return const Result.failure(
          NetworkFailure(message: 'Upload was cancelled by user'),
        );
      }
      onProgress?.call(p);
      final delay = uploadDelayMs > 0 ? (uploadDelayMs / 4).round() : 10;
      await Future<void>.delayed(Duration(milliseconds: delay));
    }

    if (isCancelled?.call() == true) {
      return const Result.failure(
        NetworkFailure(message: 'Upload was cancelled by user'),
      );
    }

    // Validate path segments against path traversal
    if (ownerId.contains('/') ||
        ownerId.contains(r'\') ||
        ownerId.contains('..') ||
        subjectId.contains('/') ||
        subjectId.contains(r'\') ||
        subjectId.contains('..') ||
        recordId.contains('/') ||
        recordId.contains(r'\') ||
        recordId.contains('..')) {
      return const Result.failure(
        ValidationFailure(
          message: 'Invalid path segments: path traversal detected',
        ),
      );
    }

    // Storage path follows Phase 3 schema convention: {owner_id}/{subject_id}/{record_id}/{filename}
    final storagePath = '$ownerId/$subjectId/$recordId/${file.sanitizedName}';
    _storageObjects[storagePath] = file.bytes ?? [];

    return Result.success(storagePath);
  }

  @override
  Future<Result<void>> deleteStorageFile(String storagePath) async {
    _storageObjects.remove(storagePath);
    return const Result.success(null);
  }

  @override
  Future<Result<List<MedicalRecord>>> getRecords({
    String? subjectId,
    String? profileName,
    String? searchQuery,
    String? recordType,
    RecordSortOrder sortOrder = RecordSortOrder.newestFirst,
  }) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to fetch medical records'),
      );
    }

    // Only active (non-deleted) records
    var list = _records.where((r) => !r.isDeleted).toList();

    if (subjectId != null && subjectId.isNotEmpty) {
      list = list.where((r) => r.subjectId == subjectId).toList();
    } else if (profileName != null && profileName.isNotEmpty) {
      list = list
          .where(
            (r) => r.profileName.toLowerCase() == profileName.toLowerCase(),
          )
          .toList();
    }

    if (recordType != null &&
        recordType.isNotEmpty &&
        recordType.toLowerCase() != 'all') {
      final normalizedFilter = recordType.toLowerCase().replaceAll("'", "");
      list = list
          .where(
            (r) =>
                r.recordType.toLowerCase().replaceAll("'", "") ==
                normalizedFilter,
          )
          .toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((r) {
        return r.title.toLowerCase().contains(q) ||
            (r.doctorName?.toLowerCase().contains(q) ?? false) ||
            (r.hospitalName?.toLowerCase().contains(q) ?? false) ||
            (r.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Apply sorting
    switch (sortOrder) {
      case RecordSortOrder.newestFirst:
        list.sort((a, b) {
          final da = a.createdAt ?? DateTime.tryParse(a.date) ?? DateTime(1970);
          final db = b.createdAt ?? DateTime.tryParse(b.date) ?? DateTime(1970);
          return db.compareTo(da);
        });
        break;
      case RecordSortOrder.oldestFirst:
        list.sort((a, b) {
          final da = a.createdAt ?? DateTime.tryParse(a.date) ?? DateTime(1970);
          final db = b.createdAt ?? DateTime.tryParse(b.date) ?? DateTime(1970);
          return da.compareTo(db);
        });
        break;
      case RecordSortOrder.titleAsc:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case RecordSortOrder.titleDesc:
        list.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
    }

    return Result.success(List.unmodifiable(list));
  }

  @override
  Future<Result<MedicalRecord>> addRecord(MedicalRecord record) async {
    if (shouldFail || shouldFailSaveMetadata) {
      return const Result.failure(
        ServerFailure(message: 'Failed to save medical record metadata'),
      );
    }
    final created = record.id.isEmpty
        ? record.copyWith(id: UuidGenerator.v4(), createdAt: DateTime.now())
        : (record.createdAt == null
              ? record.copyWith(createdAt: DateTime.now())
              : record);
    _records.insert(0, created);
    return Result.success(created);
  }

  @override
  Future<Result<MedicalRecord>> updateRecord(MedicalRecord record) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to update medical record metadata'),
      );
    }
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index == -1) {
      return const Result.failure(
        ServerFailure(message: 'Medical record not found'),
      );
    }
    final updated = record.copyWith(updatedAt: DateTime.now());
    _records[index] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<String>> getSignedUrl(
    String recordId, {
    Duration expiresIn = const Duration(minutes: 15),
  }) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to generate signed URL'),
      );
    }
    final record = _records
        .where(
          (r) =>
              (r.id == recordId || r.storagePath == recordId) && !r.isDeleted,
        )
        .firstOrNull;
    if (record == null) {
      return const Result.failure(
        ServerFailure(message: 'Medical record not found or has been deleted'),
      );
    }
    if (record.storagePath == null || record.storagePath!.isEmpty) {
      return const Result.failure(
        ServerFailure(message: 'Record has no attached storage file'),
      );
    }

    // In a live environment, this calls authorize_medical_file_access RPC then creates signed URL
    final signedUrl =
        'https://fake.supabase.co/storage/v1/object/sign/medical-records/${record.storagePath}?token=fake_signed_${UuidGenerator.v4().substring(0, 8)}&expires=${expiresIn.inSeconds}';
    return Result.success(signedUrl);
  }

  @override
  Future<Result<void>> deleteRecord(String recordId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to delete medical record'),
      );
    }
    // Soft delete: sets deletedAt
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      _records[index] = _records[index].copyWith(deletedAt: DateTime.now());
    }
    return const Result.success(null);
  }
}
