import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/models/diet/diet_preferences.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';
import '../widgets/diet_planner_widgets.dart';

/// Step 2 of Diet Planner flow: Dietary Pattern, Non-veg days, and Allergies/Exclusions.
class DietPreferenceScreen extends StatefulWidget {
  final DietPreferences? initialPreferences;

  const DietPreferenceScreen({super.key, this.initialPreferences});

  @override
  State<DietPreferenceScreen> createState() => _DietPreferenceScreenState();
}

class _DietPreferenceScreenState extends State<DietPreferenceScreen> {
  String _selectedType = "Vegetarian";
  final TextEditingController _allergiesController = TextEditingController();
  final List<String> _days = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];
  final Set<String> _selectedDays = {"TU", "FR"};
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialPreferences != null) {
      final p = widget.initialPreferences!;
      switch (p.dietaryPattern) {
        case DietaryPattern.vegetarian:
          _selectedType = "Vegetarian";
          break;
        case DietaryPattern.nonVegetarian:
          _selectedType = "Non-veg";
          break;
        case DietaryPattern.both:
          _selectedType = "Both (Veg & Non-Veg)";
          break;
      }
      if (p.nonVegDays.isNotEmpty) {
        _selectedDays
          ..clear()
          ..addAll(p.nonVegDays);
      }
      if (p.allergiesAndExclusions.isNotEmpty) {
        _allergiesController.text = p.allergiesAndExclusions.join(', ');
      }
      if (p.medicalConditionNotes != null &&
          p.medicalConditionNotes!.isNotEmpty) {
        if (_allergiesController.text.isNotEmpty) {
          _allergiesController.text += ', ${p.medicalConditionNotes!}';
        } else {
          _allergiesController.text = p.medicalConditionNotes!;
        }
      }
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() => _validationError = null);

    if (_selectedType == "Both (Veg & Non-Veg)" && _selectedDays.isEmpty) {
      setState(
        () => _validationError = context.l10n.validationSelectNonVegDay,
      );
      return;
    }

    DietaryPattern pattern;
    if (_selectedType == "Vegetarian") {
      pattern = DietaryPattern.vegetarian;
    } else if (_selectedType == "Non-veg") {
      pattern = DietaryPattern.nonVegetarian;
    } else {
      pattern = DietaryPattern.both;
    }

    final rawInput = _allergiesController.text.trim();
    final tokens = rawInput
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final preferences = (widget.initialPreferences ?? const DietPreferences())
        .copyWith(
          dietaryPattern: pattern,
          nonVegDays: _selectedType == "Both (Veg & Non-Veg)"
              ? _selectedDays
              : {},
          allergiesAndExclusions: tokens,
          medicalConditionNotes: rawInput.isNotEmpty ? rawInput : null,
        );

    Navigator.pushNamed(context, AppRouter.healthGoal, arguments: preferences);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          DietPlannerHeader(
            title: context.l10n.dietPlannerTitle,
            subtitle: context.l10n.dietSectionSubtitle,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DietPlannerCard(
                title: context.l10n.dietStep2Title,
                icon: Icons.restaurant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPreferenceOption(
                          typeValue: "Vegetarian",
                          label: context.l10n.dietPatternVegetarian,
                          icon: const Icon(
                            Icons.eco_outlined,
                            color: Color(0xFF2C4E4E),
                            size: 30,
                          ),
                        ),
                        _buildPreferenceOption(
                          typeValue: "Non-veg",
                          label: context.l10n.dietPatternNonVegetarian,
                          icon: const FaIcon(
                            FontAwesomeIcons.drumstickBite,
                            color: Color(0xFF2C4E4E),
                            size: 30,
                          ),
                        ),
                        _buildPreferenceOption(
                          typeValue: "Both (Veg & Non-Veg)",
                          label: context.l10n.dietPatternBoth,
                          icon: const Icon(
                            Icons.rice_bowl_outlined,
                            color: Color(0xFF2C4E4E),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedType == "Both (Veg & Non-Veg)")
                      _buildDayPicker(),
                    const SizedBox(height: 35),
                    Text(
                      context.l10n.dietAllergiesOptional,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A6A6A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.dietSpecifyIngredientsPrompt,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomPaint(
                      painter: DashedBorderPainter(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _allergiesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: context.l10n.dietAllergiesHint,
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
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
                    const SizedBox(height: 40),
                    DietPlannerActionButton(
                      label: context.l10n.dietBtnContinueHealthGoals,
                      onPressed: _onContinue,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dietNonVegDaysPrompt,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _days.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => isSelected
                              ? _selectedDays.remove(day)
                              : _selectedDays.add(day),
                        ),
                        child: Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7CB9A8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF5A6A6A),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceOption({
    required String typeValue,
    required String label,
    required Widget icon,
  }) {
    final isSelected = _selectedType == typeValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = typeValue),
      child: Container(
        width: 100,
        constraints: const BoxConstraints(minHeight: 115),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F6F4),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: const Color(0xFF7CB9A8), width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 30, height: 30, child: icon),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
