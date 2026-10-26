import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../widgets/access_widgets.dart';
import '../../profile/controllers/profile_controller.dart';
import 'hospital_details_screen.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  int _selectedTab = 0;
  int? _expandedIndex;

  final List<Map<String, String>> _activeHospitals = [
    {
      "name": "Apollo Hospitals",
      "type": "Edit Access",
      "data": "Full Profile",
      "expiry": "14 Days",
    },
  ];

  // Selection states for "Grant New Access"
  String _selectedHospital = "Select Hospital";
  String _selectedDuration = "Permanent Access";
  final List<String> _selectedData = [
    "Only Health Timeline",
    "Only Medical Records",
  ];
  String _selectedType = "Edit & View";

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildTabToggle(l10n),
                  const SizedBox(height: 25),
                  if (_selectedTab == 0) ...[
                    _buildGrantAccessCard(l10n),
                    const SizedBox(height: 25),
                    _buildActiveAccessCard(l10n),
                  ] else ...[
                    _buildAccessRequestView(l10n),
                  ],
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: context.l10n.commonBack,
            child: Semantics(
              button: true,
              label: context.l10n.commonBack,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF769E93),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.accessTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  context.l10n.accessSubtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: l10n.accessManageTab,
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _ToggleItem(
            label: l10n.accessRequestTab,
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  String _formatDataShared(dynamic l10n, List<String> data) {
    if (data.isEmpty) return l10n.accessFullProfile;
    return data.map((d) {
      if (d == "Only Health Timeline") return l10n.accessHealthTimelineOnly;
      if (d == "Only Medical Records") return l10n.accessMedicalRecordsOnly;
      if (d == "Only Profile Page") return l10n.accessProfilePageOnly;
      return d;
    }).join(", ");
  }

  Widget _buildGrantAccessCard(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kTopBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accessGrantNewTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          Text(
            l10n.accessGrantNewSubtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          AccessExpansionTile(
            icon: Icons.local_hospital_outlined,
            title: _selectedHospital == "Select Hospital"
                ? l10n.accessSelectHospital
                : _selectedHospital,
            subtitle: l10n.accessChooseHospitalSubtitle,
            isExpanded: _expandedIndex == 0,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 0 ? null : 0),
            expandedContent: _buildHospitalDropdown(),
          ),
          AccessExpansionTile(
            icon: Icons.access_time,
            title: l10n.accessDurationTitle,
            subtitle: _selectedDuration == "Permanent Access"
                ? l10n.accessPermanent
                : _selectedDuration,
            isExpanded: _expandedIndex == 1,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 1 ? null : 1),
            expandedContent: Column(
              children: [
                SelectionPill(
                  label: l10n.accessPermanent,
                  isSelected: _selectedDuration == "Permanent Access",
                  onTap: () => setState(() {
                    _selectedDuration = "Permanent Access";
                    _expandedIndex = null;
                  }),
                ),
                SelectionPill(
                  label: l10n.accessUntilDay,
                  isSelected: _selectedDuration != "Permanent Access",
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDuration =
                            "${date.day}/${date.month}/${date.year}";
                        _expandedIndex = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          AccessExpansionTile(
            icon: Icons.create_new_folder_outlined,
            title: l10n.accessDataToShare,
            subtitle: _formatDataShared(l10n, _selectedData),
            isExpanded: _expandedIndex == 2,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 2 ? null : 2),
            expandedContent: Column(
              children: [
                SelectionPill(
                  label: l10n.accessFullProfile,
                  isSelected: _selectedData.isEmpty,
                  onTap: () => setState(() => _selectedData.clear()),
                ),
                SelectionPill(
                  label: l10n.accessHealthTimelineOnly,
                  isSelected: _selectedData.contains("Only Health Timeline"),
                  onTap: () => setState(() {
                    _selectedData.contains("Only Health Timeline")
                        ? _selectedData.remove("Only Health Timeline")
                        : _selectedData.add("Only Health Timeline");
                  }),
                ),
                SelectionPill(
                  label: l10n.accessMedicalRecordsOnly,
                  isSelected: _selectedData.contains("Only Medical Records"),
                  onTap: () => setState(() {
                    _selectedData.contains("Only Medical Records")
                        ? _selectedData.remove("Only Medical Records")
                        : _selectedData.add("Only Medical Records");
                  }),
                ),
                SelectionPill(
                  label: l10n.accessProfilePageOnly,
                  isSelected: _selectedData.contains("Only Profile Page"),
                  onTap: () => setState(() {
                    _selectedData.contains("Only Profile Page")
                        ? _selectedData.remove("Only Profile Page")
                        : _selectedData.add("Only Profile Page");
                  }),
                ),
              ],
            ),
          ),
          AccessExpansionTile(
            icon: Icons.lock_outline,
            title: l10n.accessTypeTitle,
            subtitle: _selectedType == "Edit & View"
                ? l10n.accessEditAndView
                : l10n.accessViewOnly,
            isExpanded: _expandedIndex == 3,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 3 ? null : 3),
            isLast: true,
            expandedContent: Column(
              children: [
                SelectionPill(
                  label: l10n.accessViewOnly,
                  isSelected: _selectedType == "View Only",
                  onTap: () => setState(() {
                    _selectedType = "View Only";
                    _expandedIndex = null;
                  }),
                ),
                SelectionPill(
                  label: l10n.accessEditAndView,
                  isSelected: _selectedType == "Edit & View",
                  onTap: () => setState(() {
                    _selectedType = "Edit & View";
                    _expandedIndex = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                final hospitalName = _selectedHospital == "Select Hospital"
                    ? "Caregiver"
                    : _selectedHospital;

                final List<String> scopes = [];
                if (_selectedData.contains("Only Health Timeline")) {
                  scopes.add("health_timeline");
                }
                if (_selectedData.contains("Only Medical Records")) {
                  scopes.add("medical_records");
                }
                if (_selectedData.contains("Only Profile Page") ||
                    _selectedData.isEmpty) {
                  scopes.add("full_profile");
                }

                await ProfileController.instance.inviteCaregiver(
                  email:
                      "${hospitalName.toLowerCase().replaceAll(' ', '')}@example.com",
                  name: hospitalName,
                  scopes: scopes.isEmpty ? ["medical_records"] : scopes,
                  accessType: _selectedType == "Edit & View"
                      ? "view_and_edit"
                      : "view_only",
                  purpose: "Delegated caregiver access",
                );

                setState(() {
                  _activeHospitals.insert(0, {
                    "name": hospitalName,
                    "type": _selectedType,
                    "data": _selectedData.isEmpty
                        ? "Full Profile"
                        : _selectedData.join(", "),
                    "expiry": _selectedDuration == "Permanent Access"
                        ? "Never"
                        : _selectedDuration,
                  });
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.accessGrantedSuccess),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.accessReviewAndGrant,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalDropdown() {
    final hospitals = [
      {"name": "Apollo Hospitals", "location": "Navrangpura, Ahmedabad"},
      {"name": "Zydus Hospital", "location": "Sola Road, Ahmedabad"},
    ];
    return Column(
      children: hospitals
          .map(
            (h) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                h['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              subtitle: Text(
                h['location']!,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.add_circle_outline,
                color: AppColors.kPrimary,
              ),
              onTap: () => setState(() {
                _selectedHospital = h['name']!;
                _expandedIndex = null;
              }),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActiveAccessCard(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kTopBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accessActiveHospitals,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          Text(
            l10n.accessActiveHospitalsSubtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_activeHospitals.isEmpty)
            Text(l10n.accessNoActive, style: const TextStyle(color: Colors.grey))
          else
            ..._activeHospitals.map(
              (hospital) => _buildActiveHospitalTile(hospital, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveHospitalTile(Map<String, String> hospital, dynamic l10n) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalDetailsScreen(
            hospitalName: hospital['name']!,
            accessType: hospital['type']!,
            dataShared: hospital['data']!,
            expiry: hospital['expiry'] ?? "Never",
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: Icon(Icons.business, color: Color(0xFF2C4E4E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  Text(
                    "${hospital['data']} - ${hospital['type']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.cancel_outlined,
                color: Colors.redAccent,
                size: 22,
              ),
              tooltip: l10n.accessRevokeAction,
              onPressed: () => _confirmRevoke(hospital, l10n),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _confirmRevoke(Map<String, String> hospital, dynamic l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.accessRevokeTitle),
        content: Text(
          l10n.accessRevokeConfirmMessage(hospital['name']!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              final grant = ProfileController.instance.caregiverGrant;
              if (grant != null) {
                await ProfileController.instance.revokeCaregiver(grant.id);
              }
              if (!mounted) return;
              setState(() {
                _activeHospitals.remove(hospital);
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.accessRevokedSnackbar(hospital['name']!)),
                ),
              );
            },
            child: Text(l10n.accessRevokeConfirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- ACCESS REQUEST TAB METHODS ---

  Widget _buildAccessRequestView(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kTopBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.accessHospitalRequestTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          Text(
            l10n.accessHospitalRequestSubtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD2E4DD)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F4F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primaryTeal,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.accessClinicianComingSoon,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.accessClinicianNotice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD2E4DD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        size: 16,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.accessEnforcedSecurity,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CB9A8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => setState(() => _selectedTab = 0),
                    child: Text(
                      l10n.accessGoToManage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
