import '../../errors/failures.dart';
import '../../models/medicine_routine.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../routine_repository.dart';

/// In-memory fake implementation of [RoutineRepository] for unit tests.
class FakeRoutineRepository implements RoutineRepository {
  final List<MedicineRoutine> _routines = [];
  bool shouldFail = false;

  FakeRoutineRepository({List<MedicineRoutine>? initialRoutines}) {
    if (initialRoutines != null) {
      _routines.addAll(initialRoutines);
    }
  }

  @override
  Future<Result<List<MedicineRoutine>>> getRoutines({String? profileName}) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to fetch medication routines'));
    }
    var list = _routines.toList();
    if (profileName != null && profileName.isNotEmpty) {
      list = list.where((r) => r.profileName.toLowerCase() == profileName.toLowerCase()).toList();
    }
    return Result.success(List.unmodifiable(list));
  }

  @override
  Future<Result<MedicineRoutine>> addRoutine(MedicineRoutine routine) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to add medication routine'));
    }
    final created = routine.id.isEmpty
        ? routine.copyWith(id: UuidGenerator.v4())
        : routine;
    _routines.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<MedicineRoutine>> toggleRoutine(String routineId, bool isCompleted) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to update routine'));
    }
    final index = _routines.indexWhere((r) => r.id == routineId);
    if (index == -1) {
      return const Result.failure(NotFoundFailure(message: 'Routine not found'));
    }
    final updated = _routines[index].copyWith(isCompleted: isCompleted);
    _routines[index] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<void>> deleteRoutine(String routineId) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to delete routine'));
    }
    _routines.removeWhere((r) => r.id == routineId);
    return const Result.success(null);
  }
}
