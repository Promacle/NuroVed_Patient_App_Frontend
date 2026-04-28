import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';

class SelectRelatedRecordsScreen extends StatefulWidget {
  final String profileName;
  const SelectRelatedRecordsScreen({super.key, required this.profileName});

  @override
  State<SelectRelatedRecordsScreen> createState() =>
      _SelectRelatedRecordsScreenState();
}

class _SelectRelatedRecordsScreenState
    extends State<SelectRelatedRecordsScreen> {
  int _selectedIndex = -1;
  List<dynamic> _profileRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    final members = ProfileController().familyMembers;
    final member = members.firstWhere(
      (m) => m['name'] == widget.profileName,
      orElse: () => {},
    );
    if (member.isNotEmpty && member['records'] != null) {
      _profileRecords = member['records'] as List<dynamic>;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _profileRecords.isEmpty
                ? _buildEmptyState()
                : _buildRecordsGrid(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildRecordsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 15,
        childAspectRatio: 0.65,
      ),
      itemCount: _profileRecords.length,
      itemBuilder: (context, index) {
        final record = _profileRecords[index];
        final isSelected = _selectedIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.navyGreen,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 6), // 3D Effect
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3D7E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(AppAssets.docIcon, height: 24, width: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  record['title'] ?? "Untitled",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF2C4E4E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  record['type'] ?? "Medical Record",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 8, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                SizedBox(
                  height: 24,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageGreen,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "View",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "No Records Found For ${widget.profileName}",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                "Select A Visit Related Records",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _selectedIndex == -1
              ? null
              : () => Navigator.pop(
                  context,
                  _profileRecords[_selectedIndex]['title'],
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Select Related Record",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
