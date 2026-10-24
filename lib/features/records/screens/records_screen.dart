import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/models/medical_record.dart';
import 'package:nuroved_patient/core/repositories/records_repository.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../profile/controllers/profile_controller.dart';
import '../controllers/records_controller.dart';
import '../widgets/profile_selector.dart';
import '../widgets/record_card.dart';
import '../widgets/records_widgets.dart';
import 'add_record_screen.dart';
import 'record_details_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final RecordsController _controller = RecordsController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.runFilter("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Recent Records",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // If there are no records yet, show a placeholder or hide the card
                  // If there are no records yet, show nothing (or a placeholder)
                  _controller.filteredRecords.isEmpty
                      ? const SizedBox()
                      : RecentRecordCard(
                          record: _controller.recentRecord,
                          onView: () {
                            if (_controller.recentRecord != null) {
                              _openRecordDetails(_controller.recentRecord);
                            }
                          },
                        ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Previous Records",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      PopupMenuButton<RecordSortOrder>(
                        icon: const Icon(
                          Icons.sort_rounded,
                          size: 20,
                          color: Color(0xFF2C4E4E),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (order) {
                          _controller.setSortOrder(order);
                          setState(() {});
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: RecordSortOrder.newestFirst,
                            child: Text('Newest First'),
                          ),
                          PopupMenuItem(
                            value: RecordSortOrder.oldestFirst,
                            child: Text('Oldest First'),
                          ),
                          PopupMenuItem(
                            value: RecordSortOrder.titleAsc,
                            child: Text('Title (A-Z)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RecordsSearchBar(
                    controller: _searchController,
                    onChanged: (v) {
                      _controller.runFilter(v);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFilterChips(),
                  const SizedBox(height: 20),
                  _buildRecordsGrid(),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    final profileController = ProfileController(); // Access the singleton

    return ListenableBuilder(
      listenable: profileController,
      builder: (context, _) {
        // 1. Find the currently active member's data
        final activeName = profileController.activeProfileName;
        final activeMember = profileController.familyMembers.firstWhere(
          (m) => m['name'] == activeName,
          orElse: () => profileController.userData,
        );

        return Container(
          padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
          decoration: const BoxDecoration(
            color: AppColors.kTopBg,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Records",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  // 2. Pass the dynamic name and imageFile
                  ProfileSelector(
                    name: activeName.split(" ")[0],
                    imageFile:
                        activeMember['imageFile'], // THIS REFLECTS THE PHOTO
                    familyNames: profileController.familyMembers
                        .map((e) => e['name'] as String)
                        .toList(),
                    onSelected: (name) {
                      profileController.switchSubjectByName(name);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const Text(
                "All Your And Your Families Health Record In One Place.",
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteRecord(dynamic record) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Medical Record?'),
        content: const Text(
          'Are you sure you want to delete this record? This action will remove it from your records list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _controller.deleteRecord(record, _searchController.text);
              setState(() {});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openRecordDetails(dynamic record) {
    final recordId = record is Map ? record['id']?.toString() : null;
    final fullRecord = _controller.records.firstWhere(
      (r) => r.id == recordId,
      orElse: () => MedicalRecord(
        id: recordId ?? '',
        profileName: record is Map ? (record['profile'] ?? '') : '',
        title: record is Map ? (record['title'] ?? 'Record') : 'Record',
        recordType: record is Map
            ? (record['type'] ?? 'Medical Record')
            : 'Medical Record',
        date: record is Map ? (record['date'] ?? '') : '',
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordDetailsScreen(record: fullRecord),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  Widget _buildRecordsGrid() {
    final records = _controller.filteredRecords;
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.folder_open_outlined, size: 45, color: Colors.grey[400]),
            const SizedBox(height: 10),
            const Text(
              "No medical records found for this profile",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
        childAspectRatio: 0.62,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return RecordCard(
          title: record["title"] ?? "Untitled",
          subtitle: record["sub"] ?? record["description"] ?? "No description",
          onTap: () => _openRecordDetails(record),
          onDelete: () => _confirmDeleteRecord(record),
        );
      },
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100, right: 10),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AddRecordScreen()),
        ),
        backgroundColor: AppColors.kPrimary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.note_add_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All", "Medical Records", "Vaccination's", "Bills", "Lab"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _controller.selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) {
                _controller.selectedFilter = f;
                _controller.runFilter(_searchController.text);
                setState(() {});
              },
              selectedColor: const Color(0xFF2C4E4E),
              backgroundColor: Colors.transparent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
