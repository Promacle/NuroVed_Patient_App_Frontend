import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';
import 'package:nuroved_patient/features/diet/widgets/diet_planner_widgets.dart';

class EditMealScreen extends StatefulWidget {
  const EditMealScreen({super.key});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final DietController _dietController = DietController();
  late Map<String, dynamic> _localPlan;
  int _expandedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Create a deep copy of the current plan to edit locally
    final originalPlan = _dietController.savedDietPlan ?? {};
    _localPlan = Map<String, dynamic>.from(originalPlan);
    if (_localPlan['weeklyPlan'] != null) {
      _localPlan['weeklyPlan'] = (originalPlan['weeklyPlan'] as List)
          .map(
            (day) => {
              'dayName': day['dayName'],
              'meals': (day['meals'] as List)
                  .map(
                    (meal) => {
                      'header': meal['header'],
                      'title': meal['title'],
                      'ingredients': List<String>.from(meal['ingredients']),
                    },
                  )
                  .toList(),
            },
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          const DietPlannerHeader(
            title: "Edit Meal",
            subtitle: "Check Out Your Meal Routine And Edit",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF7CB9A8),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Weekly Meal Plan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildWeeklyList(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyList() {
    final List weeklyPlan = _localPlan['weeklyPlan'] ?? [];
    return Column(
      children: List.generate(weeklyPlan.length, (index) {
        final dayData = weeklyPlan[index];
        return _buildDayItem(index + 1, dayData['dayName'], dayData['meals']);
      }),
    );
  }

  Widget _buildDayItem(int dayNum, String dayName, List meals) {
    final isExpanded = _expandedDayIndex == dayNum - 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded
            ? const Color(0xFFE8F2EF).withOpacity(0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: isExpanded ? const EdgeInsets.all(15) : EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(
              () => _expandedDayIndex = isExpanded ? -1 : dayNum - 1,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF7CB9A8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Day $dayNum $dayName",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                children: meals.map((m) => _buildEditableMealCard(m)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableMealCard(Map<String, dynamic> meal) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB9A8).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Header (e.g., BREAKFAST - 8:00 AM)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              meal['header'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Editable Title with Dashed Border
          CustomPaint(
            painter: DashedBorderPainter(color: Colors.white.withOpacity(0.6)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                initialValue: meal['title'],
                onChanged: (val) => meal['title'] = val,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            "INGREDIENTS:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          // Editable Ingredients List with Dashed Border
          CustomPaint(
            painter: DashedBorderPainter(color: Colors.white.withOpacity(0.6)),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(meal['ingredients'].length, (idx) {
                    return Row(
                      children: [
                        const Text("• ", style: TextStyle(color: Colors.white)),
                        Expanded(
                          child: TextFormField(
                            initialValue: meal['ingredients'][idx],
                            onChanged: (val) => meal['ingredients'][idx] = val,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  GestureDetector(
                    onTap: () => setState(() => meal['ingredients'].add("")),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "+ Add More",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          _dietController.saveDietPlan(_localPlan);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C4E4E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "Save Routine",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Small update to existing painter to allow custom colors
class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({this.color = const Color(0xFF7CB9A8)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 3), paint);
        distance += 5;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
