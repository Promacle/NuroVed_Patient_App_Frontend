import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.runFilter("");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
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
                      Text(
                        context.l10n.homeRecentRecords,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                          Text(
                            context.l10n.recordsPreviousRecords,
                            style: const TextStyle(
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
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: RecordSortOrder.newestFirst,
                                child: Text(context.l10n.recordsSortNewest),
                              ),
                              PopupMenuItem(
                                value: RecordSortOrder.oldestFirst,
                                child: Text(context.l10n.recordsSortOldest),
                              ),
                              PopupMenuItem(
                                value: RecordSortOrder.titleAsc,
                                child: Text(context.l10n.recordsSortTitle),
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
      },
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

        final topPad = MediaQuery.of(context).padding.top;
        return Container(
          padding: EdgeInsets.fromLTRB(25, topPad + 16, 25, 26),
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
                  Text(
                    context.l10n.navRecords,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  ProfileSelector(
                    name: activeName.split(" ")[0],
                    imageFile: activeMember['imageFile'],
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
              Text(
                context.l10n.recordsSubtitle,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
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
        title: Text(context.l10n.recordsDeleteDialogTitle),
        content: Text(context.l10n.recordsDeleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              context.l10n.commonCancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final id = record is Map ? record['id']?.toString() : null;
              if (id != null && id.isNotEmpty) {
                final result = await _controller.softDeleteRecord(id);
                if (mounted) {
                  result.when(
                    success: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.recordsDeletedSuccess),
                          backgroundColor: AppColors.primaryTeal,
                        ),
                      );
                      setState(() {});
                    },
                    failure: (f) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete record: ${f.message}',
                          ),
                          backgroundColor: Colors.red[700],
                        ),
                      );
                    },
                  );
                }
              }
            },
            child: Text(
              context.l10n.commonDelete,
              style: const TextStyle(color: Colors.white),
            ),
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
      final isSearching = _searchController.text.trim().isNotEmpty;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.folder_open_outlined,
                size: 36,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isSearching
                  ? "No records matching '${_searchController.text}'"
                  : context.l10n.recordsNoRecordsFound,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? "Check for typos or try clearing your search filter"
                  : context.l10n.recordsEmptyUploadPrompt,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 720
            ? 4
            : (constraints.maxWidth > 480 ? 3 : 2);
        final childAspectRatio = crossAxisCount == 2
            ? 0.84
            : (crossAxisCount == 3 ? 0.76 : 0.72);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return RecordCard(
              title: record["title"] ?? "Untitled",
              subtitle:
                  record["sub"] ?? record["description"] ?? "No description",
              onTap: () => _openRecordDetails(record),
              onDelete: () => _confirmDeleteRecord(record),
            );
          },
        );
      },
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100, right: 10),
      child: FloatingActionButton(
        heroTag: 'records_fab',
        tooltip: context.l10n.recordsAddRecordButton,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AddRecordScreen()),
        ),
        backgroundColor: AppColors.primaryTeal,
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

  String _getFilterLabel(String filter) {
    switch (filter) {
      case "All":
        return context.l10n.recordsFilterAll;
      case "Medical Records":
        return context.l10n.recordsFilterMedicalRecords;
      case "Vaccinations":
        return context.l10n.recordsFilterVaccinations;
      case "Bills":
        return context.l10n.recordsFilterBills;
      case "Lab":
        return context.l10n.recordsFilterLab;
      default:
        return filter;
    }
  }

  Widget _buildFilterChips() {
    final filters = ["All", "Medical Records", "Vaccinations", "Bills", "Lab"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _controller.selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getFilterLabel(f)),
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
