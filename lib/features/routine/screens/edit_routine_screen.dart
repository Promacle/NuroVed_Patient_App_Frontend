import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';

class EditRoutineScreen extends StatefulWidget {
  final String title;
  final String time;
  final String mealName;
  final List<String> ingredients;

  const EditRoutineScreen({
    super.key,
    required this.title,
    required this.time,
    required this.mealName,
    required this.ingredients,
  });

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  late TextEditingController _mealNameController;
  late List<TextEditingController> _ingredientControllers;
  bool _isEditingMealName = false;

  @override
  void initState() {
    super.initState();
    _mealNameController = TextEditingController(text: widget.mealName);
    _ingredientControllers = widget.ingredients
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveMeal() {
    final newIngredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    RoutineController().updateMeal(
      widget.title,
      _mealNameController.text.trim(),
      newIngredients,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 35),
                    _buildMealNameSection(),
                    const SizedBox(height: 45),
                    _buildIngredientsSection(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            Expanded(
              child: Text(
                "${widget.title} | ${widget.time}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
                overflow:
                    TextOverflow.ellipsis, // Added ellipsis to prevent overflow
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 1.2, color: Colors.grey),
      ],
    );
  }

  Widget _buildMealNameSection() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
      child: CustomPaint(
        painter: _DashedBorderPainter(radius: 22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.restaurant_outlined,
                color: Color(0xFF2C4E4E),
                size: 28,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _isEditingMealName
                    ? TextField(
                        controller: _mealNameController,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) =>
                            setState(() => _isEditingMealName = false),
                      )
                    : Text(
                        _mealNameController.text,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _isEditingMealName = !_isEditingMealName),
                child: Icon(
                  _isEditingMealName ? Icons.check : Icons.edit_note_rounded,
                  color: AppColors.sageGreen,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            // Removed the edit icon from here
            "Ingredients",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A6A6A),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_ingredientControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 8),
              child: Row(
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ingredientControllers[index],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontFamily: 'serif',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: "Add ingredient...",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _ingredientControllers.removeAt(index)),
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => setState(
                () => _ingredientControllers.add(TextEditingController()),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(radius: 20, color: Colors.grey),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Text(
                      "+ Add More",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
      height: 65,
      child: ElevatedButton(
        onPressed: _saveMeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 8,
        ),
        child: const Text(
          "Save Meal",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  _DashedBorderPainter({this.radius = 22, this.color = Colors.black38});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
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
