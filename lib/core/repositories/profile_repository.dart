import '../models/care_access_grant.dart';
import '../models/family_member.dart';
import '../models/user_profile.dart';
import '../utils/result.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  Future<Result<List<FamilyMember>>> getFamilyMembers();

  Future<Result<FamilyMember>> addFamilyMember(FamilyMember member);

  Future<Result<FamilyMember>> updateFamilyMember(FamilyMember member);

  Future<Result<void>> deleteFamilyMember(String memberId);

  /// Caregiver relationship (one explicitly authorised caregiver)
  Future<Result<CareAccessGrant?>> getCaregiverGrant();

  Future<Result<CareAccessGrant>> inviteCaregiver({
    required String email,
    required String name,
    required List<String> scopes,
    String accessType = 'view_only',
    String purpose = 'Continuity of diabetes care',
    Duration duration = const Duration(days: 30),
  });

  Future<Result<CareAccessGrant>> acceptCaregiverInvite(String grantId);

  Future<Result<CareAccessGrant>> updateCaregiverScopes(
    String grantId,
    List<String> scopes,
  );

  Future<Result<void>> revokeCaregiver(String grantId);
}
