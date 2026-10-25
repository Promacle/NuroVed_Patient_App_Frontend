import 'package:flutter/material.dart';
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
  String? _selectedActivityLevel = "Moderate (Active 3-4 days a week)";
  String? _selectedPrimaryGoal = "Maintain weight (Stay fit & Healthy)";
  String? _validationError;

  static const List<String> _activityOptions = [
    "Sedentary (office job, little exercise)",
    "Moderate (Active 3-4 days a week)",
    "Heavy athlete (Daily hard workout)",
  ];

  static const List<String> _goalOptions = [
    "Lose Weight (Burn Fat & Get leaner)",
    "Maintain weight (Stay fit & Healthy)",
    "Muscle Gain (Build strength & mass)",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPreferences != null) {
      final p = widget.initialPreferences!;
      switch (p.activityLevel) {
        case ActivityLevel.sedentary:
          _selectedActivityLevel = _activityOptions[0];
          break;
        case ActivityLevel.moderate:
          _selectedActivityLevel = _activityOptions[1];
          break;
        case ActivityLevel.heavyAthlete:
          _selectedActivityLevel = _activityOptions[2];
          break;
      }
      switch (p.primaryGoal) {
        case HealthGoal.loseWeight:
          _selectedPrimaryGoal = _goalOptions[0];
          break;
        case HealthGoal.maintainWeight:
          _selectedPrimaryGoal = _goalOptions[1];
          break;
        case HealthGoal.muscleGain:
          _selectedPrimaryGoal = _goalOptions[2];
          break;
      }
    }
  }

  void _onContinue() {
    setState(() => _validationError = null);

    if (_selectedActivityLevel == null || _selectedPrimaryGoal == null) {
      setState(
        () => _validationError =
            "Please select both your activity level and primary goal.",
      );
      return;
    }

    ActivityLevel activity;
    if (_selectedActivityLevel == _activityOptions[0]) {
      activity = ActivityLevel.sedentary;
    } else if (_selectedActivityLevel == _activityOptions[2]) {
      activity = ActivityLevel.heavyAthlete;
    } else {
      activity = ActivityLevel.moderate;
    }

    HealthGoal goal;
    if (_selectedPrimaryGoal == _goalOptions[0]) {
      goal = HealthGoal.loseWeight;
    } else if (_selectedPrimaryGoal == _goalOptions[2]) {
      goal = HealthGoal.muscleGain;
    } else {
      goal = HealthGoal.maintainWeight;
    }

    final preferences = (widget.initialPreferences ?? const DietPreferences())
        .copyWith(activityLevel: activity, primaryGoal: goal);

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
          const DietPlannerHeader(
            title: "Ai Diet Planner",
            subtitle: "Calculate Your Every Single Bite",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DietPlannerCard(
                title: "Health Goal",
                icon: Icons.fitness_center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DietPlannerDropdown(
                      label: "Activity Level (One Selection)",
                      hint: "Select activity level",
                      options: _activityOptions,
                      selectedValue: _selectedActivityLevel,
                      onSelected: (val) {
                        setState(() {
                          _selectedActivityLevel = val;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    DietPlannerDropdown(
                      label: "Primary Goal (One Selection)",
                      hint: "Select primary goal",
                      options: _goalOptions,
                      selectedValue: _selectedPrimaryGoal,
                      onSelected: (val) {
                        setState(() {
                          _selectedPrimaryGoal = val;
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
                      label: "Continue to Time & Context",
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
