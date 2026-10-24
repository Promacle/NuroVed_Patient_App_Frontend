import 'package:flutter/foundation.dart';
import '../utils/date_parser.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for medical records and diagnostic files.
@immutable
class MedicalRecord {
  final String id;
  final String userId;
  final String subjectId;
  final String profileName;
  final String title;
  final String recordType;
  final String date;
  final String? doctorName;
  final String? hospitalName;
  final String? description;
  final String? storagePath;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final String?
  fileUrl; // Cached short-lived signed URL (never a public URL or local path)
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const MedicalRecord({
    required this.id,
    this.userId = '',
    this.subjectId = '',
    required this.profileName,
    required this.title,
    required this.recordType,
    required this.date,
    this.doctorName,
    this.hospitalName,
    this.description,
    this.storagePath,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  DateTime get safeRecordDate {
    return DateParser.parse(date) ?? createdAt ?? DateTime.now();
  }

  MedicalRecord copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? profileName,
    String? title,
    String? recordType,
    String? date,
    String? doctorName,
    String? hospitalName,
    String? description,
    String? storagePath,
    String? fileName,
    String? mimeType,
    int? fileSize,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      profileName: profileName ?? this.profileName,
      title: title ?? this.title,
      recordType: recordType ?? this.recordType,
      date: date ?? this.date,
      doctorName: doctorName ?? this.doctorName,
      hospitalName: hospitalName ?? this.hospitalName,
      description: description ?? this.description,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'profile': profileName,
      'title': title,
      'type': recordType,
      'date': date,
      'doctor': doctorName,
      'hospital': hospitalName,
      'description': description,
      'storage_path': storagePath,
      'file_name': fileName,
      'mime_type': mimeType,
      'file_size': fileSize,
      'file_url': fileUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      userId: (map['user_id'] ?? map['userId'])?.toString() ?? '',
      subjectId:
          (map['subject_id'] ?? map['subjectId'] ?? map['family_member_id'])
              ?.toString() ??
          '',
      profileName:
          (map['profile'] ?? map['profile_name'])?.toString() ?? 'Self',
      title: map['title']?.toString() ?? 'Untitled Record',
      recordType: (map['type'] ?? map['record_type'])?.toString() ?? 'Other',
      date: map['date']?.toString() ?? '',
      doctorName: (map['doctor'] ?? map['doctor_name'])?.toString(),
      hospitalName: (map['hospital'] ?? map['hospital_name'])?.toString(),
      description: (map['description'] ?? map['sub'])?.toString(),
      storagePath: (map['storage_path'] ?? map['storagePath'])?.toString(),
      fileName: (map['file_name'] ?? map['fileName'])?.toString(),
      mimeType: (map['mime_type'] ?? map['mimeType'])?.toString(),
      fileSize: map['file_size'] is int
          ? map['file_size'] as int
          : (map['fileSize'] is int ? map['fileSize'] as int : null),
      fileUrl: (map['file_url'] ?? map['fileUrl'])?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'].toString())
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
  String toString() =>
      'MedicalRecord(id: $id, title: $title, date: $date, path: $storagePath)';
}
