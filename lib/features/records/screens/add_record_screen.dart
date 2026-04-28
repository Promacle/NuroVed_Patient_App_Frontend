import 'dart:io'; // Add this for File

import 'package:file_picker/file_picker.dart'; // Add this
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/screens/record_success_screen.dart';

import '../../home/screens/main_layout.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  bool _isProfileExpanded = false;
  bool _isTypeExpanded = false; // Added this
  String _selectedProfileName = "";
  String _selectedRecordType = ""; // Added this
  bool _isDateExpanded = false;
  bool _isDetailsExpanded = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isFileExpanded = false;
  File? _selectedFile;
  dynamic _pickedFileObject;
  String _fileName = "Upload Your Record Document";

  DateTime _selectedDate = DateTime.now();
  // Format the date for the subtitle
  String get _formattedDate =>
      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";

  @override
  void initState() {
    super.initState();
    // Initialize with the current active profile from the controller
    _selectedProfileName = "";
  }

  void _saveRecord() {
    if (_selectedProfileName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a profile")));
      return;
    }

    // Create the record data object
    final Map<String, dynamic> recordData = {
      "title": _titleController.text,
      "description": _descController.text,
      "type": _selectedRecordType,
      "date": _selectedDate.toIso8601String(),
      "fileName": _fileName,
      "file": _pickedFileObject, // Contains File path or Web Bytes
    };

    // Logic to save to the controller
    final controller = ProfileController();
    // Assuming your controller handles adding the record to the specific profile
    ProfileController().addRecordToProfile(_selectedProfileName, recordData);

    // 2. IMPORTANT: Set this as the active profile so the RecordsScreen knows who to display
    ProfileController().activeProfileName = _selectedProfileName;

    // 3. Navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordSuccessScreen(
          profileName: _selectedProfileName,
          date: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    // Change .platform to .instance for Web compatibility
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'jpg', 'png'],
      withData: kIsWeb, // Required for Web to get file content
    );

    if (result != null) {
      setState(() {
        // Handle web vs mobile file paths
        if (result.files.single.path != null) {
          _selectedFile = File(result.files.single.path!);
        }
        _fileName = result.files.single.name;
        _isFileExpanded = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _fileName = "Photo_${DateTime.now().millisecondsSinceEpoch}.jpg";
        _pickedFileObject = kIsWeb ? bytes : File(photo.path);
        _isFileExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents the default "pop"
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Redirect to Records Tab
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainLayout(initialIndex: 1),
          ),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.mintBackground, // Use AppColors here
        // Light teal background for top
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),

              // Character Illustration
              Image.asset(
                AppAssets.loginDog, // Replace with your actual asset path
                height: 170,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),

              // White Container for Form
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    // ... inside the Column within the white Container
                    _buildProfileSelectionCard(
                      ProfileController().familyMembers,
                    ),
                    _buildRecordTypeSelectionCard(),
                    _buildDateSelectionCard(),
                    // REPLACE THE OLD STATIC CARD WITH:
                    _buildDetailsInputCard(),
                    // REPLACE THE OLD STATIC Record file CARD WITH:
                    _buildFileUploadCard(),

                    const SizedBox(height: 40),

                    // Save Button
                    // Save Button inside the Container
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.darkTeal, // Use theme darkTeal
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4, // Added slight elevation for 3D look
                        ),
                        child: const Text(
                          "Save Records",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Force return to MainLayout on the Records Tab (Index 1)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainLayout(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA8D5C2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Add New Record",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance the back button
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Add Your New Medical Report, Prescription, Or Other\nHealth Record",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelectionCard(List<Map<String, dynamic>> familyMembers) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
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
          // 1. Clickable Header
          GestureDetector(
            onTap: () =>
                setState(() => _isProfileExpanded = !_isProfileExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        // SHOW PLACEHOLDER TEXT IF NOT EXPANDED OR NOT SELECTED
                        Text(
                          _selectedProfileName.isEmpty
                              ? "Select Profile In Which You Want To Save"
                              : "Selected: $_selectedProfileName",
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isProfileExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),

          // 2. Dynamic Expansion Grid (CLEANER & SMALLER)
          if (_isProfileExpanded)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              3, // Changed to 3 for smaller, cleaner cards
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio:
                              0.75, // Taller ratio for cleaner look
                        ),
                    itemCount: familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = familyMembers[index];
                      final isSelected = _selectedProfileName == member['name'];
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedProfileName = member['name'],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE2EDEA)
                                : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryTeal
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22, // Smaller avatars
                                backgroundColor: AppColors.mintBackground,
                                child: Text(
                                  member['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
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
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () =>
                          setState(() => _isProfileExpanded = false),
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordTypeSelectionCard() {
    final List<String> types = [
      "Medical Records",
      "Vaccination's",
      "Bills",
      "Lab",
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
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
          // Header (Clickable)
          GestureDetector(
            onTap: () => setState(() => _isTypeExpanded = !_isTypeExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppAssets.docIcon,
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
                          "Record Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _selectedRecordType.isEmpty
                              ? "Select Record Type"
                              : "Selected: $_selectedRecordType",
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isTypeExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),

          // Expanded List View
          if (_isTypeExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Column(
                children: types.map((type) {
                  final isSelected = _selectedRecordType == type;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedRecordType = type;
                      _isTypeExpanded = false; // Collapse after selection
                    }),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE2EDEA)
                            : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryTeal
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF2C4E4E)
                              : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
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
          // Header (Clickable)
          GestureDetector(
            onTap: () => setState(() => _isDateExpanded = !_isDateExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF2C4E4E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _isDateExpanded
                              ? "Select Date You Get The Record"
                              : "Selected: $_formattedDate",
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isDateExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Calendar View
          if (_isDateExpanded)
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  // Set background to pure white for visibility
                  scaffoldBackgroundColor: AppColors.surfaceWhite,
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryTeal, // Selection Circle Color
                    onPrimary: AppColors.white, // Text inside the Circle
                    onSurface: Color(0xFF1E293B), // High-contrast numbers/text
                  ),
                  datePickerTheme: DatePickerThemeData(
                    // THIS FORCES THE SHAPE TO BE A CIRCLE LIKE YOUR PHOTO
                    dayShape: WidgetStateProperty.all(const CircleBorder()),

                    // Background color for the selected day
                    dayBackgroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primaryTeal;
                      }
                      return null;
                    }),

                    // Text color logic
                    dayForegroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.white;
                      }
                      return const Color(0xFF1E293B);
                    }),

                    // Styling the Month-Year header (Jan-2026)
                    headerForegroundColor: const Color(0xFF1E293B),
                    headerHeadlineStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  textTheme: const TextTheme(
                    // Month-Year display (e.g., Jan-2026)
                    titleMedium: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                    // Days of the week labels
                    bodyLarge: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                    // The date numbers
                    bodySmall: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 300,
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = date;
                        _isDateExpanded = false; // Collapse after selection
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsInputCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
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
          // Header (Clickable)
          GestureDetector(
            onTap: () =>
                setState(() => _isDetailsExpanded = !_isDetailsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppAssets.docIcon,
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
                          "Record title & description",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _titleController.text.isEmpty
                              ? "Enter Record Title & Description"
                              : _titleController.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isDetailsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Input Fields
          if (_isDetailsExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Column(
                children: [
                  // Title Field
                  _buildStyledTextField(
                    controller: _titleController,
                    hint: "Enter record title....",
                  ),
                  const SizedBox(height: 15),
                  // Description Field
                  _buildStyledTextField(
                    controller: _descController,
                    hint: "Enter record description....",
                    maxLines: 3,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper widget to create those clean white text fields in your photo
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (value) => setState(() {}), // Refresh header subtitle
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

  Widget _buildFileUploadCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
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
            onTap: () => setState(() => _isFileExpanded = !_isFileExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      AppAssets.docIcon,
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
                          "Record file",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _fileName, // DYNAMIC FILE NAME
                          style: TextStyle(
                            color: _selectedFile != null
                                ? AppColors.primaryTeal
                                : AppColors.textGrey,
                            fontSize: 11,
                            fontWeight: _selectedFile != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isFileExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),
          if (_isFileExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Column(
                children: [
                  _buildUploadOption(
                    icon: Icons.unarchive_outlined,
                    label: "Upload Files",
                    onTap: _pickFile, // CONNECTED LOGIC
                  ),
                  const SizedBox(height: 12),
                  _buildUploadOption(
                    icon: Icons.camera_alt_outlined,
                    label: "Click Photo",
                    onTap: _takePhoto, // CONNECTED LOGIC
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper for the white buttons inside the expansion
  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
