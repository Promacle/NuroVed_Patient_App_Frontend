import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/edit_routine_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_success_screen.dart';

import '../../settings/controllers/app_settings_controller.dart';

class RoutineDetailScreen extends StatelessWidget {
  final String title; // "Breakfast", "Lunch", etc.
  final String time;
  final _settingsController = AppSettingsController();

  RoutineDetailScreen({
    super.key,
    required this.title,
    required this.time,
    // Optional parameters to prevent breaking existing code
    String? mealName,
    String? calories,
    List<String>? ingredients,
  });

  @override
  Widget build(BuildContext context) {
    final controller = RoutineController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Fetch the updated data from the controller to reflect edits/intake status
        final meal = controller.meals.firstWhere(
          (m) => m['title'] == title,
          orElse: () => {
            'mealName': 'Unknown Meal',
            'ingredients': [],
            'calories': 'N/A',
          },
        );

        final currentMealName = meal['mealName'] as String? ?? "Unknown Meal";
        final currentIngredients = List<String>.from(meal['ingredients'] ?? []);
        final currentCalories = meal['calories'] as String? ?? "N/A";

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 25,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(
                          context,
                          currentMealName,
                          currentIngredients,
                        ),
                        const SizedBox(height: 35),
                        _buildMealInfo(currentMealName, currentCalories),
                        const SizedBox(height: 45),
                        _buildIngredientsCard(currentIngredients),
                        const SizedBox(height: 40),
                        _buildActionButtons(
                          context,
                          controller,
                        ), // Fixed: Passing context and controller
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String mealName,
    List<String> ingredients,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: AppColors.white,
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.sageGreen,
                  size: 20,
                ),
              ),
            ),
            Text(
              "$title | ${_settingsController.formatTime(time)}", // Format the time here
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRoutineScreen(
                      title: title,
                      time: time,
                      mealName: mealName,
                      ingredients: ingredients,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.sageGreen,
                size: 32,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 1.2, color: Colors.grey),
      ],
    );
  }

  Widget _buildMealInfo(String mealName, String calories) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_outlined,
              color: Color(0xFF2C4E4E),
              size: 28,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                mealName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          calories,
          style: const TextStyle(
            color: Color(0xFF318686),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsCard(List<String> ingredients) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ingredients",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A6A6A),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ingredients
                  .map(
                    (item) => Text(
                      "• $item",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontFamily: 'serif',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RoutineController controller,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 65,
          child: ElevatedButton(
            onPressed: () {
              // Update progress in the controller
              controller.intakeMeal(title);

              // Navigate to the success screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoutineSuccessScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sageGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 8,
              shadowColor: Colors.black45,
            ),
            child: Text(
              "Intake $title",
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFFB0B0B0),
            borderRadius: BorderRadius.circular(22),
          ),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CustomPaint(
              painter: _DashedBorderPainter(),
              child: const Center(
                child: Text(
                  "Ignore and Skip",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(22),
        ),
      );

    double dashWidth = 5, dashSpace = 4, distance = 0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
