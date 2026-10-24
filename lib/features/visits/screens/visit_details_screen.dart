import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/models/medical_record.dart';
import 'package:nuroved_patient/core/models/visit.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/utils/date_parser.dart';
import 'package:nuroved_patient/features/records/screens/record_details_screen.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';

class VisitDetailsScreen extends StatefulWidget {
  final Visit? visit;
  final String? visitId;

  const VisitDetailsScreen({
    super.key,
    this.visit,
    this.visitId,
  });

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  late Visit _visit;
  List<MedicalRecord> _relatedRecords = [];
  bool _isLoadingRecords = true;

  @override
  void initState() {
    super.initState();
    final visitsCtrl = VisitsController.instance;
    if (widget.visit != null) {
      _visit = widget.visit!;
    } else if (widget.visitId != null) {
      _visit = visitsCtrl.visits.firstWhere(
        (v) => v.id == widget.visitId,
        orElse: () => Visit(
          id: widget.visitId!,
          profileName: 'Patient',
          date: '',
          title: 'Visit Details',
          subtitle: '',
        ),
      );
    } else {
      _visit = const Visit(
        id: '',
        profileName: 'Patient',
        date: '',
        title: 'Visit Details',
        subtitle: '',
      );
    }
    _loadRelatedRecords();
  }

  Future<void> _loadRelatedRecords() async {
    setState(() => _isLoadingRecords = true);
    final records = await VisitsController.instance.getRelatedRecords(_visit.id);
    if (mounted) {
      setState(() {
        _relatedRecords = records;
        _isLoadingRecords = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Visit?'),
        content: const Text(
          'Are you sure you want to delete this consultation visit? This will remove it from your timeline.',
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
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final result = await VisitsController.instance.deleteVisit(_visit.id);
              if (mounted) {
                result.when(
                  success: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Visit deleted successfully')),
                    );
                    Navigator.pop(context);
                  },
                  failure: (f) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete visit: ${f.message}')),
                    );
                  },
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: _visit.title);
    final doctorController = TextEditingController(text: _visit.doctorName ?? '');
    final hospitalController = TextEditingController(text: _visit.hospitalName ?? '');
    final notesController = TextEditingController(text: _visit.notes ?? _visit.subtitle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Visit Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title / Purpose'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: hospitalController,
                decoration: const InputDecoration(labelText: 'Hospital / Clinic'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Clinical Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final updated = _visit.copyWith(
                title: titleController.text.trim(),
                doctorName: doctorController.text.trim(),
                hospitalName: hospitalController.text.trim(),
                notes: notesController.text.trim(),
                subtitle: notesController.text.trim(),
              );
              Navigator.pop(ctx);
              final result = await VisitsController.instance.updateVisit(updated);
              if (mounted && result.isSuccess) {
                setState(() => _visit = updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visit updated successfully')),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainCard(),
                  const SizedBox(height: 20),
                  _buildNotesCard(),
                  const SizedBox(height: 20),
                  _buildFollowUpCard(),
                  const SizedBox(height: 20),
                  _buildRelatedRecordsCard(),
                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C4E4E)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Visit Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2C4E4E)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog();
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2C4E4E)),
                    SizedBox(width: 10),
                    Text('Edit Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Visit', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    final displayDate = DateParser.formatDisplay(_visit.safeVisitDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF7CB9A8).withOpacity(0.2),
                radius: 24,
                child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF7CB9A8)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _visit.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate.isNotEmpty ? displayDate : _visit.date,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_visit.doctorName != null && _visit.doctorName!.isNotEmpty) ...[
            const Divider(height: 30),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20, color: Color(0xFF7CB9A8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_visit.doctorName}${_visit.specialty != null && _visit.specialty!.isNotEmpty ? " • ${_visit.specialty}" : ""}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
          if (_visit.hospitalName != null && _visit.hospitalName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF7CB9A8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _visit.hospitalName!,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    final notes = _visit.notes ?? _visit.subtitle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consultation Notes & Diagnosis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            notes.isNotEmpty ? notes : 'No detailed notes recorded for this visit.',
            style: TextStyle(
              fontSize: 14,
              color: notes.isNotEmpty ? Colors.black87 : Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard() {
    final hasFollowUp = _visit.followUpDate != null;
    final displayFollowUp = hasFollowUp ? DateParser.formatDisplay(_visit.followUpDate) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasFollowUp ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasFollowUp ? Border.all(color: Colors.green.shade200) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: hasFollowUp ? Colors.green[800] : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Follow-Up',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasFollowUp ? Colors.green[900] : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasFollowUp ? displayFollowUp! : 'No follow-up appointment scheduled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: hasFollowUp ? FontWeight.bold : FontWeight.normal,
                    color: hasFollowUp ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedRecordsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Related Medical Records',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              Text(
                '${_relatedRecords.length} attached',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_isLoadingRecords)
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ))
          else if (_relatedRecords.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.folder_open_outlined, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'No medical records attached to this visit',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _relatedRecords.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final record = _relatedRecords[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3D7E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(AppAssets.docIcon, height: 24, width: 24),
                  ),
                  title: Text(
                    record.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${record.recordType} • ${record.date}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordDetailsScreen(record: record),
                        ),
                      );
                    },
                    child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
