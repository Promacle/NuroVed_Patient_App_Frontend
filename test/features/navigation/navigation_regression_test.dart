import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';
import 'package:nuroved_patient/features/auth/screens/login_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_screen.dart';
import 'package:nuroved_patient/features/home/controllers/home_controller.dart';
import 'package:nuroved_patient/features/home/screens/home_screen.dart';
import 'package:nuroved_patient/features/home/screens/main_layout.dart';
import 'package:nuroved_patient/features/home/widgets/custom_bottom_nav.dart';
import 'package:nuroved_patient/features/premium/screens/premium_status_screen.dart';
import 'package:nuroved_patient/features/records/screens/records_screen.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/routine_detail_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_success_screen.dart';
import 'package:nuroved_patient/features/visits/screens/visits_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder navTab(String label) => find.descendant(
  of: find.byType(CustomBottomNav),
  matching: find.text(label),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;
  late AuthController authController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = FakeAuthRepository();
    AppRouter.authRepository = fakeAuth;
    authController = AuthController(authRepository: fakeAuth);
    HomeController().setTab(0);
    RoutineController.resetForTesting();

    await fakeAuth.signUp(
      email: 'navigation_audit@example.com',
      password: 'Password123!',
      name: 'Audit Patient',
      acknowledgedTerms: true,
    );
  });

  tearDown(() {
    authController.dispose();
    fakeAuth.dispose();
  });

  Widget createTestApp({Widget? home, String? initialRoute}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
      ],
      child: MaterialApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialRoute: initialRoute,
        home: home,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }

  group('MainLayout & Bottom Navigation Destinations', () {
    testWidgets(
      'Each of the 5 bottom navigation tabs switches to its target section',
      (tester) async {
        await tester.pumpWidget(createTestApp(home: const MainLayout()));
        await tester.pumpAndSettle();

        final homeCtrl = HomeController();
        expect(homeCtrl.currentIndex, equals(0));
        expect(find.byType(HomeScreen), findsOneWidget);

        // Tab 1: Records
        await tester.tap(navTab('Records'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(1));
        expect(find.byType(RecordsScreen), findsOneWidget);

        // Tab 2: Food Scanner
        await tester.tap(find.byTooltip('Food Scanner'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(2));

        // Tab 3: Visits
        await tester.tap(navTab('Visits'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(3));
        expect(find.byType(VisitsScreen), findsOneWidget);

        // Tab 4: Profile
        await tester.tap(navTab('Profile'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(4));

        // Return to Home
        await tester.tap(navTab('Home'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(0));
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Smart Reset: Tapping active bottom tab pops that tab back to its root page',
      (tester) async {
        await tester.pumpWidget(createTestApp(home: const MainLayout()));
        await tester.pumpAndSettle();

        final homeCtrl = HomeController();
        homeCtrl.setTab(0);
        await tester.pumpAndSettle();

        // Push a subscreen on Tab 0 (e.g. DietScreen)
        final rootContext = tester.element(find.byType(HomeScreen));
        Navigator.of(rootContext).pushNamed(AppRouter.diet);
        await tester.pumpAndSettle();

        expect(find.byType(DietScreen), findsOneWidget);

        // Tap the already active Home tab in CustomBottomNav
        await tester.tap(navTab('Home'));
        await tester.pumpAndSettle();

        // Should have popped back to root of Tab 0
        expect(find.byType(DietScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'System back at root of non-Home tab switches back to Home tab 0',
      (tester) async {
        await tester.pumpWidget(createTestApp(home: const MainLayout()));
        await tester.pumpAndSettle();

        final homeCtrl = HomeController();

        // Switch to Visits tab (index 3)
        await tester.tap(navTab('Visits'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(3));

        // Invoke system back
        final dynamic widgetsAppState = tester.state(
          find.byType(WidgetsApp).first,
        );
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();

        // Must transition to Home tab 0
        expect(homeCtrl.currentIndex, equals(0));
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Switching tabs preserves the inner navigation stack of previously visited tabs',
      (tester) async {
        await tester.pumpWidget(createTestApp(home: const MainLayout()));
        await tester.pumpAndSettle();

        final homeCtrl = HomeController();

        // On Tab 0, push DietScreen
        final homeContext = tester.element(find.byType(HomeScreen));
        Navigator.of(homeContext).pushNamed(AppRouter.diet);
        await tester.pumpAndSettle();
        expect(find.byType(DietScreen), findsOneWidget);

        // Switch to Records (Tab 1)
        await tester.tap(navTab('Records'));
        await tester.pumpAndSettle();
        expect(homeCtrl.currentIndex, equals(1));
        expect(find.byType(RecordsScreen), findsOneWidget);

        // Switch back to Home (Tab 0) without tapping the reset
        homeCtrl.setTab(0);
        await tester.pumpAndSettle();

        // Tab 0 should still be showing DietScreen!
        expect(find.byType(DietScreen), findsOneWidget);
      },
    );
  });

  group('Auth Isolation & Root Navigator Transitions', () {
    testWidgets(
      'AuthController.logout targets rootNavigator and unmounts MainLayout',
      (tester) async {
        await tester.pumpWidget(createTestApp(home: const MainLayout()));
        await tester.pumpAndSettle();

        expect(find.byType(MainLayout), findsOneWidget);

        // Call logout passing context of an inner tab
        final innerContext = tester.element(find.byType(HomeScreen));
        await authController.logout(innerContext);
        await tester.pumpAndSettle();

        // MainLayout must be completely unmounted from the root
        expect(find.byType(MainLayout), findsNothing);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(HomeController().currentIndex, equals(0));
      },
    );

    testWidgets(
      'Unauthenticated route guards redirect addRecord and routineSuccess to login',
      (tester) async {
        await fakeAuth.signOut();

        final addRecordRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.addRecord),
        );
        expect(addRecordRoute.settings.name, equals(AppRouter.login));

        final routineSuccessRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.routineSuccess),
        );
        expect(routineSuccessRoute.settings.name, equals(AppRouter.login));
      },
    );

    testWidgets(
      'Authenticated access generates valid routes for addRecord and routineSuccess',
      (tester) async {
        final addRecordRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.addRecord),
        );
        expect(addRecordRoute.settings.name, equals(AppRouter.addRecord));

        final routineSuccessRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.routineSuccess),
        );
        expect(
          routineSuccessRoute.settings.name,
          equals(AppRouter.routineSuccess),
        );
      },
    );
  });

  group('PremiumStatusScreen Safe Navigation', () {
    testWidgets(
      'Tapping "Jump to Home" returns to root of Tab 0 without duplicating MainLayout',
      (tester) async {
        final homeCtrl = HomeController();

        await tester.pumpWidget(
          createTestApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PremiumStatusScreen(
                          status: PremiumPurchaseStatus.success,
                          amount: 804.0,
                          planName: 'Yearly Premium',
                          serviceCharge: 2870.0,
                          discount: 2100.0,
                          gst: 34.02,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Premium Status'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Push screen
        await tester.tap(find.text('Open Premium Status'));
        await tester.pumpAndSettle();

        expect(find.byType(PremiumStatusScreen), findsOneWidget);

        // Tap Jump to Home
        await tester.ensureVisible(find.text('Jump to Home'));
        await tester.tap(find.text('Jump to Home'));
        await tester.pumpAndSettle();

        // Must pop cleanly back to the origin, without creating a MainLayout
        expect(find.byType(PremiumStatusScreen), findsNothing);
        expect(find.text('Open Premium Status'), findsOneWidget);
        expect(find.byType(MainLayout), findsNothing);
        expect(homeCtrl.currentIndex, equals(0));
      },
    );

    testWidgets(
      'Back button on PremiumStatusScreen (success) safely pops to root and does not recreate shell',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PremiumStatusScreen(
                          status: PremiumPurchaseStatus.success,
                          amount: 804.0,
                          planName: 'Yearly Premium',
                          serviceCharge: 2870.0,
                          discount: 2100.0,
                          gst: 34.02,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Status'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Status'));
        await tester.pumpAndSettle();

        expect(find.byType(PremiumStatusScreen), findsOneWidget);

        // Tap accessible back button
        await tester.tap(find.bySemanticsLabel('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(PremiumStatusScreen), findsNothing);
        expect(find.text('Open Status'), findsOneWidget);
        expect(find.byType(MainLayout), findsNothing);
      },
    );
  });

  group('Routine Intake & Success Flow Regression', () {
    testWidgets(
      'RoutineDetailScreen confirm dialog safely pops dialog and replaces route with RoutineSuccessScreen',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              body: RoutineDetailScreen(title: 'Breakfast', time: '08:30 AM'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(RoutineDetailScreen), findsOneWidget);

        // Tap "Intake Breakfast" button to open confirmation dialog
        await tester.tap(find.text('Intake Breakfast'));
        await tester.pumpAndSettle();

        expect(find.text('Confirm Breakfast'), findsOneWidget);
        expect(find.text('Yes, Done'), findsOneWidget);

        // Tap "Yes, Done"
        await tester.tap(find.text('Yes, Done'));
        await tester.pumpAndSettle();

        // Should transition to RoutineSuccessScreen without error
        expect(find.byType(RoutineSuccessScreen), findsOneWidget);
        expect(find.byType(RoutineDetailScreen), findsNothing);
      },
    );

    testWidgets(
      'RoutineSuccessScreen _navigateToDiet pops back to DietScreen without creating duplicate screens',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.diet);
                  },
                  child: const Text('Go to Diet'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Go to Diet
        await tester.tap(find.text('Go to Diet'));
        await tester.pumpAndSettle();
        expect(find.byType(DietScreen), findsOneWidget);

        // 2. Push RoutineSuccessScreen
        final dietContext = tester.element(find.byType(DietScreen));
        Navigator.of(
          dietContext,
        ).push(MaterialPageRoute(builder: (_) => const RoutineSuccessScreen()));
        await tester.pumpAndSettle();
        expect(find.byType(RoutineSuccessScreen), findsOneWidget);

        // 3. Tap "See in Diet Section"
        await tester.tap(find.text('See in Diet Section'));
        await tester.pumpAndSettle();

        // Must pop back to DietScreen and have exactly ONE DietScreen in the hierarchy
        expect(find.byType(RoutineSuccessScreen), findsNothing);
        expect(find.byType(DietScreen), findsOneWidget);
      },
    );
  });
}
