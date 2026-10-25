import 'package:flutter/foundation.dart';
import '../utils/platform_file.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for family member.
@immutable
class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final bool isMain;
  final bool isEmergencyContact;
  final String? phone;
  final String? bloodGroup;
  final String? photoUrl;
  final AppPlatformFile? imageFile;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.isMain = false,
    this.isEmergencyContact = false,
    this.phone,
    this.bloodGroup,
    this.photoUrl,
    this.imageFile,
  });

  FamilyMember copyWith({
    String? id,
    String? name,
    String? relation,
    bool? isMain,
    bool? isEmergencyContact,
    String? phone,
    String? bloodGroup,
    String? photoUrl,
    AppPlatformFile? imageFile,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      isMain: isMain ?? this.isMain,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoUrl: photoUrl ?? this.photoUrl,
      imageFile: imageFile ?? this.imageFile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'isMain': isMain,
      'is_emergency_contact': isEmergencyContact,
      'phone': phone,
      'blood_group': bloodGroup,
      'photo_url': photoUrl,
      if (imageFile != null) 'imageFile': imageFile,
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      name: map['name']?.toString() ?? 'Not provided',
      relation: map['relation']?.toString() ?? 'Other',
      isMain: map['isMain'] == true,
      isEmergencyContact: map['is_emergency_contact'] == true,
      phone: map['phone']?.toString(),
      bloodGroup: (map['blood_group'] ?? map['blood'])?.toString(),
      photoUrl: map['photo_url']?.toString(),
      imageFile: map['imageFile'] is AppPlatformFile
          ? map['imageFile'] as AppPlatformFile
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMember &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          relation == other.relation;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ relation.hashCode;

  @override
  String toString() =>
      'FamilyMember(id: $id, name: $name, relation: $relation)';
}
