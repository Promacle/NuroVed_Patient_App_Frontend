import 'package:flutter/foundation.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for medical records and diagnostic files.
@immutable
class MedicalRecord {
  final String id;
  final String profileName;
  final String title;
  final String recordType;
  final String date;
  final String? doctorName;
  final String? hospitalName;
  final String? description;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final DateTime? createdAt;

  const MedicalRecord({
    required this.id,
    required this.profileName,
    required this.title,
    required this.recordType,
    required this.date,
    this.doctorName,
    this.hospitalName,
    this.description,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.createdAt,
  });

  MedicalRecord copyWith({
    String? id,
    String? profileName,
    String? title,
    String? recordType,
    String? date,
    String? doctorName,
    String? hospitalName,
    String? description,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    DateTime? createdAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      profileName: profileName ?? this.profileName,
      title: title ?? this.title,
      recordType: recordType ?? this.recordType,
      date: date ?? this.date,
      doctorName: doctorName ?? this.doctorName,
      hospitalName: hospitalName ?? this.hospitalName,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile': profileName,
      'title': title,
      'type': recordType,
      'date': date,
      'doctor': doctorName,
      'hospital': hospitalName,
      'description': description,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_size': fileSize,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      profileName:
          (map['profile'] ?? map['profile_name'])?.toString() ?? 'Self',
      title: map['title']?.toString() ?? 'Untitled Record',
      recordType: (map['type'] ?? map['record_type'])?.toString() ?? 'Other',
      date: map['date']?.toString() ?? '',
      doctorName: (map['doctor'] ?? map['doctor_name'])?.toString(),
      hospitalName: (map['hospital'] ?? map['hospital_name'])?.toString(),
      description: (map['description'] ?? map['sub'])?.toString(),
      fileName: (map['file_name'] ?? map['fileName'])?.toString(),
      fileUrl: (map['file_url'] ?? map['fileUrl'])?.toString(),
      fileSize: map['file_size'] is int ? map['file_size'] as int : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          date == other.date;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ date.hashCode;

  @override
  String toString() => 'MedicalRecord(id: $id, title: $title, date: $date)';
}
