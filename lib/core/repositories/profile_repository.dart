import '../models/family_member.dart';
import '../models/user_profile.dart';
import '../utils/result.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  Future<Result<List<FamilyMember>>> getFamilyMembers();

  Future<Result<FamilyMember>> addFamilyMember(FamilyMember member);

  Future<Result<void>> deleteFamilyMember(String memberId);
}
