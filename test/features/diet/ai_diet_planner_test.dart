import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/models/diet/diet_preferences.dart';
import 'package:nuroved_patient/core/models/diet/meal_recipe.dart';
import 'package:nuroved_patient/core/services/diet/diet_planning_engine.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';
import 'package:nuroved_patient/features/diet/screens/ai_diet_planner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_output_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_preference_screen.dart';
import 'package:nuroved_patient/features/diet/screens/meal_routine_history_screen.dart';
import 'package:nuroved_patient/features/diet/screens/time_and_context_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DietController.resetForTesting();
  });

  group('DietPlanningEngine Unit Tests — Clinical Safety & Logic', () {
    const engine = DietPlanningEngine();

    test(
      'Clinical Guardrails: Rejects Type 1 Diabetes with clinical supervision guidance',
      () {
        const prefs = DietPreferences(
          age: 30,
          weightKg: 70,
          heightCm: 175,
          medicalConditionNotes:
              'diagnosed with Type 1 Diabetes on insulin pump',
        );

        final result = engine.generatePlan(prefs);

        expect(result, isA<DietPlanClinicalSupervisionRequired>());
        final supervision = result as DietPlanClinicalSupervisionRequired;
        expect(supervision.detectedCondition, equals('Type 1 Diabetes'));
        expect(
          supervision.explanation,
          contains('carbohydrate-to-insulin ratio'),
        );
        expect(supervision.recommendation, contains('physician'));
      },
    );

    test(
      'Clinical Guardrails: Rejects Renal Failure / Dialysis with clinical guidance',
      () {
        const prefs = DietPreferences(
          age: 55,
          medicalConditionNotes: 'Undergoing dialysis for kidney disease',
        );

        final result = engine.generatePlan(prefs);

        expect(result, isA<DietPlanClinicalSupervisionRequired>());
        final supervision = result as DietPlanClinicalSupervisionRequired;
        expect(supervision.detectedCondition, contains('Dialysis'));
      },
    );

    test('Clinical Guardrails: Rejects Pregnancy with clinical guidance', () {
      const prefs = DietPreferences(
        age: 28,
        gender: 'Female',
        medicalConditionNotes: 'Currently pregnant in second trimester',
      );

      final result = engine.generatePlan(prefs);

      expect(result, isA<DietPlanClinicalSupervisionRequired>());
      final supervision = result as DietPlanClinicalSupervisionRequired;
      expect(supervision.detectedCondition, contains('Pregnancy'));
    });

    test(
      'Clinical Guardrails: Rejects Eating Disorders with clinical guidance',
      () {
        const prefs = DietPreferences(
          age: 22,
          medicalConditionNotes: 'History of anorexia nervosa',
        );

        final result = engine.generatePlan(prefs);

        expect(result, isA<DietPlanClinicalSupervisionRequired>());
        final supervision = result as DietPlanClinicalSupervisionRequired;
        expect(supervision.detectedCondition, contains('Anorexia'));
      },
    );

    test(
      'Allergen Exclusions: Strictly filters out peanut recipes when peanut allergy specified',
      () {
        const prefs = DietPreferences(
          dietaryPattern: DietaryPattern.vegetarian,
          allergiesAndExclusions: ['peanuts'],
        );

        final result = engine.generatePlan(prefs);

        expect(result, isA<DietPlanSuccess>());
        final plan = (result as DietPlanSuccess).plan;

        for (final day in plan.days) {
          for (final meal in [
            day.breakfast,
            day.lunch,
            day.snack,
            day.dinner,
          ]) {
            expect(
              meal.allergens.contains('peanuts'),
              isFalse,
              reason: 'Found peanut allergen in ${meal.title}',
            );
            for (final ing in meal.ingredients) {
              expect(
                ing.toLowerCase().contains('peanut'),
                isFalse,
                reason: 'Found peanut in ingredient: $ing',
              );
            }
          }
        }
      },
    );

    test('Dietary Pattern: Vegetarian plan contains 100% vegetarian meals', () {
      const prefs = DietPreferences(dietaryPattern: DietaryPattern.vegetarian);

      final result = engine.generatePlan(prefs);

      expect(result, isA<DietPlanSuccess>());
      final plan = (result as DietPlanSuccess).plan;

      for (final day in plan.days) {
        expect(day.breakfast.isVegetarian, isTrue);
        expect(day.lunch.isVegetarian, isTrue);
        expect(day.snack.isVegetarian, isTrue);
        expect(day.dinner.isVegetarian, isTrue);
      }
    });

    test(
      'Dietary Pattern: Both (Veg & Non-Veg) schedules non-veg on designated days only',
      () {
        const prefs = DietPreferences(
          dietaryPattern: DietaryPattern.both,
          nonVegDays: {'TU', 'FR'},
        );

        final result = engine.generatePlan(prefs);

        expect(result, isA<DietPlanSuccess>());
        final plan = (result as DietPlanSuccess).plan;

        for (final day in plan.days) {
          if (day.dayCode != 'TU' && day.dayCode != 'FR') {
            // Strictly vegetarian on other days
            expect(
              day.breakfast.isVegetarian,
              isTrue,
              reason: 'Non-veg found on vegetarian day ${day.dayName}',
            );
            expect(
              day.lunch.isVegetarian,
              isTrue,
              reason: 'Non-veg found on vegetarian day ${day.dayName}',
            );
            expect(
              day.dinner.isVegetarian,
              isTrue,
              reason: 'Non-veg found on vegetarian day ${day.dayName}',
            );
          }
        }
      },
    );

    test(
      'Mifflin-St Jeor Energy Calculation respects physical metrics and health goals',
      () {
        const maintainPrefs = DietPreferences(
          age: 30,
          gender: 'Male',
          weightKg: 70,
          heightCm: 175,
          activityLevel: ActivityLevel.moderate,
          primaryGoal: HealthGoal.maintainWeight,
        );

        final losePrefs = maintainPrefs.copyWith(
          primaryGoal: HealthGoal.loseWeight,
        );

        final gainPrefs = maintainPrefs.copyWith(
          primaryGoal: HealthGoal.muscleGain,
        );

        final maintainResult =
            engine.generatePlan(maintainPrefs) as DietPlanSuccess;
        final loseResult = engine.generatePlan(losePrefs) as DietPlanSuccess;
        final gainResult = engine.generatePlan(gainPrefs) as DietPlanSuccess;

        expect(
          loseResult.plan.estimatedDailyCaloricTarget,
          lessThan(maintainResult.plan.estimatedDailyCaloricTarget),
        );
        expect(
          gainResult.plan.estimatedDailyCaloricTarget,
          greaterThan(maintainResult.plan.estimatedDailyCaloricTarget),
        );
        expect(
          maintainResult.plan.caloricEquationMethod,
          contains('Mifflin-St Jeor'),
        );
      },
    );

    test('No Consecutive Duplicate Meals ensures variety across week', () {
      const prefs = DietPreferences(dietaryPattern: DietaryPattern.vegetarian);

      final result = engine.generatePlan(prefs) as DietPlanSuccess;
      final days = result.plan.days;

      for (int i = 0; i < days.length - 1; i++) {
        final current = days[i];
        final next = days[i + 1];

        expect(
          current.breakfast.id,
          isNot(equals(next.breakfast.id)),
          reason:
              'Consecutive duplicate breakfast between Day $i and Day ${i + 1}',
        );
        expect(
          current.lunch.id,
          isNot(equals(next.lunch.id)),
          reason: 'Consecutive duplicate lunch between Day $i and Day ${i + 1}',
        );
        expect(
          current.dinner.id,
          isNot(equals(next.dinner.id)),
          reason:
              'Consecutive duplicate dinner between Day $i and Day ${i + 1}',
        );
      }
    });
  });

  group('Diet Planner UI & Preference Wizard Tests', () {
    testWidgets(
      'Step 1 (AiDietPlannerScreen) validates physical metric inputs',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const MaterialApp(home: AiDietPlannerScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Ai Diet Planner'), findsOneWidget);
        expect(find.text('Basic Information'), findsOneWidget);

        // Enter invalid age
        await tester.enterText(find.byType(TextField).first, '200');
        await tester.ensureVisible(find.text('Continue to Diet Preference'));
        await tester.tap(find.text('Continue to Diet Preference'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid age (1–120).'), findsOneWidget);
      },
    );

    testWidgets(
      'Step 2 (DietPreferenceScreen) requires at least one non-veg day when Both selected',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(home: DietPreferenceScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Diet Preference'), findsOneWidget);

        // Select 'Both (Veg & Non-Veg)'
        await tester.tap(find.text('Both (Veg & Non-Veg)'));
        await tester.pumpAndSettle();

        expect(
          find.text('Pick the days you prefer non-veg meals'),
          findsOneWidget,
        );

        // Deselect default days TU and FR
        await tester.tap(find.text('TU'));
        await tester.tap(find.text('FR'));
        await tester.pumpAndSettle();

        // Tap continue with 0 days selected
        await tester.ensureVisible(find.text('Continue to Health Goals'));
        await tester.tap(find.text('Continue to Health Goals'));
        await tester.pumpAndSettle();

        expect(
          find.text('Please select at least one day for non-vegetarian meals.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Step 4 (TimeAndContextScreen) shows clinical dialog when high-risk condition entered',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const initialPrefs = DietPreferences(
          age: 25,
          medicalConditionNotes: 'patient has type 1 diabetes',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: TimeAndContextScreen(initialPreferences: initialPrefs),
          ),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Generate Verified Diet Plan'));
        await tester.tap(find.text('Generate Verified Diet Plan'));
        await tester.pumpAndSettle();

        expect(find.text('Clinical Supervision Notice'), findsOneWidget);
        expect(find.text('Condition: Type 1 Diabetes'), findsOneWidget);
        expect(find.text('Return to Diet Overview'), findsOneWidget);
      },
    );

    testWidgets(
      'Step 5 (DietOutputScreen) displays 7-day plan, macros, and allows saving to routine',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final engine = const DietPlanningEngine();
        final res =
            engine.generatePlan(
                  const DietPreferences(
                    dietaryPattern: DietaryPattern.vegetarian,
                  ),
                )
                as DietPlanSuccess;

        await tester.pumpWidget(
          MaterialApp(
            home: DietOutputScreen(initialPlan: res.plan),
            routes: {
              AppRouter.dietSuccess: (_) =>
                  const Scaffold(body: Text('Diet Success Screen')),
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Weekly Meal Plan'), findsOneWidget);
        expect(find.text('Verified Nutritional Planning'), findsOneWidget);
        expect(find.text('Clinical Reference Notice'), findsOneWidget);
        expect(find.textContaining('Breakfast'), findsWidgets);
        expect(find.textContaining('Lunch'), findsWidgets);

        // Switch day tab
        await tester.tap(find.text('TU'));
        await tester.pumpAndSettle();

        expect(find.text('Tuesday Nutrition Overview'), findsOneWidget);

        // Save to routine
        await tester.ensureVisible(find.text('Save to My Routine'));
        await tester.tap(find.text('Save to My Routine'));
        await tester.pumpAndSettle();

        expect(DietController().hasSavedPlan, isTrue);
        expect(find.text('Diet Success Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'Saved plan from DietOutputScreen renders reactively in MealRoutineHistoryScreen',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final engine = const DietPlanningEngine();
        final res =
            engine.generatePlan(
                  const DietPreferences(
                    dietaryPattern: DietaryPattern.vegetarian,
                  ),
                )
                as DietPlanSuccess;

        // Save plan via controller
        DietController().saveDietPlan(res.plan.toRoutineMap());

        await tester.pumpWidget(
          const MaterialApp(home: MealRoutineHistoryScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Weekly Meal Plan'), findsOneWidget);
        expect(find.text('Day 1 Monday'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      },
    );
  });
}
