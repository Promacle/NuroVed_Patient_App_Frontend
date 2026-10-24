import 'package:flutter/foundation.dart';
import '../utils/uuid_generator.dart';

/// Indicates whether a medication routine was entered directly by the patient
/// or was verified through an authorized clinical prescription.
enum RoutineSource {
  selfEntered,
  verifiedPrescription,
}

/// Strongly-typed immutable domain model for medication schedule and routines.
@immutable
class MedicineRoutine {
  final String id;
  final String subjectId;
  final String profileName;
  final String medicineName;
  final String instruction;
  final bool isCompleted;
  final String? time;
  final String? dosage;
  final RoutineSource source;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  const MedicineRoutine({
    required this.id,
    this.subjectId = '',
    required this.profileName,
    required this.medicineName,
    required this.instruction,
    this.isCompleted = false,
    this.time,
    this.dosage,
    this.source = RoutineSource.selfEntered,
    this.createdAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  String get sourceDisplayName {
    switch (source) {
      case RoutineSource.verifiedPrescription:
        return 'Verified Prescription';
      case RoutineSource.selfEntered:
        return 'Self-Entered';
    }
  }

  MedicineRoutine copyWith({
    String? id,
    String? subjectId,
    String? profileName,
    String? medicineName,
    String? instruction,
    bool? isCompleted,
    String? time,
    String? dosage,
    RoutineSource? source,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return MedicineRoutine(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      profileName: profileName ?? this.profileName,
      medicineName: medicineName ?? this.medicineName,
      instruction: instruction ?? this.instruction,
      isCompleted: isCompleted ?? this.isCompleted,
      time: time ?? this.time,
      dosage: dosage ?? this.dosage,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'profile': profileName,
      'name': medicineName,
      'medicine_name': medicineName,
      'instruction': instruction,
      'isCompleted': isCompleted,
      'time': time,
      'dosage': dosage,
      'source': source.name,
      'source_display': sourceDisplayName,
      'created_at': createdAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory MedicineRoutine.fromMap(Map<String, dynamic> map) {
    RoutineSource parsedSource = RoutineSource.selfEntered;
    final rawSource = map['source']?.toString().toLowerCase();
    if (rawSource == 'verifiedprescription' ||
        rawSource == 'verified_prescription' ||
        rawSource == 'prescription') {
      parsedSource = RoutineSource.verifiedPrescription;
    }

    return MedicineRoutine(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      subjectId: (map['subject_id'] ?? map['subjectId'])?.toString() ?? '',
      profileName:
          (map['profile'] ?? map['profile_name'])?.toString() ?? 'Self',
      medicineName:
          (map['name'] ?? map['medicine_name'])?.toString() ?? 'Medicine',
      instruction: map['instruction']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      time: map['time']?.toString(),
      dosage: map['dosage']?.toString(),
      source: parsedSource,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'].toString())
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRoutine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subjectId == other.subjectId &&
          medicineName == other.medicineName &&
          instruction == other.instruction &&
          isCompleted == other.isCompleted &&
          source == other.source &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      subjectId.hashCode ^
      medicineName.hashCode ^
      instruction.hashCode ^
      isCompleted.hashCode ^
      source.hashCode ^
      deletedAt.hashCode;

  @override
  String toString() =>
      'MedicineRoutine(id: $id, subjectId: $subjectId, name: $medicineName, source: ${source.name}, isCompleted: $isCompleted)';
}
