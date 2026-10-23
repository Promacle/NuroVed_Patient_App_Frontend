import '../models/family_member.dart';
import '../models/user_profile.dart';

abstract class ProfileDataSource {
  Future<UserProfile> fetchProfile();
  Future<UserProfile> saveProfile(UserProfile profile);
  Future<List<FamilyMember>> fetchFamilyMembers();
  Future<FamilyMember> insertFamilyMember(FamilyMember member);
  Future<void> removeFamilyMember(String memberId);
}
