import '../models/medicine_routine.dart';
import '../utils/result.dart';

abstract class RoutineRepository {
  Future<Result<List<MedicineRoutine>>> getRoutines({String? profileName});

  Future<Result<MedicineRoutine>> addRoutine(MedicineRoutine routine);

  Future<Result<MedicineRoutine>> toggleRoutine(String routineId, bool isCompleted);

  Future<Result<void>> deleteRoutine(String routineId);
}
