import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/models/diet/diet_preferences.dart';
import 'package:nuroved_patient/core/models/diet/meal_recipe.dart';
import 'package:nuroved_patient/core/services/diet/diet_planning_engine.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';
import '../widgets/diet_planner_widgets.dart';

/// Step 4 of Diet Planner flow: Meal Timing, Budget, and Practical Cooking Context.
/// Triggers deterministic generation via DietPlanningEngine with clinical safety screen.
class TimeAndContextScreen extends StatefulWidget {
  final DietPreferences? initialPreferences;
  final DietPlanningEngine? engine;

  const TimeAndContextScreen({super.key, this.initialPreferences, this.engine});

  @override
  State<TimeAndContextScreen> createState() => _TimeAndContextScreenState();
}

class _TimeAndContextScreenState extends State<TimeAndContextScreen> {
  final TextEditingController _mealTimingController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _anythingElseController = TextEditingController();

  late final DietPlanningEngine _engine;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _engine = widget.engine ?? const DietPlanningEngine();
    if (widget.initialPreferences != null) {
      final p = widget.initialPreferences!;
      if (p.mealTiming != null) _mealTimingController.text = p.mealTiming!;
      if (p.practicalContext != null) {
        _anythingElseController.text = p.practicalContext!;
      }
    }
  }

  @override
  void dispose() {
    _mealTimingController.dispose();
    _budgetController.dispose();
    _anythingElseController.dispose();
    super.dispose();
  }

  void _onGeneratePlan() {
    setState(() => _isGenerating = true);

    final finalPreferences =
        (widget.initialPreferences ?? const DietPreferences()).copyWith(
          mealTiming: _mealTimingController.text.trim().isNotEmpty
              ? _mealTimingController.text.trim()
              : null,
          practicalContext: _anythingElseController.text.trim().isNotEmpty
              ? _anythingElseController.text.trim()
              : null,
        );

    final result = _engine.generatePlan(finalPreferences);

    setState(() => _isGenerating = false);

    if (result is DietPlanClinicalSupervisionRequired) {
      _showClinicalSafetyDialog(result);
    } else if (result is DietPlanInsufficientRecipes) {
      _showInsufficientRecipesDialog(result.message);
    } else if (result is DietPlanSuccess) {
      Navigator.pushNamed(
        context,
        AppRouter.dietOutput,
        arguments: {'plan': result.plan, 'preferences': finalPreferences},
      );
    }
  }

  void _showClinicalSafetyDialog(
    DietPlanClinicalSupervisionRequired supervision,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.health_and_safety,
              color: Color(0xFFDC2626),
              size: 26,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Clinical Supervision Notice",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Condition: ${supervision.detectedCondition}",
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              supervision.explanation,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              supervision.recommendation,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.popUntil(
                context,
                (route) =>
                    route.settings.name == AppRouter.diet || route.isFirst,
              );
            },
            child: const Text("Return to Diet Overview"),
          ),
        ],
      ),
    );
  }

  void _showInsufficientRecipesDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Notice: Constraints Too Restrictive"),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Adjust Exclusions"),
          ),
        ],
      ),
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
                title: "Time & Context",
                icon: Icons.access_time_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Meal Timing / Fasting Preferences (Optional)"),
                    _buildDashedInputField(
                      _mealTimingController,
                      "e.g., Skip Breakfast, Intermittent Fasting 16:8, or Regular 4 meals",
                    ),
                    const SizedBox(height: 25),
                    _buildLabel("Monthly Grocery Budget Level (Optional)"),
                    _buildDashedInputField(
                      _budgetController,
                      "e.g., Budget-friendly, Standard, or Flexible",
                    ),
                    const SizedBox(height: 25),
                    _buildLabel(
                      "Practical Cooking & Availability Context (Optional)",
                    ),
                    _buildDashedInputField(
                      _anythingElseController,
                      "e.g., Prefer 15-minute quick prep, family meals, no microwave...",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 40),
                    if (_isGenerating)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      )
                    else
                      DietPlannerActionButton(
                        label: "Generate Verified Diet Plan",
                        onPressed: _onGeneratePlan,
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
