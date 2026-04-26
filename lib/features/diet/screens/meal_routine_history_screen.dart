import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';

import '../widgets/diet_planner_widgets.dart';

class MealRoutineHistoryScreen extends StatefulWidget {
  const MealRoutineHistoryScreen({super.key});

  @override
  State<MealRoutineHistoryScreen> createState() =>
      _MealRoutineHistoryScreenState();
}

class _MealRoutineHistoryScreenState extends State<MealRoutineHistoryScreen> {
  final DietController _dietController = DietController();
  int _expandedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final plan = _dietController.savedDietPlan;

    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          const DietPlannerHeader(
            title: "Meal Routine History",
            subtitle: "Check Out Your Meal Routine And Edit",
          ),
          Expanded(
            child: plan == null
                ? const Center(child: Text("No diet plan saved yet."))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildWeeklyMealPlanCard(plan),
                        const SizedBox(height: 30),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMealPlanCard(Map<String, dynamic> plan) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EF).withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 15),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeeklyHeader(),
          const SizedBox(height: 15),
          _buildWeeklyList(plan['weeklyPlan'] ?? []),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF7CB9A8),
                size: 24,
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
          // Inside _buildWeeklyHeader()
          IconButton(
            icon: const Icon(Icons.edit_note, color: Color(0xFF2C4E4E)),
            onPressed: () =>
                Navigator.pushNamed(context, '/edit-meal'), // Add this
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyList(List weeklyPlan) {
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    spreadRadius: -2,
                  ),
                ],
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Column(
                children: meals
                    .map(
                      (m) => _buildMealCard(
                        m['header'],
                        m['title'],
                        List<String>.from(m['ingredients']),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String header, String title, List<String> ingredients) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB9A8).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              header,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
          const SizedBox(height: 4),
          ...ingredients.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: null, // Done button disabled/non-working as requested
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C4E4E),
              disabledBackgroundColor: const Color(0xFF2C4E4E).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Done",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            _dietController.deleteDietPlan();
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Delete",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A6A6A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
