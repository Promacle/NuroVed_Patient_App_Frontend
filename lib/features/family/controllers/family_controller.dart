import '../../../core/models/family_member.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../profile/controllers/profile_controller.dart';

/// Controller coordinating family profile operations against [ProfileController].
class FamilyController {
  static final FamilyController _instance = FamilyController._internal();
  factory FamilyController() => _instance;
  FamilyController._internal();

  final ProfileController _profileController = ProfileController();

  List<Map<String, dynamic>> get familyMembers =>
      _profileController.familyMembers;

  List<FamilyMember> get typedMembers => _profileController.familyMembersList;

  Future<Result<FamilyMember>> addFamilyMember(
    Map<String, dynamic> data,
  ) async {
    final member = FamilyMember(
      id: data['id']?.toString() ?? UuidGenerator.v4(),
      name: data['name']?.toString() ?? 'Unnamed',
      relation: data['relation']?.toString() ?? 'Relative',
      isMain: data['isMain'] == true,
      isEmergencyContact: data['is_emergency_contact'] == true,
      phone: data['phone']?.toString(),
      bloodGroup: data['blood']?.toString() ?? data['blood_group']?.toString(),
      photoUrl: data['photo_url']?.toString(),
    );
    return _profileController.addFamilyMember(member);
  }

  Future<Result<FamilyMember>> updateFamilyMember(
    dynamic idOrIndex,
    Map<String, dynamic> updatedData,
  ) async {
    String id = '';
    if (idOrIndex is int) {
      final members = _profileController.familyMembers;
      if (idOrIndex >= 0 && idOrIndex < members.length) {
        id = members[idOrIndex]['id']?.toString() ?? '';
      }
    } else {
      id = idOrIndex.toString();
    }

    final existing = _profileController.familyMembersList.firstWhere(
      (m) => m.id == id,
      orElse: () => FamilyMember(id: id, name: '', relation: ''),
    );

    final updated = existing.copyWith(
      name: updatedData['name']?.toString() ?? existing.name,
      relation: updatedData['relation']?.toString() ?? existing.relation,
      isEmergencyContact: updatedData['is_emergency_contact'] != null
          ? updatedData['is_emergency_contact'] == true
          : existing.isEmergencyContact,
      phone: updatedData['phone']?.toString() ?? existing.phone,
      bloodGroup:
          updatedData['blood']?.toString() ??
          updatedData['blood_group']?.toString() ??
          existing.bloodGroup,
    );

    return _profileController.updateFamilyMember(updated);
  }

  Future<Result<void>> removeFamilyMemberById(String id) async {
    return _profileController.removeFamilyMember(id);
  }

  /// Backward-compatible remove by index
  void removeFamilyMember(int index) {
    final members = _profileController.familyMembers;
    if (index >= 0 && index < members.length) {
      final id = members[index]['id']?.toString();
      if (id != null && id.isNotEmpty && members[index]['isMain'] != true) {
        _profileController.removeFamilyMember(id);
      }
    }
  }
}
