import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';
import '../widgets/diet_planner_widgets.dart';

class TimeAndContextScreen extends StatefulWidget {
  const TimeAndContextScreen({super.key});

  @override
  State<TimeAndContextScreen> createState() => _TimeAndContextScreenState();
}

class _TimeAndContextScreenState extends State<TimeAndContextScreen> {
  final TextEditingController _mealTimingController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _anythingElseController = TextEditingController();

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
                title: "Time & Context",
                icon: Icons.fitness_center_outlined, // Matching icon from image
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Meal Timing / Skip Times (Optional)"),
                    _buildDashedInputField(
                      _mealTimingController,
                      "e.g., Skip Breakfast, Intermittent Fasting 16:8",
                    ),
                    const SizedBox(height: 25),

                    _buildLabel(
                      "Monthly Budget For Groceries / Food (Optional)",
                    ),
                    _buildDashedInputField(
                      _budgetController,
                      "e.g., Skip Breakfast, Intermittent Fasting 16:8",
                    ),
                    const SizedBox(height: 25),

                    _buildLabel("Anything Else? (Context-Aware) (Optional)"),
                    _buildDashedInputField(
                      _anythingElseController,
                      "Additional details that would help the Ai provide better plan....",
                      maxLines: 5,
                    ),
                    const SizedBox(height: 50),

                    DietPlannerActionButton(
                      label: "Continue",
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.dietOutput);
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5A6A6A),
        ),
      ),
    );
  }

  Widget _buildDashedInputField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Color(0xFF2C4E4E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.black26),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
