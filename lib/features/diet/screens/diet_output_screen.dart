import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/models/diet/diet_preferences.dart';
import 'package:nuroved_patient/core/models/diet/meal_recipe.dart';
import 'package:nuroved_patient/core/services/diet/diet_planning_engine.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';

import '../widgets/diet_planner_widgets.dart';

/// Step 5: Plan Results Screen displaying the full interactive 7-day nutritional meal plan.
class DietOutputScreen extends StatefulWidget {
  final WeeklyDietPlan? initialPlan;
  final DietPreferences? preferences;

  const DietOutputScreen({super.key, this.initialPlan, this.preferences});

  @override
  State<DietOutputScreen> createState() => _DietOutputScreenState();
}

class _DietOutputScreenState extends State<DietOutputScreen> {
  final DietController _dietController = DietController();
  late WeeklyDietPlan _plan;
  late DietPreferences _preferences;
  int _selectedDayIndex = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? const DietPreferences();
    if (widget.initialPlan != null) {
      _plan = widget.initialPlan!;
    } else {
      // Generate a default plan if opened directly without arguments
      final engine = const DietPlanningEngine();
      final res = engine.generatePlan(_preferences);
      if (res is DietPlanSuccess) {
        _plan = res.plan;
      } else {
        // Fallback default
        _plan =
            (engine.generatePlan(const DietPreferences()) as DietPlanSuccess)
                .plan;
      }
    }
  }

  void _regeneratePlan() {
    final engine = const DietPlanningEngine();
    final res = engine.generatePlan(_preferences);
    if (res is DietPlanSuccess) {
      setState(() {
        _plan = res.plan;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.dietRegeneratedSuccess),
          backgroundColor: AppColors.primaryTeal,
        ),
      );
    }
  }

  Future<void> _savePlanToRoutine() async {
    setState(() => _isSaving = true);
    final routineMap = _plan.toRoutineMap();

    await _dietController.saveDietPlanAsync(routineMap);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.dietSavedToRoutineSuccess),
        backgroundColor: AppColors.primaryTeal,
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      AppRouter.dietSuccess,
      arguments: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = _plan.days[_selectedDayIndex];

    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          DietPlannerHeader(
            title: context.l10n.dietOutputTitle,
            subtitle: context.l10n.dietVerifiedNutritionalPlanning,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalorieGuidanceHeader(),
                  const SizedBox(height: 16),
                  _buildDaySelectorBar(),
                  const SizedBox(height: 16),
                  _buildDailyNutritionSummary(currentDay),
                  const SizedBox(height: 16),
                  _buildMealCard(
                    categoryTitle: context.l10n.dietMealBreakfast,
                    timeBadge: "8:00 AM",
                    recipe: currentDay.breakfast,
                    icon: Icons.wb_sunny_outlined,
                    initiallyExpanded: true,
                  ),
                  _buildMealCard(
                    categoryTitle: context.l10n.dietMealLunch,
                    timeBadge: "1:00 PM",
                    recipe: currentDay.lunch,
                    icon: Icons.wb_twilight_outlined,
                    initiallyExpanded: true,
                  ),
                  _buildMealCard(
                    categoryTitle: context.l10n.dietMealSnack,
                    timeBadge: "5:00 PM",
                    recipe: currentDay.snack,
                    icon: Icons.coffee_outlined,
                    initiallyExpanded: false,
                  ),
                  _buildMealCard(
                    categoryTitle: context.l10n.dietMealDinner,
                    timeBadge: "8:00 PM",
                    recipe: currentDay.dinner,
                    icon: Icons.nightlight_outlined,
                    initiallyExpanded: false,
                  ),
                  const SizedBox(height: 14),
                  _buildClinicalDisclaimerCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieGuidanceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7E2D9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFC7E2D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Color(0xFF2C4E4E),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "~${_plan.estimatedDailyCaloricTarget} kcal / day",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Informational",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _plan.caloricEquationMethod,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5A6A6A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelectorBar() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _plan.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          final day = _plan.days[index];
          return Semantics(
            button: true,
            label: context.l10n.dietDayNumberName(index + 1, day.dayName),
            selected: isSelected,
            child: GestureDetector(
              onTap: () => setState(() => _selectedDayIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryTeal : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryTeal
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryTeal.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.dayCode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2C4E4E),
                      ),
                    ),
                    Text(
                      context.l10n.dietDayNumber(index + 1),
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected ? Colors.white70 : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyNutritionSummary(MealPlanDay day) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${day.dayName} ${context.l10n.dietNutritionOverview}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              Text(
                context.l10n.dietTotalCaloriesKcal(day.totalCalories),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroChip(
                context.l10n.foodScannerProteins,
                "${day.totalProtein.toStringAsFixed(0)}g",
              ),
              _buildMacroChip(
                context.l10n.foodScannerCarbs,
                "${day.totalCarbs.toStringAsFixed(0)}g",
              ),
              _buildMacroChip(
                context.l10n.foodScannerTotalFat,
                "${day.totalFat.toStringAsFixed(0)}g",
              ),
              _buildMacroChip(
                context.l10n.foodScannerFiber,
                "${day.totalFiber.toStringAsFixed(0)}g",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4E4E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String categoryTitle,
    required String timeBadge,
    required MealRecipe recipe,
    required IconData icon,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const Border(),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2EF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2C4E4E), size: 20),
        ),
        title: Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4E4E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$categoryTitle • $timeBadge",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${recipe.nutrition.calories} kcal",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 16),
                Text(
                  context.l10n.dietIngredientsAndPortions,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                ...recipe.ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(color: AppColors.primaryTeal),
                        ),
                        Expanded(
                          child: Text(
                            ing,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF334155),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.dietEstimatedNutritionPerServing,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildNutrientPill(
                      context.l10n.dietProtein(
                        recipe.nutrition.proteinGrams.toString(),
                      ),
                    ),
                    _buildNutrientPill(
                      context.l10n.dietCarbs(
                        recipe.nutrition.carbGrams.toString(),
                      ),
                    ),
                    _buildNutrientPill(
                      context.l10n.dietFat(
                        recipe.nutrition.fatGrams.toString(),
                      ),
                    ),
                    _buildNutrientPill(
                      context.l10n.dietFiber(
                        recipe.nutrition.fiberGrams.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.dietPreparationNote,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.instructions,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                if (recipe.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recipe.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildClinicalDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 16,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.dietClinicalReferenceNotice,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _plan.clinicalDisclaimer,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.dietGuidelinesAttribution,
            style: const TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: Color(0xFF94A3B8),
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
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C4E4E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isSaving ? null : _savePlanToRoutine,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    context.l10n.dietSaveToRoutineButton,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2C4E4E),
                  side: const BorderSide(color: Color(0xFF2C4E4E)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _regeneratePlan,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.dietRegenerateButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5A6A6A),
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.dietEditInputsButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.popUntil(
              context,
              (route) => route.settings.name == AppRouter.diet || route.isFirst,
            );
          },
          child: Text(
            context.l10n.dietBackToOverviewButton,
            style: const TextStyle(
              color: Color(0xFF5A6A6A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
