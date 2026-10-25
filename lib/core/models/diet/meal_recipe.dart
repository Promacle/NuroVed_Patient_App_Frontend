enum MealType { breakfast, lunch, snack, dinner }

class MealNutritionalProfile {
  final int calories;
  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;
  final double fiberGrams;
  final String servingBasis;

  const MealNutritionalProfile({
    required this.calories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    required this.fiberGrams,
    this.servingBasis = '1 serving',
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinGrams': proteinGrams,
    'carbGrams': carbGrams,
    'fatGrams': fatGrams,
    'fiberGrams': fiberGrams,
    'servingBasis': servingBasis,
  };

  factory MealNutritionalProfile.fromJson(Map<String, dynamic> json) =>
      MealNutritionalProfile(
        calories: json['calories'] as int? ?? 0,
        proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
        carbGrams: (json['carbGrams'] as num?)?.toDouble() ?? 0.0,
        fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
        fiberGrams: (json['fiberGrams'] as num?)?.toDouble() ?? 0.0,
        servingBasis: json['servingBasis'] as String? ?? '1 serving',
      );
}

class MealRecipe {
  final String id;
  final String title;
  final MealType mealType;
  final bool isVegetarian;
  final List<String> ingredients;
  final Set<String> allergens;
  final int prepTimeMinutes;
  final String instructions;
  final MealNutritionalProfile nutrition;
  final List<String> tags;
  final String sourceAttribution;

  const MealRecipe({
    required this.id,
    required this.title,
    required this.mealType,
    required this.isVegetarian,
    required this.ingredients,
    required this.allergens,
    required this.prepTimeMinutes,
    required this.instructions,
    required this.nutrition,
    required this.tags,
    this.sourceAttribution =
        'ICMR-NIN & USDA Food Data Central Dietary Guidelines',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'mealType': mealType.name,
    'isVegetarian': isVegetarian,
    'ingredients': ingredients,
    'allergens': allergens.toList(),
    'prepTimeMinutes': prepTimeMinutes,
    'instructions': instructions,
    'nutrition': nutrition.toJson(),
    'tags': tags,
    'sourceAttribution': sourceAttribution,
  };
}

/// A single day's structured meal plan
class MealPlanDay {
  final String dayName; // e.g. "Monday"
  final String dayCode; // e.g. "MO"
  final MealRecipe breakfast;
  final MealRecipe lunch;
  final MealRecipe snack;
  final MealRecipe dinner;

  const MealPlanDay({
    required this.dayName,
    required this.dayCode,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.dinner,
  });

  int get totalCalories =>
      breakfast.nutrition.calories +
      lunch.nutrition.calories +
      snack.nutrition.calories +
      dinner.nutrition.calories;

  double get totalProtein =>
      breakfast.nutrition.proteinGrams +
      lunch.nutrition.proteinGrams +
      snack.nutrition.proteinGrams +
      dinner.nutrition.proteinGrams;

  double get totalCarbs =>
      breakfast.nutrition.carbGrams +
      lunch.nutrition.carbGrams +
      snack.nutrition.carbGrams +
      dinner.nutrition.carbGrams;

  double get totalFat =>
      breakfast.nutrition.fatGrams +
      lunch.nutrition.fatGrams +
      snack.nutrition.fatGrams +
      dinner.nutrition.fatGrams;

  double get totalFiber =>
      breakfast.nutrition.fiberGrams +
      lunch.nutrition.fiberGrams +
      snack.nutrition.fiberGrams +
      dinner.nutrition.fiberGrams;

  /// Formats meals into format compatible with MealRoutineHistoryScreen & EditMealScreen
  Map<String, dynamic> toHistoryFormat() {
    return {
      'dayName': dayName,
      'meals': [
        {
          'header': 'Breakfast (8:00 AM)',
          'title': breakfast.title,
          'ingredients': breakfast.ingredients,
          'calories': breakfast.nutrition.calories,
          'protein': breakfast.nutrition.proteinGrams,
          'carbs': breakfast.nutrition.carbGrams,
          'fat': breakfast.nutrition.fatGrams,
          'instructions': breakfast.instructions,
        },
        {
          'header': 'Lunch (1:00 PM)',
          'title': lunch.title,
          'ingredients': lunch.ingredients,
          'calories': lunch.nutrition.calories,
          'protein': lunch.nutrition.proteinGrams,
          'carbs': lunch.nutrition.carbGrams,
          'fat': lunch.nutrition.fatGrams,
          'instructions': lunch.instructions,
        },
        {
          'header': 'Evening Snack (5:00 PM)',
          'title': snack.title,
          'ingredients': snack.ingredients,
          'calories': snack.nutrition.calories,
          'protein': snack.nutrition.proteinGrams,
          'carbs': snack.nutrition.carbGrams,
          'fat': snack.nutrition.fatGrams,
          'instructions': snack.instructions,
        },
        {
          'header': 'Dinner (8:00 PM)',
          'title': dinner.title,
          'ingredients': dinner.ingredients,
          'calories': dinner.nutrition.calories,
          'protein': dinner.nutrition.proteinGrams,
          'carbs': dinner.nutrition.carbGrams,
          'fat': dinner.nutrition.fatGrams,
          'instructions': dinner.instructions,
        },
      ],
    };
  }
}

/// Full 7-day weekly diet plan with clinical guidance metadata
class WeeklyDietPlan {
  final List<MealPlanDay> days;
  final int estimatedDailyCaloricTarget;
  final String caloricEquationMethod;
  final String clinicalDisclaimer;
  final DateTime generatedAt;

  const WeeklyDietPlan({
    required this.days,
    required this.estimatedDailyCaloricTarget,
    required this.caloricEquationMethod,
    required this.clinicalDisclaimer,
    required this.generatedAt,
  });

  /// Serializes into the canonical map required by DietController and MealRoutineHistoryScreen
  Map<String, dynamic> toRoutineMap() {
    return {
      'weeklyPlan': days.map((d) => d.toHistoryFormat()).toList(),
      'estimatedDailyCaloricTarget': estimatedDailyCaloricTarget,
      'caloricEquationMethod': caloricEquationMethod,
      'clinicalDisclaimer': clinicalDisclaimer,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Sealed result from the deterministic diet planning engine
abstract class DietPlanResult {
  const DietPlanResult();
}

class DietPlanSuccess extends DietPlanResult {
  final WeeklyDietPlan plan;
  const DietPlanSuccess(this.plan);
}

class DietPlanClinicalSupervisionRequired extends DietPlanResult {
  final String detectedCondition;
  final String explanation;
  final String recommendation;

  const DietPlanClinicalSupervisionRequired({
    required this.detectedCondition,
    required this.explanation,
    required this.recommendation,
  });
}

class DietPlanInsufficientRecipes extends DietPlanResult {
  final String message;
  const DietPlanInsufficientRecipes(this.message);
}
