import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import '../../../core/models/medicine_routine.dart';
import '../../../core/services/notification_scheduler.dart';
import '../../../core/utils/uuid_generator.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final RoutineController _controller = RoutineController();
  final ProfileController _profileController = ProfileController();

  bool _isProfileExpanded = false;
  bool _isDetailsExpanded = false;
  bool _isTimeExpanded = true; // Keep time expanded by default as in photo
  bool _isSubmitting = false;

  String _selectedProfileName = "";
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  DateTime _selectedTime = DateTime(2024, 1, 1, 8, 0); // Default 8:00 AM

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profileController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildProfileSelectionCard(),
                      const SizedBox(height: 15),
                      _buildMedicineDetailsCard(),
                      const SizedBox(height: 15),
                      _buildReminderTimeCard(),
                      const SizedBox(height: 30),
                      _buildSaveButton(),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: context.l10n.semanticsBack,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
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
                  context.l10n.routineAddMedicinesTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  context.l10n.routineAddMedicinesSubtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelectionCard() {
    final familyMembers = _profileController.familyMembers;
    final selectedMember = familyMembers.firstWhere(
      (m) => m['name'] == _selectedProfileName,
      orElse: () => {},
    );
    final dynamic selectedImage = selectedMember['imageFile'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDEA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isProfileExpanded = !_isProfileExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          selectedImage is AppPlatformFile &&
                              selectedImage.bytes != null
                          ? Image.memory(
                              selectedImage.bytes!,
                              fit: BoxFit.cover,
                            )
                          : (selectedImage is Uint8List
                                ? Image.memory(selectedImage, fit: BoxFit.cover)
                                : Image.asset(AppAssets.userIcon, scale: 2)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.routineProfiles,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _selectedProfileName.isEmpty
                              ? context.l10n.routineSelectProfilePrompt
                              : "${context.l10n.routineSelectedProfile}: $_selectedProfileName",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isProfileExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.arrow_downward,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isProfileExpanded)
            Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  final member = familyMembers[index];
                  final isSelected = _selectedProfileName == member['name'];
                  final dynamic imageFile = member['imageFile'];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedProfileName = member['name'];
                      _isProfileExpanded = false;
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFADC8C0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryTeal
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.mintBackground,
                            backgroundImage: imageFile is AppPlatformFile
                                ? imageFile.toImageProvider()
                                : (imageFile is Uint8List
                                      ? MemoryImage(imageFile)
                                      : null),
                            child: imageFile == null
                                ? Text(member['name'][0].toUpperCase())
                                : null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            member['name'],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineDetailsCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDEA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isDetailsExpanded = !_isDetailsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      AppAssets.medicineIcon,
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
                          context.l10n.routineMedicineDetails,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          _medicineNameController.text.isEmpty
                              ? context.l10n.routineEnterMedicineDetails
                              : "${context.l10n.routineMedicineNameLabel}: ${_medicineNameController.text}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isDetailsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.arrow_downward,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isDetailsExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _medicineNameController,
                    hint: context.l10n.routineEnterMedicineNameHint,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _instructionController,
                    hint: context.l10n.routineEnterInstructionsHint,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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

  Widget _buildReminderTimeCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EDEA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isTimeExpanded = !_isTimeExpanded),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.routineReminderTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                      ),
                      Text(
                        context.l10n.routineSelectTimePrompt,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isTimeExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.arrow_downward,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isTimeExpanded) ...[
            const SizedBox(height: 25),
            // 12-Hour Time Picker with AM/PM
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false, // Enables AM/PM selection
                initialDateTime: _selectedTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() => _selectedTime = newDateTime);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _onSaveReminderPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                context.l10n.routineSaveReminder,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _onSaveReminderPressed() async {
    if (_isSubmitting) return;

    if (_selectedProfileName.isEmpty ||
        _medicineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.routineSelectProfileAndNameError)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // 1. Request notification permissions properly before scheduling
    final permissionStatus = await _controller.scheduler.requestPermission();
    if (permissionStatus != NotificationPermissionStatus.granted) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showPermissionDeniedDialog(context);
      }
      return;
    }

    // 2. Format 12-hour display time
    final hours = _selectedTime.hour;
    final minutes = _selectedTime.minute;
    final amPm = hours >= 12 ? "PM" : "AM";
    final displayHour = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours);
    final timeStr =
        "${displayHour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $amPm";
    final instruction = _instructionController.text.trim();
    final medName = _medicineNameController.text.trim();
    final reminderId = UuidGenerator.v4();

    // 3. Schedule the reminder notification and verify confirmation
    final scheduleResult = await _controller.scheduler.scheduleReminder(
      id: reminderId,
      title: "Medication Reminder: $medName",
      body:
          "1 tablet * $timeStr ${instruction.isNotEmpty ? '* $instruction' : ''}"
              .trim(),
      scheduledTime: _selectedTime,
      exact: true,
    );

    if (scheduleResult.isFailure) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.routineFailedToScheduleNotification(
                scheduleResult.failureOrNull?.message ?? "Error",
              ),
            ),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
      return;
    }

    // 4. Save the routine only after scheduling confirms success
    _controller.addMedicine({
      "id": reminderId,
      "name": medName,
      "instruction":
          "1 tablet * $timeStr ${instruction.isNotEmpty ? '* $instruction' : ''}"
              .trim(),
      "dosage": "1 tablet",
      "time": timeStr,
      "source": RoutineSource.selfEntered.name,
      "source_display": "Self-Entered",
      "isCompleted": false,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.routineReminderSavedSuccess),
          backgroundColor: AppColors.primaryTeal,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFFE11D48),
            ),
            const SizedBox(width: 10),
            Text(
              dialogCtx.l10n.routinePermissionDenied,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          dialogCtx.l10n.routinePermissionDeniedMessage,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              dialogCtx.l10n.commonCancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              dialogCtx.l10n.commonUnderstood,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
