import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../app/app_router.dart';
import '../widgets/diet_planner_widgets.dart';

class DietPreferenceScreen extends StatefulWidget {
  const DietPreferenceScreen({super.key});

  @override
  State<DietPreferenceScreen> createState() => _DietPreferenceScreenState();
}

class _DietPreferenceScreenState extends State<DietPreferenceScreen> {
  String _selectedType = "Vegetarian";
  final TextEditingController _allergiesController = TextEditingController();
  final List<String> _days = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];
  final Set<String> _selectedDays = {"TU", "FR"};

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
                title: "Diet Preference",
                icon: Icons.restaurant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPreferenceOption(
                          "Vegetarian",
                          Icons.eco_outlined,
                        ),
                        _buildPreferenceOption(
                          "Non-veg",
                          FontAwesomeIcons.drumstickBite,
                        ),
                        _buildPreferenceOption(
                          "Both (Veg & Non-Veg)",
                          Icons.rice_bowl_outlined,
                        ),
                      ],
                    ),
                    if (_selectedType != "Vegetarian") _buildDayPicker(),
                    const SizedBox(height: 35),
                    const Text(
                      "Allergies / Medical Condition (Optional)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A6A6A),
                      ),
                    ),
                    const SizedBox(height: 15),
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
                          decoration: const InputDecoration(
                            hintText:
                                "e.g., Peanuts, Gluten, Dairy intolerance, Diabetes...",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    DietPlannerActionButton(
                      label: "Continue",
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.healthGoal),
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
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pick a day you prefer non-veg",
                style: TextStyle(
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
                          margin: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ), // Added small horizontal margin
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
                              fontSize: 9,
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

  Widget _buildPreferenceOption(String label, IconData icon) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        width: 95,
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F6F4),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: const Color(0xFF7CB9A8), width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2C4E4E), size: 30),
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
