import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/models/diet/diet_preferences.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';

import '../widgets/diet_planner_widgets.dart';

/// Step 1 of the Diet Planner flow: Basic Information & Profile Selection.
class AiDietPlannerScreen extends StatefulWidget {
  final DietPreferences? initialPreferences;

  const AiDietPlannerScreen({super.key, this.initialPreferences});

  @override
  State<AiDietPlannerScreen> createState() => _AiDietPlannerScreenState();
}

class _AiDietPlannerScreenState extends State<AiDietPlannerScreen> {
  final ProfileController _profileController = ProfileController.instance;

  final TextEditingController _ageController = TextEditingController(
    text: '28',
  );
  final TextEditingController _weightController = TextEditingController(
    text: '70',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '175',
  );

  String _selectedGender = 'Male';
  String? _selectedProfileName;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialPreferences != null) {
      final p = widget.initialPreferences!;
      if (p.age != null) _ageController.text = p.age.toString();
      if (p.weightKg != null) {
        _weightController.text = p.weightKg!.toStringAsFixed(0);
      }
      if (p.heightCm != null) {
        _heightController.text = p.heightCm!.toStringAsFixed(0);
      }
      if (p.gender != null) _selectedGender = p.gender!;
      _selectedProfileName = p.profileName;
    } else {
      _tryAutoPopulateFromActiveProfile();
    }
  }

  void _tryAutoPopulateFromActiveProfile() {
    try {
      final profile = _profileController.profile;
      if (profile.name.isNotEmpty && profile.name != 'Not provided') {
        _selectedProfileName = profile.name;
      }
      final cleanHeight = profile.height.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanHeight.isNotEmpty) {
        _heightController.text = cleanHeight;
      }
      final cleanWeight = profile.weight.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleanWeight.isNotEmpty) {
        _weightController.text = cleanWeight;
      }
      final g = profile.gender.trim();
      if (['Male', 'Female', 'Other'].contains(g)) {
        _selectedGender = g;
      }
      final dobStr = profile.dateOfBirth;
      if (dobStr.isNotEmpty && dobStr != 'Not provided') {
        final parts = dobStr.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            final birthDate = DateTime(year, month, day);
            final today = DateTime.now();
            int age = today.year - birthDate.year;
            if (today.month < birthDate.month ||
                (today.month == birthDate.month && today.day < birthDate.day)) {
              age--;
            }
            if (age > 0 && age < 120) {
              _ageController.text = age.toString();
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() => _validationError = null);

    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      setState(() => _validationError = context.l10n.validationAgeRange);
      return;
    }

    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight < 20 || weight > 300) {
      setState(
        () => _validationError = context.l10n.dietValidationWeight,
      );
      return;
    }

    final height = double.tryParse(_heightController.text.trim());
    if (height == null || height < 50 || height > 250) {
      setState(
        () => _validationError = context.l10n.dietValidationHeight,
      );
      return;
    }

    final preferences = (widget.initialPreferences ?? const DietPreferences())
        .copyWith(
          profileName: _selectedProfileName,
          age: age,
          gender: _selectedGender,
          weightKg: weight,
          heightCm: height,
        );

    Navigator.pushNamed(
      context,
      AppRouter.dietPreference,
      arguments: preferences,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          DietPlannerHeader(
            title: context.l10n.dietPlannerTitle,
            subtitle: context.l10n.dietPlannerSubtitle,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInformationalBanner(context),
                  const SizedBox(height: 16),
                  DietPlannerCard(
                    title: context.l10n.dietStep1Title,
                    icon: Icons.person_outline_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedProfileName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_circle,
                                  size: 18,
                                  color: AppColors.primaryTeal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.l10n.dietProfilePrefix(
                                      _selectedProfileName!,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        DietPlannerTextField(
                          label: context.l10n.dietAgeYearsLabel,
                          controller: _ageController,
                          hint: "28",
                          keyboardType: TextInputType.number,
                          onIncrement: () {
                            final curr =
                                int.tryParse(_ageController.text.trim()) ?? 28;
                            if (curr < 120) {
                              setState(
                                () =>
                                    _ageController.text = (curr + 1).toString(),
                              );
                            }
                          },
                          onDecrement: () {
                            final curr =
                                int.tryParse(_ageController.text.trim()) ?? 28;
                            if (curr > 1) {
                              setState(
                                () =>
                                    _ageController.text = (curr - 1).toString(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildGenderSelector(context),
                        const SizedBox(height: 16),
                        DietPlannerTextField(
                          label: context.l10n.dietWeightKgLabel,
                          controller: _weightController,
                          hint: "70",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DietPlannerTextField(
                          label: context.l10n.dietHeightCmLabel,
                          controller: _heightController,
                          hint: "175",
                          keyboardType: TextInputType.number,
                        ),
                        if (_validationError != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFDC2626),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _validationError!,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        DietPlannerActionButton(
                          label: context.l10n.dietBtnContinueDietPref,
                          onPressed: _onContinue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationalBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.dietVerifiedNutritionalPlanningNotice,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF166534),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.dietFieldGender,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6A6A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: "Male",
                  child: Text(context.l10n.dietFieldGenderMale),
                ),
                DropdownMenuItem(
                  value: "Female",
                  child: Text(context.l10n.dietFieldGenderFemale),
                ),
                DropdownMenuItem(
                  value: "Other",
                  child: Text(context.l10n.dietFieldGenderOther),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedGender = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
