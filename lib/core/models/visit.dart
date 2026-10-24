import 'package:flutter/foundation.dart';
import '../utils/date_parser.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for clinical visits and doctor consultations.
@immutable
class Visit {
  final String id;
  final String userId;
  final String subjectId;
  final String profileName;
  final String date;
  final DateTime? visitDate;
  final String title;
  final String subtitle;
  final String? doctorName;
  final String? specialty;
  final String? hospitalName;
  final String? notes;
  final DateTime? followUpDate;
  final List<String>
  relatedRecordIds; // Canonical MedicalRecord IDs (never duplicates)
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Visit({
    required this.id,
    this.userId = '',
    this.subjectId = '',
    required this.profileName,
    required this.date,
    this.visitDate,
    required this.title,
    required this.subtitle,
    this.doctorName,
    this.specialty,
    this.hospitalName,
    this.notes,
    this.followUpDate,
    this.relatedRecordIds = const [],
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  DateTime get safeVisitDate {
    if (visitDate != null) return visitDate!;
    return DateParser.parse(date) ?? DateTime.now();
  }

  Visit copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? profileName,
    String? date,
    DateTime? visitDate,
    String? title,
    String? subtitle,
    String? doctorName,
    String? specialty,
    String? hospitalName,
    String? notes,
    DateTime? followUpDate,
    List<String>? relatedRecordIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Visit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      profileName: profileName ?? this.profileName,
      date: date ?? this.date,
      visitDate: visitDate ?? this.visitDate,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospitalName: hospitalName ?? this.hospitalName,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
      relatedRecordIds: relatedRecordIds ?? this.relatedRecordIds,
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
      'date': date,
      'visit_date': visitDate?.toIso8601String(),
      'title': title,
      'subtitle': subtitle,
      'doctor_name': doctorName,
      'specialty': specialty,
      'hospital_name': hospitalName,
      'notes': notes,
      'follow_up_date': followUpDate?.toIso8601String(),
      'related_record_ids': relatedRecordIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Visit.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    if (map['visit_date'] != null) {
      parsedDate = DateTime.tryParse(map['visit_date'].toString());
    } else if (map['date'] != null) {
      parsedDate = DateTime.tryParse(map['date'].toString());
    }

    final rawRelated =
        map['related_record_ids'] ??
        map['relatedRecords'] ??
        map['relatedRecordIds'];
    List<String> relatedList = [];
    if (rawRelated is List) {
      relatedList = rawRelated.map((e) => e.toString()).toList();
    } else if (map['relatedRecord'] != null &&
        map['relatedRecord'].toString().isNotEmpty) {
      relatedList = [map['relatedRecord'].toString()];
    }

    return Visit(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      userId: (map['user_id'] ?? map['userId'])?.toString() ?? '',
      subjectId:
          (map['subject_id'] ?? map['subjectId'] ?? map['family_member_id'])
              ?.toString() ??
          '',
      profileName:
          (map['profile'] ?? map['profile_name'])?.toString() ?? 'Self',
      date: map['date']?.toString() ?? '',
      visitDate: parsedDate,
      title: map['title']?.toString() ?? 'Consultation',
      subtitle: map['subtitle']?.toString() ?? '',
      doctorName: (map['doctor_name'] ?? map['doctor'])?.toString(),
      specialty: map['specialty']?.toString(),
      hospitalName: (map['hospital_name'] ?? map['hospital'])?.toString(),
      notes: (map['notes'] ?? map['description'])?.toString(),
      followUpDate: map['follow_up_date'] != null
          ? DateTime.tryParse(map['follow_up_date'].toString())
          : null,
      relatedRecordIds: relatedList,
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
      other is Visit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          date == other.date;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ date.hashCode;

  @override
  String toString() => 'Visit(id: $id, title: $title, date: $date)';
}
