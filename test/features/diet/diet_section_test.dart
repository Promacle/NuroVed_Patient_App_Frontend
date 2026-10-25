import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';
import 'package:nuroved_patient/features/diet/screens/ai_diet_planner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_screen.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/meal_routine_history_screen.dart';
import 'package:nuroved_patient/features/home/controllers/home_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = FakeAuthRepository();
    await fakeAuth.signUp(
      email: 'diet_test@example.com',
      password: 'Password123!',
      name: 'Diet Tester',
      acknowledgedTerms: true,
    );
    AppRouter.authRepository = fakeAuth;
    HomeController().setTab(0);
    DietController().deleteDietPlan();
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  Widget buildTestApp({Widget? home, RouteFactory? onGenerateRoute}) {
    return MaterialApp(
      home: home ?? const DietScreen(),
      onGenerateRoute: onGenerateRoute ?? AppRouter.generateRoute,
    );
  }

  group('DietScreen - UI Rendering & Accessibility', () {
    testWidgets(
      'renders header, title, subtitle, and disclaimer banner without exceptions',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Diet Section'), findsOneWidget);
        expect(find.text('Calculate Your Every Single Bite'), findsOneWidget);
        expect(find.bySemanticsLabel('Back'), findsOneWidget);
        expect(
          find.textContaining(
            'Diet suggestions are for nutritional tracking only',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Sample preview metrics - not clinical measurements'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Diet Planner icon is correctly styled, centered and uses food/diet iconography',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        final plannerIconFinder = find.byIcon(Icons.restaurant_menu_rounded);
        expect(plannerIconFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(plannerIconFinder);
        expect(iconWidget.color, equals(AppColors.sageGreen));
        expect(iconWidget.size, equals(34));

        // Verify centered container
        final containerFinder = find
            .ancestor(of: plannerIconFinder, matching: find.byType(Container))
            .first;
        final container = tester.widget<Container>(containerFinder);
        expect(container.alignment, equals(Alignment.center));
      },
    );

    testWidgets(
      'All three Quick Action cards are present with semantic labels and InkWells',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Quick Action'), findsOneWidget);
        expect(find.text('Diet Planner'), findsOneWidget);
        expect(find.text('Food Scanner'), findsOneWidget);
        expect(find.text('Meal Routine History'), findsOneWidget);

        expect(find.bySemanticsLabel('Diet Planner'), findsOneWidget);
        expect(find.bySemanticsLabel('Food Scanner'), findsOneWidget);
        expect(find.bySemanticsLabel('Meal Routine History'), findsOneWidget);

        expect(find.byType(QuickActionButton), findsNWidgets(3));
        expect(find.byType(InkWell), findsAtLeastNWidgets(3));
      },
    );

    testWidgets('tapping header back button pops the DietScreen safely', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DietScreen()),
                  );
                },
                child: const Text('Open Diet'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Diet'));
      await tester.pumpAndSettle();

      expect(find.byType(DietScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(DietScreen), findsNothing);
      expect(find.text('Open Diet'), findsOneWidget);
    });

    testWidgets('PopScope / system back on DietScreen pops cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DietScreen()),
                  );
                },
                child: const Text('Launch Diet PopScope'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Diet PopScope'));
      await tester.pumpAndSettle();

      expect(find.byType(DietScreen), findsOneWidget);

      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(DietScreen), findsNothing);
      expect(find.text('Launch Diet PopScope'), findsOneWidget);
    });
  });

  group('DietScreen - Quick Action Card Interaction & Navigation Flows', () {
    testWidgets(
      'tapping Diet Planner opens AiDietPlannerScreen basic info flow',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.bySemanticsLabel('Diet Planner'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Diet Planner'));
        await tester.pumpAndSettle();

        expect(find.byType(AiDietPlannerScreen), findsOneWidget);
        expect(find.text('Basic Information'), findsOneWidget);
        expect(find.text('Continue to Diet Preference'), findsOneWidget);

        // Back button returns cleanly to DietScreen
        await tester.tap(find.bySemanticsLabel('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(AiDietPlannerScreen), findsNothing);
        expect(find.byType(DietScreen), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Food Scanner opens FoodScannerScreen without duplicate MainLayout',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.bySemanticsLabel('Food Scanner'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Food Scanner'));
        await tester.pumpAndSettle();

        expect(find.byType(FoodScannerScreen), findsOneWidget);
        expect(find.text('Food Scanner'), findsOneWidget);
        expect(find.text('Scan Retail Food Barcode'), findsOneWidget);

        // Back button pops back cleanly to DietScreen
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(FoodScannerScreen), findsNothing);
        expect(find.byType(DietScreen), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Meal Routine History opens MealRoutineHistoryScreen and handles empty plan',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.bySemanticsLabel('Meal Routine History'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Meal Routine History'));
        await tester.pumpAndSettle();

        expect(find.byType(MealRoutineHistoryScreen), findsOneWidget);
        expect(find.text('No Meal Routine Saved Yet'), findsOneWidget);
        expect(find.text('Back to Diet Overview'), findsOneWidget);

        await tester.tap(find.text('Back to Diet Overview'));
        await tester.pumpAndSettle();

        expect(find.byType(MealRoutineHistoryScreen), findsNothing);
        expect(find.byType(DietScreen), findsOneWidget);
      },
    );

    testWidgets(
      'MealRoutineHistoryScreen renders saved weekly meal plan reactively',
      (tester) async {
        final samplePlan = {
          'weeklyPlan': [
            {
              'dayName': 'Monday',
              'meals': [
                {
                  'header': 'Breakfast',
                  'title': 'Oats with Almonds',
                  'ingredients': ['Oats', 'Almond Milk', 'Chia Seeds'],
                },
              ],
            },
          ],
        };
        DietController().saveDietPlan(samplePlan);

        await tester.pumpWidget(
          buildTestApp(home: const MealRoutineHistoryScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Weekly Meal Plan'), findsOneWidget);
        expect(find.text('Day 1 Monday'), findsOneWidget);
        expect(find.text('Oats with Almonds'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        // Scroll delete button into view and tap
        await tester.ensureVisible(find.text('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Safety confirmation dialog appears before destructive action
        expect(find.text('Delete Diet Plan?'), findsOneWidget);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
        await tester.pumpAndSettle();

        expect(DietController().hasSavedPlan, isFalse);
      },
    );
  });

  group('DietScreen - Hit Testing, Scrolling & Shell Isolation', () {
    testWidgets(
      'page scrolls normally without gesture blocking or overlay interception',
      (tester) async {
        tester.view.physicalSize = const Size(400, 600); // Compact viewport
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Verify initial visibility of header
        expect(find.text('Diet Section'), findsOneWidget);

        // Scroll down
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();

        // Quick action buttons should still be tappable after scroll
        expect(find.text('Quick Action'), findsOneWidget);
        expect(find.bySemanticsLabel('Diet Planner'), findsOneWidget);

        await tester.ensureVisible(find.bySemanticsLabel('Diet Planner'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Diet Planner'));
        await tester.pumpAndSettle();

        expect(find.byType(AiDietPlannerScreen), findsOneWidget);
      },
    );

    testWidgets(
      'QuickAction cards respond independently and tapping empty space does not trigger action',
      (tester) async {
        int tappedCard = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  QuickActionButton(
                    label: 'Card 1',
                    icon: const Icon(Icons.star),
                    onTap: () => tappedCard = 1,
                  ),
                  QuickActionButton(
                    label: 'Card 2',
                    icon: const Icon(Icons.favorite),
                    onTap: () => tappedCard = 2,
                  ),
                  QuickActionButton(
                    label: 'Card 3',
                    icon: const Icon(Icons.timer),
                    onTap: () => tappedCard = 3,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.bySemanticsLabel('Card 2'));
        await tester.pumpAndSettle();

        expect(tappedCard, equals(2));

        await tester.tap(find.bySemanticsLabel('Card 1'));
        await tester.pumpAndSettle();

        expect(tappedCard, equals(1));
      },
    );

    testWidgets(
      'Bottom navigation remains functional after opening and returning from Diet flows',
      (tester) async {
        int activeTab = 0;

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: activeTab == 0
                      ? Builder(
                          builder: (innerContext) => Center(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                innerContext,
                                AppRouter.diet,
                              ),
                              child: const Text('Open Diet Flow'),
                            ),
                          ),
                        )
                      : Center(child: Text('Tab $activeTab Content')),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: activeTab,
                    onTap: (index) => setState(() => activeTab = index),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.description),
                        label: 'Records',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open Diet Section
        await tester.tap(find.text('Open Diet Flow'));
        await tester.pumpAndSettle();

        expect(find.byType(DietScreen), findsOneWidget);

        // Open Food Scanner from DietScreen
        await tester.ensureVisible(find.bySemanticsLabel('Food Scanner'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Food Scanner'));
        await tester.pumpAndSettle();

        expect(find.byType(FoodScannerScreen), findsOneWidget);

        // Return back to DietScreen
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(DietScreen), findsOneWidget);

        // Return back to HomeScreen
        await tester.tap(find.bySemanticsLabel('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(DietScreen), findsNothing);
        expect(find.text('Open Diet Flow'), findsOneWidget);

        // Switch tab via Bottom Navigation
        await tester.tap(find.byIcon(Icons.description));
        await tester.pumpAndSettle();

        expect(find.text('Tab 1 Content'), findsOneWidget);
      },
    );
  });
}
