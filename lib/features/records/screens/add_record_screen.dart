import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/core/utils/validators.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/records/screens/record_success_screen.dart';

import '../../home/controllers/home_controller.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  bool _isProfileExpanded = false;
  bool _isTypeExpanded = false;
  String _selectedProfileName = "";
  String _selectedRecordType = "";
  bool _isDateExpanded = false;
  bool _isDetailsExpanded = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isFileExpanded = false;
  AppPlatformFile? _pickedPlatformFile;
  String _fileName = "Upload Your Record Document";

  DateTime _selectedDate = DateTime.now();
  String get _formattedDate =>
      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";

  @override
  void initState() {
    super.initState();
    _selectedProfileName = "";
  }

  Future<void> _saveRecord() async {
    if (_selectedProfileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordsSelectProfilePrompt)),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordsEnterTitlePrompt)),
      );
      return;
    }

    if (_pickedPlatformFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordsAttachPrompt)),
      );
      return;
    }

    final recordsCtrl = RecordsController();
    if (recordsCtrl.isUploading) {
      return;
    }

    final result = await recordsCtrl.uploadAndSaveRecord(
      title: _titleController.text.trim(),
      recordType: _selectedRecordType.isEmpty
          ? 'Medical Record'
          : _selectedRecordType,
      date: _selectedDate.toIso8601String(),
      description: _descController.text.trim(),
      file: _pickedPlatformFile!,
    );

    if (!mounted) return;

    result.when(
      success: (record) {
        ProfileController().activeProfileName = _selectedProfileName;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RecordSuccessScreen(
              profileName: _selectedProfileName,
              date: DateTime.now(),
            ),
          ),
        );
      },
      failure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message), backgroundColor: Colors.red[700]),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      final platformFile = await AppPlatformFile.fromPlatformFile(file);

      // Validate format, 10MB limit, and magic bytes signature
      final validationError = Validators.validateMedicalDocument(
        fileName: platformFile.name,
        byteLength: platformFile.size,
        bytes: platformFile.bytes,
      );
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Colors.red[700],
            ),
          );
        }
        return;
      }

      setState(() {
        _pickedPlatformFile = platformFile;
        _fileName = platformFile.name;
        _isFileExpanded = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final platformFile = await AppPlatformFile.fromXFile(photo);

      final validationError = Validators.validateMedicalDocument(
        fileName: platformFile.name,
        byteLength: platformFile.size,
        bytes: platformFile.bytes,
      );
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Colors.red[700],
            ),
          );
        }
        return;
      }

      setState(() {
        _pickedPlatformFile = platformFile;
        _fileName = platformFile.name;
        _isFileExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = ProfileController();

    return ListenableBuilder(
      listenable: profileController,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              HomeController().setTab(1);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.mintBackground,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  Image.asset(
                    AppAssets.loginDog,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildProfileSelectionCard(
                          profileController.familyMembers,
                        ),
                        _buildRecordTypeSelectionCard(),
                        _buildDateSelectionCard(),
                        _buildDetailsInputCard(),
                        _buildFileUploadCard(),
                        const SizedBox(height: 40),
                        _buildSaveButtonWidget(),
                        const SizedBox(height: 20),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    HomeController().setTab(1);
                  }
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
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.recordsAddRecordTitle,
                    style: const TextStyle(
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
          Text(
            context.l10n.recordsAddRecordSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelectionCard(List<Map<String, dynamic>> familyMembers) {
    final selectedMember = familyMembers.firstWhere(
      (m) => m['name'] == _selectedProfileName,
      orElse: () => {},
    );
    final dynamic selectedImage = selectedMember['imageFile'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.navyGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isProfileExpanded = !_isProfileExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child:
                          selectedImage is AppPlatformFile &&
                              selectedImage.bytes != null
                          ? Image.memory(
                              selectedImage.bytes!,
                              fit: BoxFit.cover,
                            )
                          : (selectedImage is Uint8List
                                ? Image.memory(selectedImage, fit: BoxFit.cover)
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(AppAssets.userIcon),
                                  )),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.familyTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _selectedProfileName.isEmpty
                              ? context.l10n.recordsSelectProfile
                              : "${context.l10n.routineSelectedProfile}: $_selectedProfileName",
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
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = familyMembers[index];
                      final isSelected = _selectedProfileName == member['name'];
                      final dynamic imageFile = member['imageFile'];

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
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.mintBackground,
                                backgroundImage: imageFile is AppPlatformFile
                                    ? imageFile.toImageProvider()
                                    : (imageFile is Uint8List
                                          ? MemoryImage(imageFile)
                                          : null),
                                child: imageFile == null
                                    ? Text(
                                        member['name'][0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryTeal,
                                        ),
                                      )
                                    : null,
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
                  _buildCollapseButton(
                    () => setState(() => _isProfileExpanded = false),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getRecordTypeLabel(BuildContext context, String type) {
    switch (type) {
      case "Medical Records":
        return context.l10n.recordsFilterMedicalRecords;
      case "Vaccinations":
        return context.l10n.recordsFilterVaccinations;
      case "Bills":
        return context.l10n.recordsFilterBills;
      case "Lab":
        return context.l10n.recordsFilterLab;
      default:
        return type;
    }
  }

  Widget _buildRecordTypeSelectionCard() {
    final List<String> types = [
      "Medical Records",
      "Vaccinations",
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
            color: Colors.black.withValues(alpha: 0.12),
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                        Text(
                          context.l10n.recordsRecordType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _selectedRecordType.isEmpty
                              ? context.l10n.recordsSelectRecordType
                              : "${context.l10n.routineSelectedProfile}: ${_getRecordTypeLabel(context, _selectedRecordType)}",
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
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getRecordTypeLabel(context, type),
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
            color: Colors.black.withValues(alpha: 0.12),
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                        Text(
                          context.l10n.recordsDateLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _isDateExpanded
                              ? context.l10n.recordsSelectDatePrompt
                              : "${context.l10n.routineSelectedProfile}: $_formattedDate",
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: AppColors.surfaceWhite,
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryTeal,
                    onPrimary: AppColors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
                  datePickerTheme: DatePickerThemeData(
                    dayShape: WidgetStateProperty.all(const CircleBorder()),
                    dayBackgroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primaryTeal;
                      }
                      return null;
                    }),
                    dayForegroundColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.white;
                      }
                      return const Color(0xFF1E293B);
                    }),
                    headerForegroundColor: const Color(0xFF1E293B),
                    headerHeadlineStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  textTheme: const TextTheme(
                    titleMedium: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                    bodyLarge: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
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
                        _isDateExpanded = false;
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

  Widget _buildSaveButtonWidget() {
    final recordsCtrl = RecordsController();

    return ListenableBuilder(
      listenable: recordsCtrl,
      builder: (context, _) {
        if (recordsCtrl.isUploading) {
          final progressPercent = (recordsCtrl.uploadProgress * 100).toInt();
          return Column(
            children: [
              LinearProgressIndicator(
                value: recordsCtrl.uploadProgress > 0
                    ? recordsCtrl.uploadProgress
                    : null,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primaryTeal,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${context.l10n.recordsUploadingSecurely} $progressPercent%',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  TextButton.icon(
                    onPressed: () => recordsCtrl.cancelUpload(),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: Colors.red,
                    ),
                    label: Text(
                      context.l10n.commonCancel,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _saveRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            child: Text(
              context.l10n.recordsSaveButton,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
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
        child: Text(
          context.l10n.recordsSelectProfile,
          style: const TextStyle(color: Colors.white),
        ),
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
            color: Colors.black.withValues(alpha: 0.12),
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                        Text(
                          context.l10n.recordsTitleAndDescription,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _titleController.text.isEmpty
                              ? context.l10n.recordsEnterTitleAndDescription
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
                    hint: context.l10n.recordsEnterRecordTitleHint,
                  ),
                  const SizedBox(height: 15),
                  // Description Field
                  _buildStyledTextField(
                    controller: _descController,
                    hint: context.l10n.recordsEnterRecordDescriptionHint,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (value) => setState(() {}),
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
            color: Colors.black.withValues(alpha: 0.12),
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
                        Text(
                          context.l10n.recordsRecordFile,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _fileName == "Upload Your Record Document"
                              ? context.l10n.recordsUploadDocumentPrompt
                              : _fileName,
                          style: TextStyle(
                            color: _pickedPlatformFile != null
                                ? AppColors.primaryTeal
                                : AppColors.textGrey,
                            fontSize: 11,
                            fontWeight: _pickedPlatformFile != null
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
                    label: context.l10n.recordsUploadFilesOption,
                    onTap: _pickFile,
                  ),
                  const SizedBox(height: 12),
                  _buildUploadOption(
                    icon: Icons.camera_alt_outlined,
                    label: context.l10n.recordsClickPhotoOption,
                    onTap: _takePhoto,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

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
              color: Colors.black.withValues(alpha: 0.05),
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
