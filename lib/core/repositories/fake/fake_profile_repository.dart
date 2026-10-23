import '../../errors/failures.dart';
import '../../models/family_member.dart';
import '../../models/user_profile.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../profile_repository.dart';

/// In-memory fake implementation of [ProfileRepository] for unit tests.
class FakeProfileRepository implements ProfileRepository {
  UserProfile _profile;
  final List<FamilyMember> _familyMembers = [];
  bool shouldFail = false;

  FakeProfileRepository({UserProfile? initialProfile})
      : _profile = initialProfile ?? UserProfile.empty();

  @override
  Future<Result<UserProfile>> getProfile() async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to retrieve profile'));
    }
    return Result.success(_profile);
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to update profile'));
    }
    _profile = profile.copyWith(updatedAt: DateTime.now());
    return Result.success(_profile);
  }

  @override
  Future<Result<List<FamilyMember>>> getFamilyMembers() async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to retrieve family members'));
    }
    return Result.success(List.unmodifiable(_familyMembers));
  }

  @override
  Future<Result<FamilyMember>> addFamilyMember(FamilyMember member) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to add family member'));
    }
    final created = member.id.isEmpty
        ? member.copyWith(id: UuidGenerator.v4())
        : member;
    _familyMembers.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<void>> deleteFamilyMember(String memberId) async {
    if (shouldFail) {
      return const Result.failure(ServerFailure(message: 'Failed to delete family member'));
    }
    _familyMembers.removeWhere((m) => m.id == memberId);
    return const Result.success(null);
  }
}
