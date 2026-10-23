import 'package:flutter/foundation.dart';
import '../utils/uuid_generator.dart';

/// Strongly-typed immutable domain model for Care Access Grants.
///
/// Models explicitly authorised caregiver/clinician relationships
/// with fine-grained resource scoping and temporal expiration.
@immutable
class CareAccessGrant {
  final String id;
  final String patientId;
  final String? granteeId;
  final String granteeEmail;
  final String granteeName;
  final String accessType; // 'view_only' | 'view_and_edit'
  final List<String> scopes; // 'full_profile', 'medical_records', 'health_timeline', 'medications'
  final String purpose;
  final String status; // 'pending' | 'active' | 'revoked' | 'expired'
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;

  const CareAccessGrant({
    required this.id,
    required this.patientId,
    this.granteeId,
    required this.granteeEmail,
    required this.granteeName,
    required this.accessType,
    required this.scopes,
    required this.purpose,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.revokedAt,
  });

  /// Factory creating an empty/default pending grant for initialization.
  factory CareAccessGrant.createPending({
    required String patientId,
    required String granteeEmail,
    required String granteeName,
    required List<String> scopes,
    String accessType = 'view_only',
    String purpose = 'Continuity of diabetes care',
    Duration duration = const Duration(days: 30),
  }) {
    final now = DateTime.now();
    return CareAccessGrant(
      id: UuidGenerator.v4(),
      patientId: patientId,
      granteeEmail: granteeEmail,
      granteeName: granteeName,
      accessType: accessType,
      scopes: List.unmodifiable(scopes),
      purpose: purpose,
      status: 'pending',
      createdAt: now,
      expiresAt: now.add(duration),
    );
  }

  /// Whether this grant is currently valid (active, not revoked, not expired).
  bool get isValid {
    if (status != 'active') return false;
    if (revokedAt != null) return false;
    if (DateTime.now().isAfter(expiresAt)) return false;
    return true;
  }

  /// Checks if a specific resource scope is authorized.
  bool hasScope(String scope) {
    if (!isValid) return false;
    if (scopes.contains('full_profile')) return true;
    return scopes.contains(scope);
  }

  /// Checks if edit access is permitted for this grant.
  bool canEdit() {
    return isValid && accessType == 'view_and_edit';
  }

  CareAccessGrant copyWith({
    String? id,
    String? patientId,
    String? granteeId,
    String? granteeEmail,
    String? granteeName,
    String? accessType,
    List<String>? scopes,
    String? purpose,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? revokedAt,
  }) {
    return CareAccessGrant(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      granteeId: granteeId ?? this.granteeId,
      granteeEmail: granteeEmail ?? this.granteeEmail,
      granteeName: granteeName ?? this.granteeName,
      accessType: accessType ?? this.accessType,
      scopes: scopes ?? this.scopes,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'grantee_id': granteeId,
      'grantee_email': granteeEmail,
      'grantee_name': granteeName,
      'access_type': accessType,
      'scopes': scopes,
      'purpose': purpose,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
    };
  }

  factory CareAccessGrant.fromMap(Map<String, dynamic> map) {
    final rawScopes = map['scopes'];
    final List<String> parsedScopes = rawScopes is List
        ? rawScopes.map((e) => e.toString()).toList()
        : const <String>[];

    return CareAccessGrant(
      id: map['id']?.toString() ?? UuidGenerator.v4(),
      patientId: map['patient_id']?.toString() ?? '',
      granteeId: map['grantee_id']?.toString(),
      granteeEmail: map['grantee_email']?.toString() ?? '',
      granteeName: map['grantee_name']?.toString() ?? '',
      accessType: map['access_type']?.toString() ?? 'view_only',
      scopes: parsedScopes,
      purpose: map['purpose']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: map['expires_at'] != null
          ? DateTime.tryParse(map['expires_at'].toString()) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      revokedAt: map['revoked_at'] != null
          ? DateTime.tryParse(map['revoked_at'].toString())
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareAccessGrant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          status == other.status &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => id.hashCode ^ patientId.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'CareAccessGrant(id: $id, grantee: $granteeName, status: $status)';
}
