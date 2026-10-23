import 'package:flutter/foundation.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for patient profile.
@immutable
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String height;
  final String weight;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.bloodGroup,
    required this.allergies,
    required this.chronicConditions,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory creating an empty, unauthenticated patient profile.
  factory UserProfile.empty() {
    return UserProfile(
      id: UuidGenerator.v4(),
      name: 'Not provided',
      email: 'Not provided',
      phone: 'Not provided',
      dateOfBirth: 'Not provided',
      gender: 'Not provided',
      height: 'Not provided',
      weight: 'Not provided',
      bloodGroup: 'Not provided',
      allergies: const [],
      chronicConditions: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? height,
    String? weight,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dateOfBirth,
      'gender': gender,
      'height': height,
      'weight': weight,
      'blood': bloodGroup,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final rawAllergies = map['allergies'];
    final allergiesList = rawAllergies is List
        ? rawAllergies.map((e) => e.toString()).toList()
        : const <String>[];

    final rawConditions = map['chronicConditions'] ?? map['chronic_conditions'];
    final conditionsList = rawConditions is List
        ? rawConditions.map((e) => e.toString()).toList()
        : const <String>[];

    return UserProfile(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      name: map['name']?.toString() ?? 'Not provided',
      email: map['email']?.toString() ?? 'Not provided',
      phone: map['phone']?.toString() ?? 'Not provided',
      dateOfBirth: (map['dob'] ?? map['date_of_birth'])?.toString() ?? 'Not provided',
      gender: map['gender']?.toString() ?? 'Not provided',
      height: map['height']?.toString() ?? 'Not provided',
      weight: map['weight']?.toString() ?? 'Not provided',
      bloodGroup: (map['blood'] ?? map['blood_group'])?.toString() ?? 'Not provided',
      allergies: allergiesList,
      chronicConditions: conditionsList,
      photoUrl: map['photo_url']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          dateOfBirth == other.dateOfBirth;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;

  @override
  String toString() => 'UserProfile(id: $id, name: $name, email: $email)';
}
