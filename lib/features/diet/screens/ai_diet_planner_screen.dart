import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';

import '../widgets/diet_planner_widgets.dart';

class AiDietPlannerScreen extends StatefulWidget {
  const AiDietPlannerScreen({super.key});

  @override
  State<AiDietPlannerScreen> createState() => _AiDietPlannerScreenState();
}

class _AiDietPlannerScreenState extends State<AiDietPlannerScreen> {
  final ProfileController _profileController = ProfileController();
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String _selectedGender = "Male";
  String? _selectedProfile;

  @override
  void initState() {
    super.initState();
    final userData = _profileController.userData;
    _ageController = TextEditingController(
      text: _profileController.calculateAge().split(" ")[0],
    );
    _weightController = TextEditingController(text: userData['weight'] ?? "70");
    _heightController = TextEditingController(
      text: userData['height'] ?? "175",
    );
    _selectedGender = userData['gender'] != null
        ? userData['gender']![0].toUpperCase() +
              userData['gender']!.substring(1)
        : "Male";
    _selectedProfile = userData['name'];
  }

  // Helper to calculate age from DOB string (DD/MM/YYYY)
  String _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return "25";
    try {
      List<String> parts = dob.split('/');
      if (parts.length != 3) return "25";
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
      return "$age";
    } catch (e) {
      return "25";
    }
  }

  // Logic to populate fields and navigate when a profile is selected
  void _onProfileSelected(Map<String, dynamic> member) {
    setState(() {
      _selectedProfile = member['name'];

      // Use the singleton userData for the main profile to get latest edits
      final data = member['isMain'] == true
          ? _profileController.userData
          : member;

      // Update text controllers with selected profile's data
      // We strip non-numeric characters (like " Kg" or " Cm") for the input fields
      _ageController.text = _calculateAge(data['dob']);
      _weightController.text =
          data['weight']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? "70";
      _heightController.text =
          data['height']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? "175";

      String gender = data['gender'] ?? "Male";
      if (gender.isNotEmpty) {
        _selectedGender =
            gender[0].toUpperCase() + gender.substring(1).toLowerCase();
      }
    });

    // Navigate to the next screen automatically
    Navigator.pushNamed(context, '/diet-preference');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          const DietPlannerHeader(
            title: "Ai Diet Planner",
            subtitle: "Calculate Your Every Single Bite",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildBasicInfoCard(),
                  const SizedBox(height: 25),
                  _buildProfileSelectionCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return DietPlannerCard(
      title: "Basic Information",
      icon: Icons.person,
      child: Column(
        children: [
          DietPlannerTextField(
            label: "Age",
            controller: _ageController,
            hint: "e.g., 25",
            keyboardType: TextInputType.number,
            onIncrement: () => setState(
              () => _ageController.text = (int.parse(_ageController.text) + 1)
                  .toString(),
            ),
            onDecrement: () => setState(
              () => _ageController.text = (int.parse(_ageController.text) - 1)
                  .toString(),
            ),
          ),
          const SizedBox(height: 15),
          _buildGenderField(),
          const SizedBox(height: 15),
          DietPlannerTextField(
            label: "Weight (Kg)",
            controller: _weightController,
            hint: "70",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          DietPlannerTextField(
            label: "Height (Cm)",
            controller: _heightController,
            hint: "175",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 30),
          DietPlannerActionButton(
            label: "Continue",
            onPressed: () => Navigator.pushNamed(context, '/diet-preference'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6A6A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              items: ["Male", "Female", "Other"]
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSelectionCard() {
    final family = _profileController.familyMembers;
    return DietPlannerCard(
      title: "Or Select Profile",
      icon: Icons.group,
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: family.length,
          itemBuilder: (context, index) {
            final member = family[index];
            final isSelected = _selectedProfile == member['name'];
            return GestureDetector(
              onTap: () => _onProfileSelected(
                member,
              ), // Updated to use the selection logic
              child: Container(
                width: 110,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF7CB9A8), width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFE1ECE7),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF7CB9A8),
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member['name'].split(" ")[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      member['relation'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
