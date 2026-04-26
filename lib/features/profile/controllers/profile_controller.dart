import 'package:flutter/material.dart';

import '../screens/edit_profile_screen.dart';

class ProfileController {
  // 1. CREATE THE SINGLETON
  static final ProfileController _instance = ProfileController._internal();

  factory ProfileController() {
    return _instance;
  }

  ProfileController._internal() {
    // Initialize the family list with the main user data
    _familyList = [
      {'name': userData['name'], 'relation': "Self", 'isMain': true},
      {'name': "Umar chk", 'relation': "Friend", 'isMain': false},
      {'name': "Sara Malek", 'relation': "Wife", 'isMain': false},
    ];
  }

  // 2. THE DATA
  Map<String, dynamic> userData = {
    'name': "Fazilkhan Malek",
    'email': "malekfazilkhan@gmail.com",
    'phone': "+91 98765 43210",
    'dob': "02/05/2007",
    'height': "175",
    'weight': "95",
    'gender': "male",
    'blood': "B+",
    'imageFile': null,
    'allergies': ["Penicillin"],
    'chronicConditions': ["Mild Asthma"],
  };

  // 3. DYNAMIC FAMILY LIST LOGIC
  // This is the private list that holds the actual data
  late List<Map<String, dynamic>> _familyList;

  // This is the single public getter that other screens will use
  List<Map<String, dynamic>> get familyMembers {
    // Keep the main user's name in sync with any profile edits
    if (_familyList.isNotEmpty) {
      _familyList[0]['name'] = userData['name'];
    }
    return _familyList;
  }

  void addFamilyMember(Map<String, dynamic> data) {
    _familyList.add({...data, 'isMain': false});
  }

  void removeFamilyMember(int index) {
    if (index < _familyList.length && !_familyList[index]['isMain']) {
      _familyList.removeAt(index);
    }
  }

  String activeProfileName = "Fazilkhan Malek";

  // 4. NAVIGATION & EDIT LOGIC
  Future<void> navigateToEdit(
    BuildContext context,
    VoidCallback onUpdate,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfileScreen(initialData: Map.from(userData)),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      // If the main profile was selected in Records, update the active name
      if (activeProfileName == userData['name']) {
        activeProfileName = result['name'];
      }

      userData = result;
      onUpdate(); // Triggers the setState in ProfileScreen
    }
  }

  void logout() {
    debugPrint("User logged out");
  }

  String calculateAge() {
    try {
      String dobStr = userData['dob'] ?? "";
      if (dobStr.isEmpty) return "N/A";

      List<String> parts = dobStr.split('/');
      if (parts.length != 3) return "N/A";

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime birthDate = DateTime(year, month, day);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return "$age years";
    } catch (e) {
      return "N/A";
    }
  }

  void addRecordToProfile(String name, Map<String, dynamic> record) {
    // Find the index of the family member
    final index = _familyList.indexWhere((m) => m['name'] == name);

    if (index != -1) {
      // Ensure the member has a 'records' list initialized inside the _familyList
      if (_familyList[index]['records'] == null) {
        _familyList[index]['records'] = [];
      }

      // Add the new record to the specific profile
      (_familyList[index]['records'] as List).add(record);

      debugPrint(
        "Record added to $name. Total records: ${_familyList[index]['records'].length}",
      );
    }
  }

  void updateFamilyMember(int index, Map<String, dynamic> updatedData) {
    if (index >= 0 && index < _familyList.length) {
      // We merge the updated data with the existing member data
      _familyList[index] = {..._familyList[index], ...updatedData};
    }
  }
}
