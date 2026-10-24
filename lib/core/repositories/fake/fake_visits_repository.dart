import '../../errors/failures.dart';
import '../../models/medical_record.dart';
import '../../models/visit.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../records_repository.dart';
import '../visits_repository.dart';

/// In-memory fake implementation of [VisitsRepository] for unit tests.
class FakeVisitsRepository implements VisitsRepository {
  final List<Visit> _visits = [];
  final RecordsRepository? _recordsRepository;
  bool shouldFail = false;

  FakeVisitsRepository({
    List<Visit>? initialVisits,
    RecordsRepository? recordsRepository,
  }) : _recordsRepository = recordsRepository {
    if (initialVisits != null) {
      _visits.addAll(initialVisits);
    }
  }

  List<Visit> get internalVisits => List.unmodifiable(_visits);

  @override
  Future<Result<List<Visit>>> getVisits({
    String? subjectId,
    String? profileName,
    VisitSortOrder sortOrder = VisitSortOrder.newestFirst,
  }) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to fetch visits'),
      );
    }

    var list = _visits.where((v) => !v.isDeleted).toList();

    if (subjectId != null && subjectId.isNotEmpty) {
      list = list.where((v) => v.subjectId == subjectId).toList();
    } else if (profileName != null && profileName.isNotEmpty) {
      list = list
          .where(
            (v) => v.profileName.toLowerCase() == profileName.toLowerCase(),
          )
          .toList();
    }

    switch (sortOrder) {
      case VisitSortOrder.newestFirst:
        list.sort((a, b) => b.safeVisitDate.compareTo(a.safeVisitDate));
        break;
      case VisitSortOrder.oldestFirst:
        list.sort((a, b) => a.safeVisitDate.compareTo(b.safeVisitDate));
        break;
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

    // Canonical link deduplication: ensure no duplicate record IDs in relatedRecordIds
    final dedupedRelated = visit.relatedRecordIds.toSet().toList();
    final created = visit.id.isEmpty
        ? visit.copyWith(
            id: UuidGenerator.v4(),
            createdAt: DateTime.now(),
            relatedRecordIds: dedupedRelated,
          )
        : (visit.createdAt == null
              ? visit.copyWith(
                  createdAt: DateTime.now(),
                  relatedRecordIds: dedupedRelated,
                )
              : visit.copyWith(relatedRecordIds: dedupedRelated));

    _visits.insert(0, created);
    return Result.success(created);
  }

  @override
  Future<Result<Visit>> updateVisit(Visit visit) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to update visit'),
      );
    }

    final index = _visits.indexWhere((v) => v.id == visit.id);
    if (index == -1) {
      return const Result.failure(ServerFailure(message: 'Visit not found'));
    }

    final dedupedRelated = visit.relatedRecordIds.toSet().toList();
    final updated = visit.copyWith(
      relatedRecordIds: dedupedRelated,
      updatedAt: DateTime.now(),
    );
    _visits[index] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<void>> deleteVisit(String visitId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to delete visit'),
      );
    }

    // Soft delete: sets deletedAt
    final index = _visits.indexWhere((v) => v.id == visitId);
    if (index != -1) {
      _visits[index] = _visits[index].copyWith(deletedAt: DateTime.now());
    }
    return const Result.success(null);
  }

  @override
  Future<Result<List<MedicalRecord>>> getRelatedRecords(String visitId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to fetch related records for visit'),
      );
    }

    final visit = _visits
        .where((v) => v.id == visitId && !v.isDeleted)
        .firstOrNull;
    if (visit == null) {
      return const Result.failure(
        ServerFailure(message: 'Visit not found or has been deleted'),
      );
    }

    if (visit.relatedRecordIds.isEmpty) {
      return const Result.success([]);
    }

    if (_recordsRepository != null) {
      final allRecordsResult = await _recordsRepository.getRecords(
        subjectId: visit.subjectId.isNotEmpty ? visit.subjectId : null,
      );
      if (allRecordsResult.isSuccess) {
        final allRecords = allRecordsResult.dataOrNull ?? [];
        final matched = allRecords
            .where((r) => visit.relatedRecordIds.contains(r.id))
            .toList();
        return Result.success(matched);
      }
    }

    return const Result.success([]);
  }
}
