import '../models/visit.dart';
import '../utils/result.dart';

abstract class VisitsRepository {
  Future<Result<List<Visit>>> getVisits({String? profileName});

  Future<Result<Visit>> addVisit(Visit visit);

  Future<Result<void>> deleteVisit(String visitId);
}
