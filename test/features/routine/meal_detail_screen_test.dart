import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';
import 'package:nuroved_patient/features/diet/screens/meal_routine_history_screen.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/edit_routine_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_detail_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_success_screen.dart';
import 'package:nuroved_patient/features/settings/controllers/app_settings_controller.dart';
import 'package:nuroved_patient/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences testPrefs;
  late LocaleController localeController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'timeFormat': '12hr'});
    testPrefs = await SharedPreferences.getInstance();
    localeController = LocaleController.instance;
    await localeController.init(preferences: testPrefs);
    await localeController.setLanguageCode('en', preferences: testPrefs);
    await AppSettingsController().setTimeFormat('12hr');

    ProfileController.resetForTesting(
      initialProfile: const UserProfile(
        id: 'subject-patient-001',
        name: 'Test Patient',
        email: 'patient@example.com',
        phone: '+919876543210',
        dateOfBirth: '1980-05-15',
        gender: 'Male',
        height: '175',
        weight: '70',
        bloodGroup: 'B+',
        allergies: ['Peanuts'],
        chronicConditions: ['Type 2 Diabetes'],
      ),
    );
    RoutineController.resetForTesting();
    DietController().deleteDietPlan();
  });

  Widget buildTestApp({
    required Widget child,
    Locale locale = const Locale('en'),
    double width = 360,
    double height = 800,
    double textScale = 1.0,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('RoutineDetailScreen - Core Meal Rendering', () {
    testWidgets(
      'renders standard meal overview, time, calories, and ingredients',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const RoutineDetailScreen(
              title: 'Breakfast',
              time: '08:00 AM',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Category chip (localized for Breakfast)
        expect(find.text('Breakfast'), findsWidgets);
        // Meal name from RoutineController
        expect(find.text('Oatmeal with Almond Milk'), findsOneWidget);
        // Time chip in header and card
        expect(find.textContaining('08:00 AM'), findsWidgets);
        // Calories
        expect(find.text('350 Calories'), findsOneWidget);
        // Ingredients from RoutineController
        expect(find.text('rolled oats'), findsOneWidget);
        expect(find.text('almond milk'), findsOneWidget);
        // Action buttons
        expect(find.textContaining('Intake'), findsOneWidget);
        expect(find.text('Ignore & Skip'), findsOneWidget);
      },
    );

    testWidgets(
      'handles missing calories and nutrition values without fabrication',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const RoutineDetailScreen(
              title: 'Custom Herbal Tea',
              time: '04:00 PM',
              mealName: 'Warm Tulsi & Ginger Tea',
              ingredients: ['fresh tulsi leaves', 'ginger slice'],
              // no calories, no macros
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Custom Herbal Tea'), findsWidgets);
        expect(find.text('Warm Tulsi & Ginger Tea'), findsOneWidget);
        expect(find.text('fresh tulsi leaves'), findsOneWidget);
        expect(find.text('ginger slice'), findsOneWidget);

        // Nutrition overview card should NOT be rendered when no macros exist
        expect(find.text('Nutrition Overview'), findsNothing);
        expect(find.text('Protein'), findsNothing);
        expect(find.text('Carbs'), findsNothing);
        // Flame calorie chip should not appear
        expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
      },
    );

    testWidgets(
      'renders comprehensive nutrition breakdown card when macros are supplied',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const RoutineDetailScreen(
              title: 'Lunch',
              time: '01:00 PM',
              mealName: 'High Protein Lentil Bowl',
              calories: '420 kcal',
              ingredients: ['Brown rice', 'Yellow lentils', 'Spinach'],
              protein: '24g',
              carbs: '58g',
              fat: '8g',
              fiber: '12g',
              instructions:
                  'Steam lentils thoroughly, toss with wilted spinach, serve hot.',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nutrition Overview'), findsOneWidget);
        expect(find.text('24g'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
        expect(find.text('58g'), findsOneWidget);
        expect(find.text('Carbohydrates'), findsOneWidget);
        expect(find.text('8g'), findsOneWidget);
        expect(find.text('Fat'), findsOneWidget);
        expect(find.text('12g'), findsOneWidget);
        expect(find.text('Fiber'), findsOneWidget);

        expect(find.text('Instructions'), findsOneWidget);
        expect(find.textContaining('Steam lentils thoroughly'), findsOneWidget);
      },
    );

    testWidgets('displays placeholder when meal has no ingredients', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const RoutineDetailScreen(
            title: 'Water Intake',
            time: '10:00 AM',
            mealName: 'Electrolyte Water',
            ingredients: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No ingredients listed'), findsOneWidget);
    });
  });

  group('RoutineDetailScreen - Responsive Layout & Text Scaling Resilience', () {
    testWidgets('resilient on 320px narrow screen without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestApp(
          width: 320,
          height: 640,
          child: const RoutineDetailScreen(
            title:
                'Very Long Ayurvedic Nutritional Category Title That Might Wrap',
            time: '12:30 PM',
            mealName:
                'Steamed Khichdi with Ghee, Fresh Turmeric, Cumin, and Steamed Vegetables',
            calories: '480 kcal Energy',
            ingredients: [
              'Long Grain Basmati Rice washed three times thoroughly',
              'Yellow Moong Dal Split and Soaked for Two Hours',
              'Cold Pressed Desi Cow A2 Ghee',
            ],
            protein: '18g High Biological Value',
            carbs: '65g Complex Carbohydrates',
            fat: '12g Healthy Fatty Acids',
            fiber: '9g Dietary Soluble Fiber',
            instructions:
                'Boil with mild salt and fresh crushed ginger, garnish with chopped coriander.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RoutineDetailScreen), findsOneWidget);
    });

    testWidgets(
      'resilient under 1.5x text scaler on 360px viewport without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(
            width: 360,
            height: 720,
            textScale: 1.5,
            child: const RoutineDetailScreen(
              title: 'Cardiology Morning Routine',
              time: '08:30 AM',
              mealName:
                  'Oatmeal Porridge with Fresh Blueberries, Walnuts, and Organic Soy Milk',
              calories: '450 Calories',
              ingredients: ['Organic Rolled Oats', 'Soy Milk', 'Blueberries'],
              protein: '16g',
              carbs: '60g',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(RoutineDetailScreen), findsOneWidget);
      },
    );
  });

  group('RoutineDetailScreen - Multilingual Localization (EN, GU, HI)', () {
    testWidgets('renders Gujarati translations accurately', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('gu'),
          child: const RoutineDetailScreen(
            title: 'Breakfast',
            time: '08:00 AM',
            mealName: 'પૌંઆ અને લીલી ચટણી',
            ingredients: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Localized meal category for Breakfast in Gujarati: સવારનો નાસ્તો
      expect(find.text('સવારનો નાસ્તો'), findsWidgets);
      // Localized no ingredients key
      expect(find.text('કોઈ સામગ્રી સૂચિબદ્ધ નથી'), findsOneWidget);
      // Localized scheduled time string containing 08:00 AM
      expect(find.textContaining('08:00 AM'), findsWidgets);
      expect(find.textContaining('માટે નિર્ધારિત'), findsOneWidget);
      // Localized Ignore & Skip
      expect(find.text('અવગણો અને સ્કીપ કરો'), findsOneWidget);
    });

    testWidgets('renders Hindi translations accurately', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('hi'),
          child: const RoutineDetailScreen(
            title: 'Lunch',
            time: '01:00 PM',
            mealName: 'दाल और रोटी',
            ingredients: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Localized meal category for Lunch in Hindi: दोपहर का भोजन
      expect(find.text('दोपहर का भोजन'), findsWidgets);
      // Localized no ingredients key
      expect(find.text('कोई सामग्री सूचीबद्ध नहीं है'), findsOneWidget);
      // Localized scheduled time string
      expect(find.textContaining('के लिए निर्धारित'), findsOneWidget);
      // Localized Ignore & Skip
      expect(find.text('अनदेखा करें और छोड़ें'), findsOneWidget);
    });
  });

  group('RoutineDetailScreen - Actions & State Transitions', () {
    testWidgets(
      'completing intake triggers confirmation dialog and replaces with RoutineSuccessScreen',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const RoutineDetailScreen(
              title: 'Breakfast',
              time: '08:00 AM',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the intake button and tap
        final intakeButton = find.widgetWithText(
          ElevatedButton,
          'Intake Breakfast',
        );
        expect(intakeButton, findsOneWidget);
        await tester.tap(intakeButton);
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.text('Confirm Breakfast'), findsOneWidget);
        expect(find.textContaining('Have you finished'), findsOneWidget);

        // Tap Yes, Done
        final confirmButton = find.widgetWithText(ElevatedButton, 'Yes, Done');
        expect(confirmButton, findsOneWidget);
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        // Should replace with RoutineSuccessScreen
        expect(find.byType(RoutineSuccessScreen), findsOneWidget);
        expect(find.byType(RoutineDetailScreen), findsNothing);

        // RoutineController state should be updated
        final updatedMeal = RoutineController().meals.firstWhere(
          (m) => m['title'] == 'Breakfast',
        );
        expect(updatedMeal['isCompleted'], isTrue);
      },
    );

    testWidgets('renders completed banner when meal is already completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const RoutineDetailScreen(
            title: 'Dinner',
            time: '08:00 PM',
            mealName: 'Steamed Soup',
            isCompleted: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Status badge shows Taken
      expect(find.text('Taken'), findsOneWidget);
      // Completed banner should be present in place of active intake button
      expect(find.text('Meal Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
      // Intake button should NOT be shown
      expect(find.textContaining('Intake Dinner'), findsNothing);
    });

    testWidgets('edit button navigates to EditRoutineScreen', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const RoutineDetailScreen(
            title: 'Breakfast',
            time: '08:00 AM',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editButton = find.byTooltip('Edit Routine');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(EditRoutineScreen), findsOneWidget);
    });

    testWidgets(
      'tapping meal card in MealRoutineHistoryScreen navigates to RoutineDetailScreen',
      (tester) async {
        final samplePlan = {
          'weeklyPlan': [
            {
              'dayName': 'Monday',
              'meals': [
                {
                  'header': 'Breakfast (08:30 AM)',
                  'title': 'Ayurvedic Herb Porridge',
                  'ingredients': ['Quinoa', 'Cardamom', 'Warm Almond Milk'],
                  'calories': '320 kcal',
                  'protein': '12g',
                },
              ],
            },
          ],
        };
        DietController().saveDietPlan(samplePlan);

        await tester.pumpWidget(
          buildTestApp(child: const MealRoutineHistoryScreen()),
        );
        await tester.pumpAndSettle();

        // Day 1 is expanded by default, so 'Ayurvedic Herb Porridge' is visible
        final mealCard = find.text('Ayurvedic Herb Porridge');
        expect(mealCard, findsOneWidget);

        await tester.tap(mealCard);
        await tester.pumpAndSettle();

        // Verify RoutineDetailScreen is opened
        expect(find.byType(RoutineDetailScreen), findsOneWidget);
        expect(find.text('Ayurvedic Herb Porridge'), findsOneWidget);
        expect(find.text('Quinoa'), findsOneWidget);
        expect(find.text('Cardamom'), findsOneWidget);
        expect(find.textContaining('08:30 AM'), findsWidgets);
        expect(find.text('320 kcal'), findsOneWidget);
        expect(find.text('12g'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
      },
    );
  });
}
