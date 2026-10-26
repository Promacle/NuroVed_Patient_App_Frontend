import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/models/diet/diet_preferences.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';
import '../widgets/diet_planner_widgets.dart';

/// Step 3 of Diet Planner flow: Activity Level and Primary Health Goal.
class HealthGoalScreen extends StatefulWidget {
  final DietPreferences? initialPreferences;

  const HealthGoalScreen({super.key, this.initialPreferences});

  @override
  State<HealthGoalScreen> createState() => _HealthGoalScreenState();
}

class _HealthGoalScreenState extends State<HealthGoalScreen> {
  ActivityLevel? _selectedActivityLevel = ActivityLevel.moderate;
  HealthGoal? _selectedPrimaryGoal = HealthGoal.maintainWeight;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialPreferences != null) {
      final p = widget.initialPreferences!;
      _selectedActivityLevel = p.activityLevel;
      _selectedPrimaryGoal = p.primaryGoal;
    }
  }

  String _getActivityLevelLabel(BuildContext context, ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return context.l10n.dietActivitySedentary;
      case ActivityLevel.moderate:
        return context.l10n.dietActivityModerate;
      case ActivityLevel.heavyAthlete:
        return context.l10n.dietActivityAthlete;
    }
  }

  String _getGoalLabel(BuildContext context, HealthGoal goal) {
    switch (goal) {
      case HealthGoal.loseWeight:
        return context.l10n.dietGoalLose;
      case HealthGoal.maintainWeight:
        return context.l10n.dietGoalMaintain;
      case HealthGoal.muscleGain:
        return context.l10n.dietGoalGain;
    }
  }

  void _onContinue() {
    setState(() => _validationError = null);

    if (_selectedActivityLevel == null || _selectedPrimaryGoal == null) {
      setState(
        () => _validationError = context.l10n.dietValidationActivityGoal,
      );
      return;
    }

    final preferences = (widget.initialPreferences ?? const DietPreferences())
        .copyWith(
          activityLevel: _selectedActivityLevel!,
          primaryGoal: _selectedPrimaryGoal!,
        );

    Navigator.pushNamed(
      context,
      AppRouter.timeAndContext,
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
            subtitle: context.l10n.dietSectionSubtitle,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DietPlannerCard(
                title: context.l10n.dietStep3Title,
                icon: Icons.fitness_center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DietPlannerDropdown(
                      label: context.l10n.dietActivityLevelLabel,
                      hint: context.l10n.dietSelectActivityLevelHint,
                      options: ActivityLevel.values
                          .map((l) => _getActivityLevelLabel(context, l))
                          .toList(),
                      selectedValue: _selectedActivityLevel != null
                          ? _getActivityLevelLabel(
                              context,
                              _selectedActivityLevel!,
                            )
                          : null,
                      onSelected: (val) {
                        final level = ActivityLevel.values.firstWhere(
                          (l) => _getActivityLevelLabel(context, l) == val,
                          orElse: () => ActivityLevel.moderate,
                        );
                        setState(() {
                          _selectedActivityLevel = level;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    DietPlannerDropdown(
                      label: context.l10n.dietPrimaryGoalLabel,
                      hint: context.l10n.dietSelectPrimaryGoalHint,
                      options: HealthGoal.values
                          .map((g) => _getGoalLabel(context, g))
                          .toList(),
                      selectedValue: _selectedPrimaryGoal != null
                          ? _getGoalLabel(context, _selectedPrimaryGoal!)
                          : null,
                      onSelected: (val) {
                        final goal = HealthGoal.values.firstWhere(
                          (g) => _getGoalLabel(context, g) == val,
                          orElse: () => HealthGoal.maintainWeight,
                        );
                        setState(() {
                          _selectedPrimaryGoal = goal;
                        });
                      },
                    ),
                    if (_validationError != null) ...[
                      const SizedBox(height: 16),
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
                      label: context.l10n.dietBtnContinueTimeContext,
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
}
