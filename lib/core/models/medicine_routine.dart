import 'package:flutter/foundation.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for medication schedule and routines.
@immutable
class MedicineRoutine {
  final String id;
  final String profileName;
  final String medicineName;
  final String instruction;
  final bool isCompleted;
  final String? time;
  final String? dosage;

  const MedicineRoutine({
    required this.id,
    required this.profileName,
    required this.medicineName,
    required this.instruction,
    this.isCompleted = false,
    this.time,
    this.dosage,
  });

  MedicineRoutine copyWith({
    String? id,
    String? profileName,
    String? medicineName,
    String? instruction,
    bool? isCompleted,
    String? time,
    String? dosage,
  }) {
    return MedicineRoutine(
      id: id ?? this.id,
      profileName: profileName ?? this.profileName,
      medicineName: medicineName ?? this.medicineName,
      instruction: instruction ?? this.instruction,
      isCompleted: isCompleted ?? this.isCompleted,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile': profileName,
      'name': medicineName,
      'instruction': instruction,
      'isCompleted': isCompleted,
      'time': time,
      'dosage': dosage,
    };
  }

  factory MedicineRoutine.fromMap(Map<String, dynamic> map) {
    return MedicineRoutine(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      profileName: (map['profile'] ?? map['profile_name'])?.toString() ?? 'Self',
      medicineName: (map['name'] ?? map['medicine_name'])?.toString() ?? 'Medicine',
      instruction: map['instruction']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      time: map['time']?.toString(),
      dosage: map['dosage']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRoutine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          medicineName == other.medicineName &&
          instruction == other.instruction &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => id.hashCode ^ medicineName.hashCode ^ isCompleted.hashCode;

  @override
  String toString() => 'MedicineRoutine(id: $id, name: $medicineName, isCompleted: $isCompleted)';
}
