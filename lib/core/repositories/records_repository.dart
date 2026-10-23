import '../models/medical_record.dart';
import '../utils/result.dart';

abstract class RecordsRepository {
  Future<Result<List<MedicalRecord>>> getRecords({
    String? profileName,
    String? searchQuery,
    String? recordType,
  });

  Future<Result<MedicalRecord>> addRecord(MedicalRecord record);

  Future<Result<void>> deleteRecord(String recordId);
}
