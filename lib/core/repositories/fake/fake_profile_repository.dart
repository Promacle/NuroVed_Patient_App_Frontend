import '../../errors/failures.dart';
import '../../models/care_access_grant.dart';
import '../../models/family_member.dart';
import '../../models/user_profile.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../profile_repository.dart';

/// In-memory fake implementation of [ProfileRepository] for unit tests.
class FakeProfileRepository implements ProfileRepository {
  UserProfile _profile;
  final List<FamilyMember> _familyMembers = [];
  CareAccessGrant? _caregiverGrant;
  bool shouldFail = false;

  FakeProfileRepository({
    UserProfile? initialProfile,
    List<FamilyMember>? initialFamily,
    CareAccessGrant? initialCaregiver,
  })  : _profile = initialProfile ?? UserProfile.empty() {
    if (initialFamily != null) {
      _familyMembers.addAll(initialFamily);
    }
    _caregiverGrant = initialCaregiver;
  }

  @override
  Future<Result<UserProfile>> getProfile() async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to retrieve profile'),
      );
    }
    return Result.success(_profile);
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to update profile'),
      );
    }
    _profile = profile.copyWith(updatedAt: DateTime.now());
    return Result.success(_profile);
  }

  @override
  Future<Result<List<FamilyMember>>> getFamilyMembers() async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to retrieve family members'),
      );
    }
    return Result.success(List.unmodifiable(_familyMembers));
  }

  @override
  Future<Result<FamilyMember>> addFamilyMember(FamilyMember member) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to add family member'),
      );
    }
    final created = member.id.isEmpty
        ? member.copyWith(id: UuidGenerator.v4())
        : member;
    _familyMembers.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<FamilyMember>> updateFamilyMember(FamilyMember member) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to update family member'),
      );
    }
    final index = _familyMembers.indexWhere((m) => m.id == member.id);
    if (index == -1) {
      return const Result.failure(
        NotFoundFailure(message: 'Family member not found'),
      );
    }
    _familyMembers[index] = member;
    return Result.success(member);
  }

  @override
  Future<Result<void>> deleteFamilyMember(String memberId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to delete family member'),
      );
    }
    _familyMembers.removeWhere((m) => m.id == memberId);
    return const Result.success(null);
  }

  @override
  Future<Result<CareAccessGrant?>> getCaregiverGrant() async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to retrieve caregiver grant'),
      );
    }
    return Result.success(_caregiverGrant);
  }

  @override
  Future<Result<CareAccessGrant>> inviteCaregiver({
    required String email,
    required String name,
    required List<String> scopes,
    String accessType = 'view_only',
    String purpose = 'Continuity of diabetes care',
    Duration duration = const Duration(days: 30),
  }) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to invite caregiver'),
      );
    }
    final grant = CareAccessGrant.createPending(
      patientId: _profile.id,
      granteeEmail: email,
      granteeName: name,
      scopes: scopes,
      accessType: accessType,
      purpose: purpose,
      duration: duration,
    );
    _caregiverGrant = grant;
    return Result.success(grant);
  }

  @override
  Future<Result<CareAccessGrant>> acceptCaregiverInvite(String grantId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to accept caregiver invite'),
      );
    }
    if (_caregiverGrant == null || _caregiverGrant!.id != grantId) {
      return const Result.failure(
        NotFoundFailure(message: 'Caregiver grant not found'),
      );
    }
    final accepted = _caregiverGrant!.copyWith(status: 'active');
    _caregiverGrant = accepted;
    return Result.success(accepted);
  }

  @override
  Future<Result<CareAccessGrant>> updateCaregiverScopes(
    String grantId,
    List<String> scopes,
  ) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to update caregiver scopes'),
      );
    }
    if (_caregiverGrant == null || _caregiverGrant!.id != grantId) {
      return const Result.failure(
        NotFoundFailure(message: 'Caregiver grant not found'),
      );
    }
    final updated = _caregiverGrant!.copyWith(scopes: List.unmodifiable(scopes));
    _caregiverGrant = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<void>> revokeCaregiver(String grantId) async {
    if (shouldFail) {
      return const Result.failure(
        ServerFailure(message: 'Failed to revoke caregiver'),
      );
    }
    if (_caregiverGrant == null || _caregiverGrant!.id != grantId) {
      return const Result.failure(
        NotFoundFailure(message: 'Caregiver grant not found'),
      );
    }
    _caregiverGrant = _caregiverGrant!.copyWith(
      status: 'revoked',
      revokedAt: DateTime.now(),
    );
    return const Result.success(null);
  }
}

