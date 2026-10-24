import '../models/medical_record.dart';
import '../utils/platform_file.dart';
import '../utils/result.dart';

enum RecordSortOrder {
  newestFirst,
  oldestFirst,
  titleAsc,
  titleDesc,
}

abstract class RecordsRepository {
  Future<Result<List<MedicalRecord>>> getRecords({
    String? subjectId,
    String? profileName,
    String? searchQuery,
    String? recordType,
    RecordSortOrder sortOrder = RecordSortOrder.newestFirst,
  });

  /// Uploads file bytes to private bucket `medical-records` with path `{ownerId}/{subjectId}/{recordId}/{fileName}`.
  /// Reports upload progress (0.0 to 1.0) and supports cancellation.
  Future<Result<String>> uploadFile({
    required String ownerId,
    required String subjectId,
    required String recordId,
    required AppPlatformFile file,
    void Function(double progress)? onProgress,
    bool Function()? isCancelled,
  });

  /// Deletes an uploaded storage object from the private bucket (used for cleanup on partial failure).
  Future<Result<void>> deleteStorageFile(String storagePath);

  /// Saves canonical medical record metadata after successful file upload.
  Future<Result<MedicalRecord>> addRecord(MedicalRecord record);

  /// Updates existing medical record metadata.
  Future<Result<MedicalRecord>> updateRecord(MedicalRecord record);

  /// Generates a short-lived signed URL for file access after verifying caller authorization.
  Future<Result<String>> getSignedUrl(String recordId, {Duration expiresIn = const Duration(minutes: 15)});

  /// Soft deletes a medical record by ID.
  Future<Result<void>> deleteRecord(String recordId);
}
