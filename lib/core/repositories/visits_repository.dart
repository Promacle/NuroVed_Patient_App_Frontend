import '../models/medical_record.dart';
import '../models/visit.dart';
import '../utils/result.dart';

enum VisitSortOrder {
  newestFirst,
  oldestFirst,
}

abstract class VisitsRepository {
  Future<Result<List<Visit>>> getVisits({
    String? subjectId,
    String? profileName,
    VisitSortOrder sortOrder = VisitSortOrder.newestFirst,
  });

  Future<Result<Visit>> addVisit(Visit visit);

  Future<Result<Visit>> updateVisit(Visit visit);

  /// Soft deletes a clinical visit by ID.
  Future<Result<void>> deleteVisit(String visitId);

  /// Retrieves canonical medical records linked to this visit via `visit_record_links`.
  Future<Result<List<MedicalRecord>>> getRelatedRecords(String visitId);
}

