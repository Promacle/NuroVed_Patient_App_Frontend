import '../../errors/failures.dart';
import '../../models/visit.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../visits_repository.dart';

/// In-memory fake implementation of [VisitsRepository] for unit tests.
class FakeVisitsRepository implements VisitsRepository {
  final List<Visit> _visits = [];
  bool shouldFail = false;

  FakeVisitsRepository({List<Visit>? initialVisits}) {
    if (initialVisits != null) {
      _visits.addAll(initialVisits);
    }
  }

  @override
  Future<Result<List<Visit>>> getVisits({String? profileName}) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to fetch visits'),
      );
    }
    var list = _visits.toList();
    if (profileName != null && profileName.isNotEmpty) {
      list = list
          .where(
            (v) => v.profileName.toLowerCase() == profileName.toLowerCase(),
          )
          .toList();
    }
    return Result.success(List.unmodifiable(list));
  }

  @override
  Future<Result<Visit>> addVisit(Visit visit) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to save visit'),
      );
    }
    final created = visit.id.isEmpty
        ? visit.copyWith(id: UuidGenerator.v4(), createdAt: DateTime.now())
        : visit;
    _visits.insert(0, created);
    return Result.success(created);
  }

  @override
  Future<Result<void>> deleteVisit(String visitId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to delete visit'),
      );
    }
    _visits.removeWhere((v) => v.id == visitId);
    return const Result.success(null);
  }
}
