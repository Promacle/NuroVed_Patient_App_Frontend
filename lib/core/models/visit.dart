import 'package:flutter/foundation.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for clinical visits and doctor consultations.
@immutable
class Visit {
  final String id;
  final String profileName;
  final String date;
  final String title;
  final String subtitle;
  final String? doctorName;
  final String? specialty;
  final String? hospitalName;
  final DateTime? createdAt;

  const Visit({
    required this.id,
    required this.profileName,
    required this.date,
    required this.title,
    required this.subtitle,
    this.doctorName,
    this.specialty,
    this.hospitalName,
    this.createdAt,
  });

  Visit copyWith({
    String? id,
    String? profileName,
    String? date,
    String? title,
    String? subtitle,
    String? doctorName,
    String? specialty,
    String? hospitalName,
    DateTime? createdAt,
  }) {
    return Visit(
      id: id ?? this.id,
      profileName: profileName ?? this.profileName,
      date: date ?? this.date,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospitalName: hospitalName ?? this.hospitalName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile': profileName,
      'date': date,
      'title': title,
      'subtitle': subtitle,
      'doctor_name': doctorName,
      'specialty': specialty,
      'hospital_name': hospitalName,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      profileName: (map['profile'] ?? map['profile_name'])?.toString() ?? 'Self',
      date: map['date']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Consultation',
      subtitle: map['subtitle']?.toString() ?? '',
      doctorName: (map['doctor_name'] ?? map['doctor'])?.toString(),
      specialty: map['specialty']?.toString(),
      hospitalName: (map['hospital_name'] ?? map['hospital'])?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
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
