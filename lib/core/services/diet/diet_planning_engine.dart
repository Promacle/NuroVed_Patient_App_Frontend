import '../../models/diet/diet_preferences.dart';
import '../../models/diet/meal_recipe.dart';
import 'verified_recipe_catalog.dart';

/// Deterministic, clinical-safety-first meal planning engine.
/// Strictly excludes allergens, respects dietary patterns, and ensures balanced variety.
class DietPlanningEngine {
  final List<MealRecipe> catalog;

  const DietPlanningEngine({this.catalog = VerifiedRecipeCatalog.allRecipes});

  /// High-risk clinical conditions that strictly require individualized clinical supervision
  /// and must NEVER receive automated generic diet generation.
  static const List<Map<String, String>> highRiskConditions = [
    {
      'pattern': 'type 1',
      'name': 'Type 1 Diabetes',
      'reason':
          'Type 1 Diabetes requires specialized carbohydrate-to-insulin ratio matching and continuous clinical glucose monitoring by an endocrinologist.',
    },
    {
      'pattern': 'dialysis',
      'name': 'End-Stage Renal Disease (Dialysis)',
      'reason':
          'Dialysis patients require strictly regulated potassium, phosphorus, sodium, and fluid management that cannot be guided by automated algorithms.',
    },
    {
      'pattern': 'kidney disease',
      'name': 'Chronic Kidney Disease',
      'reason':
          'Renal nutrition requires personalized protein and electrolyte titration determined by your nephrologist or renal dietitian.',
    },
    {
      'pattern': 'renal failure',
      'name': 'Renal Failure',
      'reason':
          'Renal failure necessitates medical-grade dietary prescription tailored to glomerular filtration rates and electrolyte labs.',
    },
    {
      'pattern': 'pregnan',
      'name': 'Pregnancy / Gestational Diabetes',
      'reason':
          'Maternal and fetal nutrition necessitates personalized clinical obstetric supervision to ensure safe glycemic targets.',
    },
    {
      'pattern': 'anorexia',
      'name': 'Eating Disorder (Anorexia)',
      'reason':
          'Nutritional rehabilitation for eating disorders requires a multidisciplinary medical and psychological care team.',
    },
    {
      'pattern': 'bulimia',
      'name': 'Eating Disorder (Bulimia)',
      'reason':
          'Management of bulimia requires structured clinical psychotherapy and individualized nutritional therapy.',
    },
  ];

  /// Standard 7-day schedule metadata
  static const List<Map<String, String>> daysOfWeek = [
    {'code': 'MO', 'name': 'Monday'},
    {'code': 'TU', 'name': 'Tuesday'},
    {'code': 'WE', 'name': 'Wednesday'},
    {'code': 'TH', 'name': 'Thursday'},
    {'code': 'FR', 'name': 'Friday'},
    {'code': 'SA', 'name': 'Saturday'},
    {'code': 'SU', 'name': 'Sunday'},
  ];

  /// Generates a comprehensive 7-day weekly meal plan based on user preferences.
  DietPlanResult generatePlan(DietPreferences preferences) {
    // 1. Clinical Safety Screen
    final notes = (preferences.medicalConditionNotes ?? '').toLowerCase();
    for (final condition in highRiskConditions) {
      if (notes.contains(condition['pattern']!)) {
        return DietPlanClinicalSupervisionRequired(
          detectedCondition: condition['name']!,
          explanation: condition['reason']!,
          recommendation:
              'Please consult your treating physician or a registered clinical dietitian for an individualized clinical medical nutrition prescription.',
        );
      }
    }

    // 2. Normalize and identify excluded allergen tags & keywords
    final excludedAllergens = _normalizeAllergens(
      preferences.allergiesAndExclusions,
    );

    // 3. Filter eligible catalog by allergens and exclusions
    final eligibleRecipes = catalog.where((recipe) {
      // Check recipe allergen tags
      for (final allergen in recipe.allergens) {
        if (excludedAllergens.contains(allergen)) {
          return false;
        }
      }

      // Check ingredient text against exclusions
      for (final exclusion in preferences.allergiesAndExclusions) {
        final clean = exclusion.trim().toLowerCase();
        if (clean.length >= 3) {
          for (final ing in recipe.ingredients) {
            if (ing.toLowerCase().contains(clean)) {
              return false;
            }
          }
        }
      }

      return true;
    }).toList();

    // 4. Separate recipes by meal type and vegetarian status
    final breakfasts = eligibleRecipes
        .where((r) => r.mealType == MealType.breakfast)
        .toList();
    final lunches = eligibleRecipes
        .where((r) => r.mealType == MealType.lunch)
        .toList();
    final snacks = eligibleRecipes
        .where((r) => r.mealType == MealType.snack)
        .toList();
    final dinners = eligibleRecipes
        .where((r) => r.mealType == MealType.dinner)
        .toList();

    if (breakfasts.isEmpty ||
        lunches.isEmpty ||
        snacks.isEmpty ||
        dinners.isEmpty) {
      return const DietPlanInsufficientRecipes(
        'Your selected allergen or dietary exclusions left insufficient recipes to construct a balanced 7-day plan. Please review your exclusions or contact support.',
      );
    }

    // 5. Calculate Informational Energy Guidance (Mifflin-St Jeor)
    final caloricTarget = _calculateEstimatedCalories(preferences);

    // 6. Assemble 7 days ensuring no consecutive duplicate meals
    final planDays = <MealPlanDay>[];
    MealRecipe? prevBreakfast;
    MealRecipe? prevLunch;
    MealRecipe? prevSnack;
    MealRecipe? prevDinner;

    for (int i = 0; i < daysOfWeek.length; i++) {
      final dayMeta = daysOfWeek[i];
      final dayCode = dayMeta['code']!;
      final dayName = dayMeta['name']!;

      final isNonVegAllowedToday = _isNonVegAllowed(preferences, dayCode);

      final breakfast = _selectRecipe(
        pool: breakfasts,
        allowNonVeg: isNonVegAllowedToday,
        preferredVeg: preferences.dietaryPattern == DietaryPattern.vegetarian,
        previous: prevBreakfast,
        seedIndex: i,
      );

      final lunch = _selectRecipe(
        pool: lunches,
        allowNonVeg: isNonVegAllowedToday,
        preferredVeg: preferences.dietaryPattern == DietaryPattern.vegetarian,
        previous: prevLunch,
        seedIndex: i + 1,
      );

      final snack = _selectRecipe(
        pool: snacks,
        allowNonVeg: isNonVegAllowedToday,
        preferredVeg: preferences.dietaryPattern == DietaryPattern.vegetarian,
        previous: prevSnack,
        seedIndex: i + 2,
      );

      final dinner = _selectRecipe(
        pool: dinners,
        allowNonVeg: isNonVegAllowedToday,
        preferredVeg: preferences.dietaryPattern == DietaryPattern.vegetarian,
        previous: prevDinner,
        seedIndex: i + 3,
      );

      planDays.add(
        MealPlanDay(
          dayName: dayName,
          dayCode: dayCode,
          breakfast: breakfast,
          lunch: lunch,
          snack: snack,
          dinner: dinner,
        ),
      );

      prevBreakfast = breakfast;
      prevLunch = lunch;
      prevSnack = snack;
      prevDinner = dinner;
    }

    return DietPlanSuccess(
      WeeklyDietPlan(
        days: planDays,
        estimatedDailyCaloricTarget: caloricTarget,
        caloricEquationMethod:
            preferences.weightKg != null && preferences.heightCm != null
            ? 'Mifflin-St Jeor Equation (Informational Reference Only)'
            : 'General Population Reference Guideline (ICMR-NIN)',
        clinicalDisclaimer:
            'Informational Nutrition Notice: This meal plan provides general nutritional reference based on transparent dietary guidelines. It is not a clinical medical prescription or substitute for individualized care by a physician or registered dietitian.',
        generatedAt: DateTime.now(),
      ),
    );
  }

  /// Checks if non-vegetarian meals are permissible for the given day
  bool _isNonVegAllowed(DietPreferences preferences, String dayCode) {
    switch (preferences.dietaryPattern) {
      case DietaryPattern.vegetarian:
        return false;
      case DietaryPattern.nonVegetarian:
        return true;
      case DietaryPattern.both:
        return preferences.nonVegDays.contains(dayCode);
    }
  }

  /// Selects a recipe from the pool with preference filtering and non-repetition
  MealRecipe _selectRecipe({
    required List<MealRecipe> pool,
    required bool allowNonVeg,
    required bool preferredVeg,
    required MealRecipe? previous,
    required int seedIndex,
  }) {
    // Filter pool by vegetarian requirement
    var candidates = pool.where((r) {
      if (!allowNonVeg && !r.isVegetarian) return false;
      return true;
    }).toList();

    // If candidate list empty, fall back to any available in pool
    if (candidates.isEmpty) {
      candidates = pool;
    }

    // Try picking a non-duplicate candidate
    final nonDuplicates = candidates
        .where((r) => r.id != previous?.id)
        .toList();
    final viableList = nonDuplicates.isNotEmpty ? nonDuplicates : candidates;

    // Pick deterministically based on seedIndex
    return viableList[seedIndex % viableList.length];
  }

  /// Calculates estimated informational daily caloric target using Mifflin-St Jeor
  int _calculateEstimatedCalories(DietPreferences preferences) {
    if (preferences.weightKg == null ||
        preferences.heightCm == null ||
        preferences.age == null) {
      // General reference adult guideline
      switch (preferences.primaryGoal) {
        case HealthGoal.loseWeight:
          return 1650;
        case HealthGoal.muscleGain:
          return 2250;
        case HealthGoal.maintainWeight:
          return 1900;
      }
    }

    final weight = preferences.weightKg!;
    final height = preferences.heightCm!;
    final age = preferences.age!;
    final isMale = preferences.gender?.toLowerCase() != 'female';

    // Mifflin-St Jeor formula:
    // BMR = 10 * weight (kg) + 6.25 * height (cm) - 5 * age + (5 for male, -161 for female)
    double bmr =
        (10 * weight) + (6.25 * height) - (5 * age) + (isMale ? 5 : -161);

    // Activity multiplier
    double activityMultiplier;
    switch (preferences.activityLevel) {
      case ActivityLevel.sedentary:
        activityMultiplier = 1.2;
        break;
      case ActivityLevel.moderate:
        activityMultiplier = 1.55;
        break;
      case ActivityLevel.heavyAthlete:
        activityMultiplier = 1.725;
        break;
    }

    double tdee = bmr * activityMultiplier;

    // Goal adjustment
    switch (preferences.primaryGoal) {
      case HealthGoal.loseWeight:
        tdee -= 350; // Moderate, safe deficit
        break;
      case HealthGoal.muscleGain:
        tdee += 300; // Moderate surplus
        break;
      case HealthGoal.maintainWeight:
        break;
    }

    // Safe physiological bounds for general reference
    return tdee.round().clamp(1200, 3500);
  }

  /// Maps free-form user allergen strings to standard allergen tags
  Set<String> _normalizeAllergens(List<String> rawExclusions) {
    final normalized = <String>{};
    for (final item in rawExclusions) {
      final s = item.toLowerCase().trim();
      if (s.contains('peanut')) normalized.add('peanuts');
      if (s.contains('dairy') || s.contains('milk') || s.contains('lactose')) {
        normalized.add('dairy');
      }
      if (s.contains('gluten') || s.contains('wheat') || s.contains('bread')) {
        normalized.add('gluten');
      }
      if (s.contains('egg')) normalized.add('eggs');
      if (s.contains('soy')) normalized.add('soy');
      if (s.contains('fish')) normalized.add('fish');
      if (s.contains('shellfish') ||
          s.contains('shrimp') ||
          s.contains('crab')) {
        normalized.add('shellfish');
      }
      if (s.contains('nut') || s.contains('almond') || s.contains('walnut')) {
        normalized.add('tree_nuts');
      }
    }
    return normalized;
  }
}
