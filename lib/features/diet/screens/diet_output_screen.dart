import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/screens/diet_success_screen.dart';

import '../controllers/diet_controller.dart';
import '../widgets/diet_planner_widgets.dart';

class DietOutputScreen extends StatefulWidget {
  const DietOutputScreen({super.key});

  @override
  State<DietOutputScreen> createState() => _DietOutputScreenState();
}

class _DietOutputScreenState extends State<DietOutputScreen> {
  int _expandedDayIndex = 0; // Default Day 1 expanded

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 25),
                  _buildWeeklyMealPlanCard(), // Now in its own container
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            "Personalised Diet Plan For You",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryTile("Daily Calories", "2500", "Kcal"),
              _buildSummaryTile("Budget", "Low", ""),
              _buildSummaryTile("Health Goal", "Weight Loss", ""),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMealPlanCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyMealPlanHeader(),
          const SizedBox(height: 15),
          _buildWeeklyList(),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, String unit) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB9A8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: Text(
                      unit,
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMealPlanHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 5, top: 5),
      child: Row(
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
    );
  }

  Widget _buildWeeklyList() {
    final days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return Column(
      children: List.generate(days.length, (index) {
        return _buildDayItem(index + 1, days[index]);
      }),
    );
  }

  Widget _buildDayItem(int dayNum, String dayName) {
    final isExpanded = _expandedDayIndex == dayNum - 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedDayIndex = isExpanded ? -1 : dayNum - 1;
              });
            },
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
                children: [
                  _buildMealCard(
                    "BREAKFAST - 8:00 AM - 400 kcal",
                    "Oatmeal with Banana and Almond Milk",
                    ["Oats", "Almond Milk", "Banana"],
                  ),
                  const SizedBox(height: 15),
                  _buildMealCard(
                    "LUNCH - 12:00 AM - 550 kcal",
                    "Vegetable Wrap and Curd",
                    [
                      "Whole wheat tortilla",
                      "Cheese",
                      "Cucumber, tomato and boiled Potato",
                      "Curd",
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildMealCard(
                    "DINNER - 8:00 PM - 500 kcal",
                    "Vegetable Stir Fry",
                    ["Broccoli", "Carrot, onion and tomato", "Potato"],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String header, String title, List<String> ingredients) {
    return Container(
      width: double.infinity,
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
            onPressed: () {
              // 1. Save the Diet Plan data to the Controller
              DietController().saveDietPlan({
                "calories": "2500",
                "budget": "Low",
                "goal": "Weight Loss",
                "weeklyPlan": [
                  {
                    "dayName": "Monday",
                    "meals": [
                      {
                        "header": "BREAKFAST - 8:00 AM - 400 kcal",
                        "title": "Oatmeal with Banana and Almond Milk",
                        "ingredients": ["Oats", "Almond Milk", "Banana"],
                      },
                      {
                        "header": "LUNCH - 12:00 AM - 550 kcal",
                        "title": "Vegetable Wrap and Curd",
                        "ingredients": [
                          "Whole wheat tortilla",
                          "Cheese",
                          "Cucumber, tomato and boiled Potato",
                          "Curd",
                        ],
                      },
                      {
                        "header": "DINNER - 8:00 PM - 500 kcal",
                        "title": "Vegetable Stir Fry",
                        "ingredients": [
                          "Broccoli",
                          "Carrot, onion and tomato",
                          "Potato",
                        ],
                      },
                    ],
                  },
                  // Note: You can repeat this structure for Tuesday through Sunday
                ],
              });

              // 2. Navigate to the Success Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DietSuccessScreen(timestamp: DateTime.now()),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C4E4E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: const Text(
              "Add to Routine Meal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            // Pop all pages and return to the main Diet Screen
            Navigator.popUntil(
              context,
              (route) => route.settings.name == '/diet' || route.isFirst,
            );
          },
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey.shade400,
                style: BorderStyle.solid,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Ignore",
              style: TextStyle(
                fontSize: 16,
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
