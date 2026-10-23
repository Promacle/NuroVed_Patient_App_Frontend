import '../models/medical_record.dart';

abstract class RecordsDataSource {
  Future<List<MedicalRecord>> fetchRecords({String? profileName});
  Future<MedicalRecord> insertRecord(MedicalRecord record);
  Future<void> removeRecord(String recordId);
}
