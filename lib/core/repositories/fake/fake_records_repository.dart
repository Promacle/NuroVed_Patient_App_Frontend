import '../../errors/failures.dart';
import '../../models/medical_record.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../records_repository.dart';

/// In-memory fake implementation of [RecordsRepository] for unit tests.
class FakeRecordsRepository implements RecordsRepository {
  final List<MedicalRecord> _records = [];
  bool shouldFail = false;

  FakeRecordsRepository({List<MedicalRecord>? initialRecords}) {
    if (initialRecords != null) {
      _records.addAll(initialRecords);
    }
  }

  @override
  Future<Result<List<MedicalRecord>>> getRecords({
    String? profileName,
    String? searchQuery,
    String? recordType,
  }) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to fetch medical records'),
      );
    }

    var list = _records.toList();

    if (profileName != null && profileName.isNotEmpty) {
      list = list
          .where(
            (r) => r.profileName.toLowerCase() == profileName.toLowerCase(),
          )
          .toList();
    }

    if (recordType != null &&
        recordType.isNotEmpty &&
        recordType.toLowerCase() != 'all') {
      list = list
          .where((r) => r.recordType.toLowerCase() == recordType.toLowerCase())
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

    return Result.success(List.unmodifiable(list));
  }

  @override
  Future<Result<MedicalRecord>> addRecord(MedicalRecord record) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to save medical record'),
      );
    }
    final created = record.id.isEmpty
        ? record.copyWith(id: UuidGenerator.v4(), createdAt: DateTime.now())
        : record;
    _records.insert(0, created);
    return Result.success(created);
  }

  @override
  Future<Result<void>> deleteRecord(String recordId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to delete medical record'),
      );
    }
    _records.removeWhere((r) => r.id == recordId);
    return const Result.success(null);
  }
}
