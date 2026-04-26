import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../widgets/diet_planner_widgets.dart';

class HealthGoalScreen extends StatefulWidget {
  const HealthGoalScreen({super.key});

  @override
  State<HealthGoalScreen> createState() => _HealthGoalScreenState();
}

class _HealthGoalScreenState extends State<HealthGoalScreen> {
  // Logic: Variables to hold the selected values from the dropdowns
  String? _selectedActivityLevel;
  String? _selectedPrimaryGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          // Custom header for the Diet Planner module
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
                    // Activity Level Dropdown
                    DietPlannerDropdown(
                      label: "Activity Level (One Selection)",
                      hint: "Select activity level",
                      options: const [
                        "Sedentary (office job, little exercise)",
                        "Moderate (Active 3-4 days a week)",
                        "Heavy athlete (Daily hard workout)",
                      ],
                      selectedValue: _selectedActivityLevel,
                      onSelected: (val) {
                        setState(() {
                          _selectedActivityLevel = val;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // Primary Goal Dropdown
                    DietPlannerDropdown(
                      label: "Primary Goal (One Selection)",
                      hint: "Select primary goal",
                      options: const [
                        "Lose Weight (Burn Fat & Get leaner)",
                        "Maintain weight (Stay fit & Healthy)",
                        "Muscle Gain (Build strength & mass)",
                      ],
                      selectedValue: _selectedPrimaryGoal,
                      onSelected: (val) {
                        setState(() {
                          _selectedPrimaryGoal = val;
                        });
                      },
                    ),
                    const SizedBox(height: 50),

                    // Final Action Button
                    DietPlannerActionButton(
                      label: "Continue",
                      onPressed: () {
                        // Implement AI generation logic or navigation to results here
                        if (_selectedActivityLevel != null &&
                            _selectedPrimaryGoal != null) {
                          Navigator.pushNamed(context, '/time-and-context');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select both goals to continue",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
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
