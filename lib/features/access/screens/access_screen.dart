import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../widgets/access_widgets.dart';
import 'hospital_details_screen.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  int _selectedTab = 0; // 0 for Manage Access, 1 for Access Request
  int? _expandedIndex; // Null if no tile is expanded

  // --- DYNAMIC DATA LISTS ---
  final List<Map<String, String>> _activeHospitals = [
    {
      "name": "Apollo Hospitals",
      "type": "Edit Access",
      "data": "Full Profile",
      "expiry": "14 Days",
    },
  ];

  final List<Map<String, String>> _accessRequests = [
    {"name": "Apollo Hospitals", "type": "Edit Access", "data": "Full Profile"},
    {"name": "Zydus Hospital", "type": "View Only", "data": "Medical Records"},
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
                  _buildTabToggle(),
                  const SizedBox(height: 25),
                  if (_selectedTab == 0) ...[
                    _buildGrantAccessCard(),
                    const SizedBox(height: 25),
                    _buildActiveAccessCard(),
                  ] else ...[
                    _buildAccessRequestView(),
                  ],
                  const SizedBox(height: 120),
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
          GestureDetector(
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
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hospital Access",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  "Manage What Profile Access To Hospital",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: "Manage Access",
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _ToggleItem(
            label: "Access Request",
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildGrantAccessCard() {
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
          const Text(
            "Grant New Access",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const Text(
            "Give Hospitals Access To Your Health Profile",
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          AccessExpansionTile(
            icon: Icons.local_hospital_outlined,
            title: _selectedHospital,
            subtitle: "Choose A Hospital Or Healthcare Provider",
            isExpanded: _expandedIndex == 0,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 0 ? null : 0),
            expandedContent: _buildHospitalDropdown(),
          ),
          AccessExpansionTile(
            icon: Icons.access_time,
            title: "Access Duration",
            subtitle: _selectedDuration,
            isExpanded: _expandedIndex == 1,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 1 ? null : 1),
            expandedContent: Column(
              children: [
                SelectionPill(
                  label: "Permanent Access",
                  isSelected: _selectedDuration == "Permanent Access",
                  onTap: () => setState(() {
                    _selectedDuration = "Permanent Access";
                    _expandedIndex = null;
                  }),
                ),
                SelectionPill(
                  label: "Select Access Until Day",
                  isSelected: _selectedDuration != "Permanent Access",
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null)
                      setState(() {
                        _selectedDuration =
                            "${date.day}/${date.month}/${date.year}";
                        _expandedIndex = null;
                      });
                  },
                ),
              ],
            ),
          ),
          AccessExpansionTile(
            icon: Icons.create_new_folder_outlined,
            title: "Data To Share",
            subtitle: _selectedData.isEmpty
                ? "Full Profile"
                : _selectedData.join(", "),
            isExpanded: _expandedIndex == 2,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 2 ? null : 2),
            expandedContent: Column(
              children: [
                SelectionPill(
                  label: "Full Profile Access",
                  isSelected: _selectedData.isEmpty,
                  onTap: () => setState(() => _selectedData.clear()),
                ),
                SelectionPill(
                  label: "Only Health Timeline",
                  isSelected: _selectedData.contains("Only Health Timeline"),
                  onTap: () => setState(() {
                    _selectedData.contains("Only Health Timeline")
                        ? _selectedData.remove("Only Health Timeline")
                        : _selectedData.add("Only Health Timeline");
                  }),
                ),
                SelectionPill(
                  label: "Only Medical Records",
                  isSelected: _selectedData.contains("Only Medical Records"),
                  onTap: () => setState(() {
                    _selectedData.contains("Only Medical Records")
                        ? _selectedData.remove("Only Medical Records")
                        : _selectedData.add("Only Medical Records");
                  }),
                ),
                SelectionPill(
                  label: "Only Profile Page",
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
            title: "Access Type",
            subtitle: _selectedType,
            isExpanded: _expandedIndex == 3,
            onTap: () =>
                setState(() => _expandedIndex = _expandedIndex == 3 ? null : 3),
            isLast: true,
            expandedContent: Column(
              children: [
                SelectionPill(
                  label: "View Only",
                  isSelected: _selectedType == "View Only",
                  onTap: () => setState(() {
                    _selectedType = "View Only";
                    _expandedIndex = null;
                  }),
                ),
                SelectionPill(
                  label: "Edit & View",
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
              onPressed: () {
                setState(() {
                  _activeHospitals.insert(0, {
                    "name": _selectedHospital == "Select Hospital"
                        ? "New Hospital"
                        : _selectedHospital,
                    "type": _selectedType,
                    "data": _selectedData.isEmpty
                        ? "Full Profile"
                        : _selectedData.join(", "),
                    "expiry": _selectedDuration == "Permanent Access"
                        ? "Never"
                        : _selectedDuration,
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Access Granted Successfully!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Review & Grant Access",
                style: TextStyle(
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

  Widget _buildActiveAccessCard() {
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
          const Text(
            "Active Hospital Access",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const Text(
            "Hospitals That Currently Have Access To Your Profile",
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_activeHospitals.isEmpty)
            const Text("No active access", style: TextStyle(color: Colors.grey))
          else
            ..._activeHospitals.map(
              (hospital) => _buildActiveHospitalTile(hospital),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveHospitalTile(Map<String, String> hospital) {
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
            const Icon(Icons.arrow_forward, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // --- ACCESS REQUEST TAB METHODS ---

  Widget _buildAccessRequestView() {
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
          const Text(
            "Hospital Access Request",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const Text(
            "Hospitals Requesting Access To Your Profile",
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (_accessRequests.isEmpty)
            _buildEmptyState()
          else
            ..._accessRequests.map((request) => _buildRequestTile(request)),
        ],
      ),
    );
  }

  Widget _buildRequestTile(Map<String, String> request) {
    return GestureDetector(
      onTap: () => _showReviewGrantPopup(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Icon(Icons.business, color: Color(0xFF2C4E4E), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  Text(
                    "${request['data']} - ${request['type']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                ],
              ),
            ),
            _buildRequestButton(
              label: "Grant",
              color: const Color(0xFF7CB9A8),
              onTap: () => _showReviewGrantPopup(request),
            ),
            const SizedBox(width: 8),
            _buildRequestButton(
              label: "Decline",
              color: const Color(0xFFBDBDBD),
              onTap: () {
                setState(() => _accessRequests.remove(request));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Request from ${request['name']} declined"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showReviewGrantPopup(Map<String, String> request) {
    String tempDuration = "Permanent Access";
    String tempType = request['type']!;
    List<String> tempData = [request['data']!];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setPopupState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFE2EDEA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Hospital Access Request",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              const Text(
                "Hospitals Requesting Access To Your Profile",
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFF2C4E4E),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['name']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF2C4E4E),
                                ),
                              ),
                              Text(
                                "${tempData.join(", ")} - $tempType",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildPopupRow(
                            icon: Icons.access_time,
                            title: "Access Duration",
                            subtitle: tempDuration,
                            onTap: () {
                              _showSelectionPopup(
                                title: "Access Duration",
                                options: ["Permanent Access", "Custom Date"],
                                onSelected: (val) async {
                                  if (val == "Custom Date") {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (date != null)
                                      setPopupState(
                                        () => tempDuration =
                                            "${date.day}/${date.month}/${date.year}",
                                      );
                                  } else {
                                    setPopupState(() => tempDuration = val);
                                  }
                                },
                                isSelected: (val) => val == "Custom Date"
                                    ? tempDuration != "Permanent Access"
                                    : tempDuration == val,
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 60),
                          _buildPopupRow(
                            icon: Icons.create_new_folder_outlined,
                            title: "Data To Share",
                            subtitle: tempData.isEmpty
                                ? "Full Profile"
                                : tempData.join(", "),
                            onTap: () {
                              _showSelectionPopup(
                                title: "Data To Share",
                                options: [
                                  "Full Profile",
                                  "Only Health Timeline",
                                  "Only Medical Records",
                                  "Only Profile Page",
                                ],
                                isMultiSelect: true,
                                onSelected: (val) {
                                  setPopupState(() {
                                    if (val == "Full Profile")
                                      tempData.clear();
                                    else if (tempData.contains(val))
                                      tempData.remove(val);
                                    else
                                      tempData.add(val);
                                  });
                                },
                                isSelected: (val) => val == "Full Profile"
                                    ? tempData.isEmpty
                                    : tempData.contains(val),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 60),
                          _buildPopupRow(
                            icon: Icons.lock_outline,
                            title: "Access Type",
                            subtitle: tempType,
                            onTap: () {
                              _showSelectionPopup(
                                title: "Access Type",
                                options: ["View Only", "Edit & View"],
                                onSelected: (val) =>
                                    setPopupState(() => tempType = val),
                                isSelected: (val) => tempType == val,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activeHospitals.insert(0, {
                              "name": request['name']!,
                              "type": tempType,
                              "data": tempData.isEmpty
                                  ? "Full Profile"
                                  : tempData.join(", "),
                              "expiry": tempDuration == "Permanent Access"
                                  ? "Never"
                                  : tempDuration,
                            });
                            _accessRequests.remove(request);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Access granted successfully!"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CB9A8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Review & Grant Access",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectionPopup({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
    required bool Function(String) isSelected,
    bool isMultiSelect = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFE2EDEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2C4E4E),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (opt) => SelectionPill(
                    label: opt,
                    isSelected: isSelected(opt),
                    onTap: () {
                      onSelected(opt);
                      setDialogState(() {});
                      if (!isMultiSelect && opt != "Custom Date")
                        Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF7CB9A8), size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF2C4E4E)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 15),
            Text(
              "No Access Requests",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
