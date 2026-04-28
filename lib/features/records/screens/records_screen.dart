import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../profile/controllers/profile_controller.dart';
import '../controllers/records_controller.dart';
import '../widgets/profile_selector.dart';
import '../widgets/record_card.dart';
import '../widgets/records_widgets.dart';
import 'add_record_screen.dart';

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
                          // Use the getter from the controller which is safer
                          record: _controller.recentRecord,
                        ),
                  const SizedBox(height: 25),
                  const Text(
                    "Previous Records",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  const SizedBox(height: 180),
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
              ProfileSelector(
                name: ProfileController().activeProfileName.split(" ")[0],
                familyNames: ProfileController().familyMembers
                    .map((e) => e['name'] as String)
                    .toList(),
                onSelected: (name) {
                  ProfileController().activeProfileName = name;
                  _controller.runFilter(_searchController.text);
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
  }

  Widget _buildRecordsGrid() {
    final records = _controller.filteredRecords;
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
      // Inside _buildRecordsGrid item builder
      itemBuilder: (context, index) {
        final record = records[index];
        return RecordCard(
          title: record["title"] ?? "Untitled",
          subtitle: record["sub"] ?? record["description"] ?? "No description",
          // Added required onTap
          onTap: () {
            // Placeholder: Navigate to record viewer in future
          },
          onDelete: () {
            _controller.deleteRecord(record, _searchController.text);
            setState(() {}); // Ensure UI refreshes after delete
          },
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
