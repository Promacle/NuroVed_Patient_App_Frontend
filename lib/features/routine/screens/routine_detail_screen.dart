import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/edit_routine_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_success_screen.dart';

import '../../settings/controllers/app_settings_controller.dart';

/// Redesigned, responsive, production-grade individual meal detail screen.
class RoutineDetailScreen extends StatelessWidget {
  final String title; // "Breakfast", "Lunch", "Dinner", etc.
  final String time;
  final String? mealName;
  final String? calories;
  final List<String>? ingredients;
  final String? protein;
  final String? carbs;
  final String? fat;
  final String? fiber;
  final dynamic instructions;
  final bool? isCompleted;

  const RoutineDetailScreen({
    super.key,
    required this.title,
    required this.time,
    this.mealName,
    this.calories,
    this.ingredients,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.instructions,
    this.isCompleted,
  });

  AppSettingsController get _settingsController => AppSettingsController();

  /// Resolves localized meal category title when matching standard routines.
  String _localizedMealTitle(BuildContext context, String rawTitle) {
    final lower = rawTitle.trim().toLowerCase();
    if (lower == 'breakfast') return context.l10n.dietMealBreakfast;
    if (lower == 'lunch') return context.l10n.dietMealLunch;
    if (lower == 'snack' || lower == 'evening snack') {
      return context.l10n.dietMealSnack;
    }
    if (lower == 'dinner') return context.l10n.dietMealDinner;
    return rawTitle;
  }

  @override
  Widget build(BuildContext context) {
    final controller = RoutineController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Fetch updated data from controller if available, else fall back gracefully to arguments
        final matchingMeal = controller.meals
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (m) => m != null && m['title'] == title,
              orElse: () => null,
            );

        final currentMealName =
            mealName ?? matchingMeal?['mealName'] as String? ?? "Unknown Meal";
        final currentIngredients =
            ingredients ??
            (matchingMeal != null && matchingMeal['ingredients'] != null
                ? List<String>.from(matchingMeal['ingredients'])
                : <String>[]);
        final currentCalories =
            calories ?? matchingMeal?['calories'] as String? ?? "N/A";
        final currentIsCompleted =
            isCompleted ?? matchingMeal?['isCompleted'] as bool? ?? false;
        final currentProtein = protein ?? matchingMeal?['protein']?.toString();
        final currentCarbs = carbs ?? matchingMeal?['carbs']?.toString();
        final currentFat = fat ?? matchingMeal?['fat']?.toString();
        final currentFiber = fiber ?? matchingMeal?['fiber']?.toString();
        final currentInstructions =
            instructions ?? matchingMeal?['instructions'];

        final displayTitle = _localizedMealTitle(context, title);
        final formattedTime = _settingsController.formatTime(time);

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                        context,
                        displayTitle,
                        formattedTime,
                        currentMealName,
                        currentIngredients,
                      ),
                      const SizedBox(height: 18),
                      _buildMealOverviewCard(
                        context,
                        displayTitle,
                        currentMealName,
                        currentCalories,
                        formattedTime,
                        currentIsCompleted,
                      ),
                      _buildNutritionCard(
                        context,
                        currentProtein,
                        currentCarbs,
                        currentFat,
                        currentFiber,
                      ),
                      _buildIngredientsCard(context, currentIngredients),
                      _buildInstructionsCard(context, currentInstructions),
                      const SizedBox(height: 24),
                      _buildActionButtons(
                        context,
                        controller,
                        displayTitle,
                        currentIsCompleted,
                      ),
                      const SizedBox(height: 16),
                    ],
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
    String displayTitle,
    String formattedTime,
    String mealName,
    List<String> ingredients,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              button: true,
              label: context.l10n.semanticsBack,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.sageGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF5A6A6A),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5A6A6A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Semantics(
              button: true,
              label: context.l10n.routineEditMeal,
              child: Tooltip(
                message: context.l10n.routineEditMeal,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.sageGreen,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(thickness: 1, color: Colors.black12),
      ],
    );
  }

  Widget _buildMealOverviewCard(
    BuildContext context,
    String displayTitle,
    String mealName,
    String calories,
    String formattedTime,
    bool isCompleted,
  ) {
    final hasCalories = calories != 'N/A' && calories.trim().isNotEmpty;
    final calorieDisplay = hasCalories
        ? (calories.toLowerCase().contains('cal') ||
                  calories.toLowerCase().contains('kcal')
              ? calories
              : '$calories kcal')
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF86EFAC).withValues(alpha: 0.6)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEDF6F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF2C4E4E),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF318686,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF004445),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 13,
                                color: isCompleted
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isCompleted
                                    ? context.l10n.routineStatusTaken
                                    : context.l10n.routineStatusPending,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            mealName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (calorieDisplay != null)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE4E6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 15,
                              color: Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                calorieDisplay,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFBE123C),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              context.l10n.routineScheduledTime(formattedTime),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
    BuildContext context,
    String? protein,
    String? carbs,
    String? fat,
    String? fiber,
  ) {
    final hasMacros =
        protein != null || carbs != null || fat != null || fiber != null;
    if (!hasMacros) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                size: 17,
                color: Color(0xFF2C4E4E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.dietNutritionOverview,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final chipMaxWidth = constraints.maxWidth;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (protein != null)
                    _buildMacroChip(
                      label: context.l10n.foodScannerProtein,
                      value: protein.contains('g') ? protein : '${protein}g',
                      bgColor: const Color(0xFFF0F9FF),
                      textColor: const Color(0xFF0369A1),
                      borderColor: const Color(0xFFBAE6FD),
                      maxWidth: chipMaxWidth,
                    ),
                  if (carbs != null)
                    _buildMacroChip(
                      label: context.l10n.foodScannerCarbs,
                      value: carbs.contains('g') ? carbs : '${carbs}g',
                      bgColor: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFFB45309),
                      borderColor: const Color(0xFFFDE68A),
                      maxWidth: chipMaxWidth,
                    ),
                  if (fat != null)
                    _buildMacroChip(
                      label: context.l10n.foodScannerFat,
                      value: fat.contains('g') ? fat : '${fat}g',
                      bgColor: const Color(0xFFFFF1F2),
                      textColor: const Color(0xFFBE123C),
                      borderColor: const Color(0xFFFFE4E6),
                      maxWidth: chipMaxWidth,
                    ),
                  if (fiber != null)
                    _buildMacroChip(
                      label: 'Fiber',
                      value: fiber.contains('g') ? fiber : '${fiber}g',
                      bgColor: const Color(0xFFECFDF5),
                      textColor: const Color(0xFF047857),
                      borderColor: const Color(0xFFA7F3D0),
                      maxWidth: chipMaxWidth,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    double? maxWidth,
  }) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (maxWidth != null && maxWidth > 0) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: chip,
      );
    }
    return chip;
  }

  Widget _buildIngredientsCard(BuildContext context, List<String> ingredients) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: Color(0xFF2C4E4E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.routineIngredients,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (ingredients.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF318686).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${ingredients.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004445),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (ingredients.isEmpty)
            Text(
              context.l10n.routineNoIngredients,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: ingredients.map((item) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2, right: 10),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF397D71),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context, dynamic instructions) {
    if (instructions == null) return const SizedBox.shrink();
    final String instructionText = instructions is List
        ? instructions.join('\n')
        : instructions.toString().trim();
    if (instructionText.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: Color(0xFF2C4E4E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.routineFieldInstructions,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            instructionText,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF334155),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RoutineController controller,
    String displayTitle,
    bool isCompleted,
  ) {
    return Column(
      children: [
        if (isCompleted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.routineMealCompleted,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () =>
                  _showIntakeConfirmation(context, controller, displayTitle),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Colors.black26,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.l10n.routineIntakeMeal(displayTitle),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
            ),
            child: Text(
              context.l10n.routineIgnoreAndSkip,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showIntakeConfirmation(
    BuildContext context,
    RoutineController controller,
    String displayTitle,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF16A34A),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  dialogCtx.l10n.routineConfirmMeal(displayTitle),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  dialogCtx.l10n.routineHaveYouFinishedMeal(displayTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text(
                          dialogCtx.l10n.routineNotYet,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sageGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // 1. Update the state
                          controller.intakeMeal(title);
                          // 2. Close the dialog
                          Navigator.pop(dialogCtx);
                          // 3. Navigate to the success screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RoutineSuccessScreen(),
                            ),
                          );
                        },
                        child: Text(
                          dialogCtx.l10n.routineYesDone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
