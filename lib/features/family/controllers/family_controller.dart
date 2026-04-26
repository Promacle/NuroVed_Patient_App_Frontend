import '../../profile/controllers/profile_controller.dart';

class FamilyController {
  static final FamilyController _instance = FamilyController._internal();
  factory FamilyController() => _instance;
  FamilyController._internal();

  final ProfileController _profileController = ProfileController();

  List<Map<String, dynamic>> get familyMembers =>
      _profileController.familyMembers;

  void updateFamilyMember(int index, Map<String, dynamic> updatedData) {
    _profileController.updateFamilyMember(index, updatedData);
  }

  void addFamilyMember(Map<String, dynamic> data) {
    _profileController.addFamilyMember(data);
  }
}
