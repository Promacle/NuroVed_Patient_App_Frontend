import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final RoutineController _controller = RoutineController();
  final ProfileController _profileController = ProfileController();

  bool _isProfileExpanded = false;
  bool _isDetailsExpanded = false;
  bool _isTimeExpanded = true; // Keep time expanded by default as in photo
  // Added this variable

  String _selectedProfileName = "";
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  DateTime _selectedTime = DateTime(2024, 1, 1, 8, 0); // Default 8:00 AM

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileSelectionCard(),
                  const SizedBox(height: 15),
                  _buildMedicineDetailsCard(),
                  const SizedBox(height: 15),
                  _buildReminderTimeCard(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Medicines",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  "Add Your Medicine Reminder So You Dont Forget",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelectionCard() {
    final familyMembers = _profileController.familyMembers;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDEA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isProfileExpanded = !_isProfileExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.userIcon,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Profiles",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _selectedProfileName.isEmpty
                              ? "Select Profile In Which You Want To Save"
                              : "Selected: $_selectedProfileName",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isProfileExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.arrow_downward,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isProfileExpanded)
            Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  final member = familyMembers[index];
                  final isSelected = _selectedProfileName == member['name'];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedProfileName = member['name'];
                      _isProfileExpanded = false;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFADC8C0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryTeal
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.mintBackground,
                            child: Text(member['name'][0]),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            member['name'],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineDetailsCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDEA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isDetailsExpanded = !_isDetailsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.medicineIcon,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Medicine Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _medicineNameController.text.isEmpty
                              ? "Enter Your Medicine Details"
                              : "Name: ${_medicineNameController.text}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isDetailsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.arrow_downward,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isDetailsExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _medicineNameController,
                    hint: "Enter medicine name....",
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _instructionController,
                    hint: "Enter instructions (e.g. 1 tablet after meal)....",
                    maxLines: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildReminderTimeCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDEA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isTimeExpanded = !_isTimeExpanded),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reminder Time",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                      ),
                      Text(
                        "Select Time On Which You Want Remider",
                        style: TextStyle(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isTimeExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.arrow_downward,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isTimeExpanded) ...[
            const SizedBox(height: 25),
            // 12-Hour Time Picker with AM/PM
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false, // Enables AM/PM selection
                initialDateTime: _selectedTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() => _selectedTime = newDateTime);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedProfileName.isEmpty ||
              _medicineNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please select profile and enter medicine name"),
              ),
            );
            return;
          }

          // Logic to extract 12h time from DateTime
          final hours = _selectedTime.hour;
          final minutes = _selectedTime.minute;
          final amPm = hours >= 12 ? "PM" : "AM";
          final displayHour = hours == 0
              ? 12
              : (hours > 12 ? hours - 12 : hours);
          final timeStr =
              "${displayHour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $amPm";

          _controller.addMedicine(
            _medicineNameController.text,
            "1 tablet * $timeStr * ${_instructionController.text}",
          );

          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: const Text(
          "Save Reminder",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
