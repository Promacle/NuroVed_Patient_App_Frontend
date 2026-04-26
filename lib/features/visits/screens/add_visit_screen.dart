import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/visits/screens/select_related_records.dart';

import '../controllers/visits_controller.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  bool _isProfileExpanded = false;
  bool _isDetailsExpanded = false;
  bool _isDateExpanded = false;

  String _selectedProfileName = "";
  String _selectedRecordTitle = "";
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _visitTitleController = TextEditingController();
  final TextEditingController _visitDescController = TextEditingController();

  String get _formattedDate =>
      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
  void _saveVisit() {
    if (_selectedProfileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile first")),
      );
      return;
    }
    if (_visitTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a visit title")),
      );
      return;
    }

    final newVisit = {
      "profile": _selectedProfileName,
      "date": _formatDateForTimeline(_selectedDate),
      "title": _visitTitleController.text,
      "subtitle": _visitDescController.text,
      "icon": Icons.local_hospital_rounded,
      "relatedRecord": _selectedRecordTitle,
    };

    VisitsController().addVisit(newVisit);
    ProfileController().activeProfileName = _selectedProfileName;
    Navigator.pop(context);
  }

  String _formatDateForTimeline(DateTime date) {
    const months = [
      "january",
      "february",
      "march",
      "april",
      "may",
      "june",
      "july",
      "august",
      "september",
      "october",
      "november",
      "december",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  _buildProfileSelectionCard(ProfileController().familyMembers),
                  const SizedBox(height: 15),
                  _buildVisitDetailsCard(),
                  const SizedBox(height: 15),
                  _buildDateSelectionCard(),
                  const SizedBox(height: 15),
                  _buildOptionCard(
                    title: "Attach Records",
                    subtitle: _selectedRecordTitle.isEmpty
                        ? "Select Record Related To Visit"
                        : "Selected: $_selectedRecordTitle",
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Colors.black,
                    isNext: true,
                    onTap: () async {
                      if (_selectedProfileName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a profile first"),
                          ),
                        );
                        return;
                      }
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectRelatedRecordsScreen(
                            profileName: _selectedProfileName,
                          ),
                        ),
                      );
                      if (result != null && result is String) {
                        setState(() => _selectedRecordTitle = result);
                      }
                    },
                  ),
                  const SizedBox(height: 100),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: AppColors.sageGreen),
            ),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Visit",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                  fontFamily: 'serif',
                ),
              ),
              Text(
                "Add Visit Details Below",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelectionCard(List<Map<String, dynamic>> familyMembers) {
    return _buildExpandableCard(
      isExpanded: _isProfileExpanded,
      onToggle: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
      iconAsset: AppAssets.userIcon,
      title: "Profiles",
      subtitle: _selectedProfileName.isEmpty
          ? "Select Profile"
          : "Selected: $_selectedProfileName",
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: familyMembers.length,
          itemBuilder: (context, index) {
            final member = familyMembers[index];
            final isSelected = _selectedProfileName == member['name'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedProfileName = member['name']),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE2EDEA) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTeal
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.mintBackground,
                      child: Text(
                        member['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      member['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      member['relation'],
                      style: const TextStyle(color: Colors.grey, fontSize: 9),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        _buildCollapseButton(() => setState(() => _isProfileExpanded = false)),
      ],
    );
  }

  Widget _buildVisitDetailsCard() {
    return _buildExpandableCard(
      isExpanded: _isDetailsExpanded,
      onToggle: () => setState(() => _isDetailsExpanded = !_isDetailsExpanded),
      iconAsset: AppAssets.medicineIcon,
      title: "Visit details",
      subtitle: _visitTitleController.text.isEmpty
          ? "Enter Your Recent Visit Details"
          : _visitTitleController.text,
      children: [
        _buildStyledTextField(
          controller: _visitTitleController,
          hint: "Enter visit title....",
        ),
        const SizedBox(height: 15),
        _buildStyledTextField(
          controller: _visitDescController,
          hint: "Enter visit description....",
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDateSelectionCard() {
    return _buildExpandableCard(
      isExpanded: _isDateExpanded,
      onToggle: () => setState(() => _isDateExpanded = !_isDateExpanded),
      iconData: Icons.calendar_month_rounded,
      title: "Date",
      subtitle: _isDateExpanded
          ? "Select Date On Which You Visit"
          : "Selected: $_formattedDate",
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryTeal,
              ),
            ),
            child: SizedBox(
              height: 280,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: (date) => setState(() {
                  _selectedDate = date;
                  _isDateExpanded = false;
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildExpandableCard({
    required bool isExpanded,
    required VoidCallback onToggle,
    String? iconAsset,
    IconData? iconData,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.navyGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: iconAsset != null
                        ? Image.asset(iconAsset)
                        : Icon(
                            iconData,
                            color: const Color(0xFF2C4E4E),
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isNext = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.navyGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isNext
                  ? Icons.arrow_forward_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
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

  Widget _buildCollapseButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Select Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _saveVisit, // Make sure this is linked to the method above

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Save Visit",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
