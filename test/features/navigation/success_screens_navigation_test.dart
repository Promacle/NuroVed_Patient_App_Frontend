import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/features/diet/screens/calorie_success_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_success_screen.dart';
import 'package:nuroved_patient/features/home/controllers/home_controller.dart';
import 'package:nuroved_patient/features/home/screens/main_layout.dart';
import 'package:nuroved_patient/features/records/screens/record_success_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_success_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = FakeAuthRepository();
    AppRouter.authRepository = fakeAuth;
    HomeController().setTab(0);
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  group('RecordSuccessScreen Navigation', () {
    testWidgets('renders back button with accessible semantics and checkmark', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecordSuccessScreen(
            profileName: 'Patient One',
            date: DateTime(2026, 3, 15, 10, 30),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RecordSuccessScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.bySemanticsLabel('Back to records'), findsOneWidget);
      expect(find.text('New Record Saved\nSuccessfully'), findsOneWidget);
      expect(find.text('See in Records'), findsOneWidget);
    });

    testWidgets(
      'tapping Back button returns to RecordsScreen without duplicate MainLayout',
      (tester) async {
        final homeCtrl = HomeController();
        homeCtrl.setTab(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordSuccessScreen(
                          profileName: 'Patient One',
                          date: DateTime(2026, 3, 15, 10, 30),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Record Success'),
                );
              },
            ),
          ),
        );

        // Tap to push RecordSuccessScreen
        await tester.tap(find.text('Go to Record Success'));
        await tester.pumpAndSettle();

        expect(find.byType(RecordSuccessScreen), findsOneWidget);

        // Tap the back button
        await tester.tap(find.bySemanticsLabel('Back to records'));
        await tester.pumpAndSettle();

        // Should return to the first screen, and not create MainLayout
        expect(find.byType(RecordSuccessScreen), findsNothing);
        expect(find.text('Go to Record Success'), findsOneWidget);
        expect(find.byType(MainLayout), findsNothing);
        expect(homeCtrl.currentIndex, equals(1));
      },
    );

    testWidgets(
      'tapping "See in Records" returns to root of Records tab without pushing second MainLayout',
      (tester) async {
        final homeCtrl = HomeController();
        homeCtrl.setTab(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordSuccessScreen(
                          profileName: 'Patient One',
                          date: DateTime(2026, 3, 15, 10, 30),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Success'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Success'));
        await tester.pumpAndSettle();

        expect(find.byType(RecordSuccessScreen), findsOneWidget);

        // Scroll into view if needed and tap "See in Records"
        await tester.ensureVisible(find.text('See in Records'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('See in Records'));
        await tester.pumpAndSettle();

        expect(find.byType(RecordSuccessScreen), findsNothing);
        expect(find.text('Open Success'), findsOneWidget);
        expect(find.byType(MainLayout), findsNothing);
        expect(homeCtrl.currentIndex, equals(1));
      },
    );

    testWidgets(
      'PopScope / system back on RecordSuccessScreen pops cleanly to Records',
      (tester) async {
        final homeCtrl = HomeController();
        homeCtrl.setTab(1);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecordSuccessScreen(
                          profileName: 'Patient One',
                          date: DateTime(2026, 3, 15, 10, 30),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Screen'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open Screen'));
        await tester.pumpAndSettle();

        expect(find.byType(RecordSuccessScreen), findsOneWidget);

        // Simulate system back pop
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(RecordSuccessScreen), findsNothing);
        expect(find.text('Open Screen'), findsOneWidget);
        expect(homeCtrl.currentIndex, equals(1));
      },
    );
  });

  group('DietSuccessScreen Navigation', () {
    testWidgets('renders back button and "See in Meal Routine History"', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DietSuccessScreen(timestamp: DateTime(2026, 3, 15, 12, 0)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DietSuccessScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.bySemanticsLabel('Back to diet overview'), findsOneWidget);
      expect(find.text('See in Meal Routine History'), findsOneWidget);
      expect(find.text('New Meal Routine Saved\nSuccessfully'), findsOneWidget);
    });

    testWidgets('tapping Back pops to /diet route when present in stack', (
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
                    MaterialPageRoute(
                      settings: const RouteSettings(name: AppRouter.diet),
                      builder: (context) => Scaffold(
                        body: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DietSuccessScreen(
                                  timestamp: DateTime.now(),
                                ),
                              ),
                            );
                          },
                          child: const Text('Launch Wizard Success'),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open Diet Page'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Diet Page'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Wizard Success'));
      await tester.pumpAndSettle();

      expect(find.byType(DietSuccessScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.bySemanticsLabel('Back to diet overview'));
      await tester.pumpAndSettle();

      // Should be back on the Diet route
      expect(find.byType(DietSuccessScreen), findsNothing);
      expect(find.text('Launch Wizard Success'), findsOneWidget);
    });

    testWidgets(
      'tapping "See in Meal Routine History" navigates to MealRoutineHistoryScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: AppRouter.diet),
                        builder: (context) => Scaffold(
                          body: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DietSuccessScreen(
                                    timestamp: DateTime.now(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Launch Diet Success'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Diet Root'),
                ),
              ),
            ),
            onGenerateRoute: (settings) {
              if (settings.name == AppRouter.mealRoutineHistory) {
                return MaterialPageRoute(
                  settings: const RouteSettings(
                    name: AppRouter.mealRoutineHistory,
                  ),
                  builder: (_) => const Scaffold(
                    body: Text('Destination Meal Routine History'),
                  ),
                );
              }
              return AppRouter.generateRoute(settings);
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Diet Root'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Launch Diet Success'));
        await tester.pumpAndSettle();

        expect(find.byType(DietSuccessScreen), findsOneWidget);

        // Tap "See in Meal Routine History"
        await tester.ensureVisible(find.text('See in Meal Routine History'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('See in Meal Routine History'));
        await tester.pumpAndSettle();

        expect(find.byType(DietSuccessScreen), findsNothing);
        expect(find.text('Destination Meal Routine History'), findsOneWidget);
      },
    );

    testWidgets(
      'PopScope / system back on DietSuccessScreen returns to diet route',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: AppRouter.diet),
                        builder: (context) => Scaffold(
                          body: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DietSuccessScreen(
                                    timestamp: DateTime.now(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Launch Diet Success PopScope'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Diet For PopScope'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Diet For PopScope'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Launch Diet Success PopScope'));
        await tester.pumpAndSettle();

        expect(find.byType(DietSuccessScreen), findsOneWidget);

        // Trigger system back
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(DietSuccessScreen), findsNothing);
        expect(find.text('Launch Diet Success PopScope'), findsOneWidget);
      },
    );
  });

  group('CalorieSuccessScreen Navigation', () {
    testWidgets('renders back button and "See in Diet Section"', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalorieSuccessScreen(timestamp: DateTime(2026, 3, 15, 8, 0)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.text('Calorie Saved\nSuccessfully'), findsOneWidget);
      expect(find.text('See in Diet Section'), findsOneWidget);
    });

    testWidgets('tapping Back pops to previous screen when canPop is true', (
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
                    MaterialPageRoute(
                      builder: (_) =>
                          CalorieSuccessScreen(timestamp: DateTime.now()),
                    ),
                  );
                },
                child: const Text('Open Calorie'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Calorie'));
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsNothing);
      expect(find.text('Open Calorie'), findsOneWidget);
    });

    testWidgets('tapping "See in Diet Section" navigates to DietScreen', (
      tester,
    ) async {
      await fakeAuth.signUp(
        email: 'calorie@example.com',
        password: 'Password123!',
        name: 'Calorie User',
        acknowledgedTerms: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CalorieSuccessScreen(timestamp: DateTime.now()),
                    ),
                  );
                },
                child: const Text('Launch Calorie'),
              ),
            ),
          ),
          onGenerateRoute: (settings) {
            if (settings.name == AppRouter.diet) {
              return MaterialPageRoute(
                settings: const RouteSettings(name: AppRouter.diet),
                builder: (_) =>
                    const Scaffold(body: Text('Diet Section Overview Page')),
              );
            }
            return AppRouter.generateRoute(settings);
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Calorie'));
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsOneWidget);

      await tester.ensureVisible(find.text('See in Diet Section'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See in Diet Section'));
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsNothing);
      expect(find.text('Diet Section Overview Page'), findsOneWidget);
    });

    testWidgets('PopScope / system back on CalorieSuccessScreen pops cleanly', (
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
                    MaterialPageRoute(
                      builder: (_) =>
                          CalorieSuccessScreen(timestamp: DateTime.now()),
                    ),
                  );
                },
                child: const Text('Launch Calorie PopScope'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Calorie PopScope'));
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsOneWidget);

      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(CalorieSuccessScreen), findsNothing);
      expect(find.text('Launch Calorie PopScope'), findsOneWidget);
    });
  });

  group('RoutineSuccessScreen Navigation', () {
    testWidgets('renders back button and "See in Diet Section"', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RoutineSuccessScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(RoutineSuccessScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.text('See in Diet Section'), findsOneWidget);
    });

    testWidgets('tapping Back pops to previous screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoutineSuccessScreen(),
                    ),
                  );
                },
                child: const Text('Open Routine Success'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Routine Success'));
      await tester.pumpAndSettle();

      expect(find.byType(RoutineSuccessScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(RoutineSuccessScreen), findsNothing);
      expect(find.text('Open Routine Success'), findsOneWidget);
    });
  });

  group('AppRouter Success Route Definitions & Auth Guards', () {
    testWidgets('unauthenticated access to success routes redirects to login', (
      tester,
    ) async {
      final recordRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.recordSuccess),
      );
      expect(recordRoute.settings.name, equals(AppRouter.login));

      final dietRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.dietSuccess),
      );
      expect(dietRoute.settings.name, equals(AppRouter.login));

      final calorieRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.calorieSuccess),
      );
      expect(calorieRoute.settings.name, equals(AppRouter.login));
    });

    testWidgets(
      'authenticated access to success routes generates valid routes',
      (tester) async {
        await fakeAuth.signUp(
          email: 'auth_user@example.com',
          password: 'Password123!',
          name: 'Auth User',
          acknowledgedTerms: true,
        );

        final recordRoute = AppRouter.generateRoute(
          RouteSettings(
            name: AppRouter.recordSuccess,
            arguments: {'profileName': 'Test', 'date': DateTime.now()},
          ),
        );
        expect(recordRoute.settings.name, equals(AppRouter.recordSuccess));

        final dietRoute = AppRouter.generateRoute(
          RouteSettings(name: AppRouter.dietSuccess, arguments: DateTime.now()),
        );
        expect(dietRoute.settings.name, equals(AppRouter.dietSuccess));

        final calorieRoute = AppRouter.generateRoute(
          RouteSettings(
            name: AppRouter.calorieSuccess,
            arguments: DateTime.now(),
          ),
        );
        expect(calorieRoute.settings.name, equals(AppRouter.calorieSuccess));
      },
    );

    testWidgets(
      'omitted or null route arguments gracefully fallback without crash',
      (tester) async {
        await fakeAuth.signUp(
          email: 'fallback@example.com',
          password: 'Password123!',
          name: 'Fallback User',
          acknowledgedTerms: true,
        );

        // Null arguments for all success routes should NOT throw cast exceptions
        final recordRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.recordSuccess),
        );
        expect(recordRoute, isNotNull);

        final dietRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.dietSuccess),
        );
        expect(dietRoute, isNotNull);

        final calorieRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.calorieSuccess),
        );
        expect(calorieRoute, isNotNull);
      },
    );
  });
}
