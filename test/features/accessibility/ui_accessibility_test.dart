import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';
import 'package:nuroved_patient/features/auth/widgets/auth_form.dart';
import 'package:nuroved_patient/features/family/screens/add_family_member_screen.dart';
import 'package:nuroved_patient/features/family/screens/edit_family_member_screen.dart';
import 'package:nuroved_patient/features/family/screens/family_profile_screen.dart';
import 'package:nuroved_patient/features/home/widgets/graph_card.dart';
import 'package:nuroved_patient/features/home/widgets/home_header.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/profile/screens/edit_profile_screen.dart';
import 'package:nuroved_patient/features/profile/widgets/metric_card.dart';
import 'package:nuroved_patient/features/profile/widgets/profile_header.dart';
import 'package:nuroved_patient/features/routine/screens/add_medicine_screen.dart';
import 'package:nuroved_patient/features/routine/screens/routine_detail_screen.dart';
import 'package:nuroved_patient/features/visits/screens/add_visit_screen.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() {
    ProfileController.resetForTesting();
  });

  tearDown(() {
    ProfileController.resetForTesting();
  });

  final dummyProfileData = {
    'name': 'John Doe',
    'email': 'john@example.com',
    'dob': '1990-01-01',
    'gender': 'male',
    'bloodGroup': 'B+',
    'height': '175',
    'weight': '70',
    'phone': '+1234567890',
  };

  group('TASK 8: Touch Targets (>= 48x48) & Accessibility Semantics', () {
    testWidgets('AddFamilyMemberScreen back button meets 48x48 touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AddFamilyMemberScreen())),
      );
      await tester.pumpAndSettle();

      final backButtonFinder = find.bySemanticsLabel('Back');
      expect(backButtonFinder, findsOneWidget);

      final size = tester.getSize(backButtonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('EditFamilyMemberScreen back button meets 48x48 touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditFamilyMemberScreen(
              memberData: {'id': 'fam_1', 'name': 'Sarah', 'relation': 'Wife'},
              index: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButtonFinder = find.bySemanticsLabel('Back');
      expect(backButtonFinder, findsOneWidget);

      final size = tester.getSize(backButtonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('FamilyProfilesScreen back button meets 48x48 touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FamilyProfilesScreen())),
      );
      await tester.pumpAndSettle();

      final backButtonFinder = find.bySemanticsLabel('Back');
      expect(backButtonFinder, findsOneWidget);

      final size = tester.getSize(backButtonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('AddMedicineScreen back button meets 48x48 touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AddMedicineScreen())),
      );
      await tester.pumpAndSettle();

      final backButtonFinder = find.bySemanticsLabel('Back');
      expect(backButtonFinder, findsOneWidget);

      final size = tester.getSize(backButtonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('AddVisitScreen back button meets 48x48 touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AddVisitScreen())),
      );
      await tester.pumpAndSettle();

      final backButtonFinder = find.bySemanticsLabel('Back');
      expect(backButtonFinder, findsOneWidget);

      final size = tester.getSize(backButtonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
      'ProfileHeader settings button meets 48x48 touch target and has semantics',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: ProfileHeader())),
        );
        await tester.pumpAndSettle();

        final settingsFinder = find.bySemanticsLabel('Settings');
        expect(settingsFinder, findsOneWidget);

        final size = tester.getSize(settingsFinder);
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      },
    );

    testWidgets(
      'RoutineDetailScreen back and edit buttons meet 48x48 touch target',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoutineDetailScreen(title: 'Breakfast', time: '08:00 AM'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final backFinder = find.bySemanticsLabel('Back');
        expect(backFinder, findsOneWidget);
        final backSize = tester.getSize(backFinder);
        expect(backSize.width, greaterThanOrEqualTo(48.0));
        expect(backSize.height, greaterThanOrEqualTo(48.0));

        final editFinder = find.bySemanticsLabel('Edit Routine');
        expect(editFinder, findsOneWidget);
        final editSize = tester.getSize(editFinder);
        expect(editSize.width, greaterThanOrEqualTo(48.0));
        expect(editSize.height, greaterThanOrEqualTo(48.0));
      },
    );

    testWidgets(
      'EditProfileScreen back button has tooltip and >= 48x48 bounds',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EditProfileScreen(initialData: dummyProfileData),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final backFinder = find.byTooltip('Back');
        expect(backFinder, findsOneWidget);

        final size = tester.getSize(backFinder);
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      },
    );
  });

  group('TASK 8: Icon Tooltips & Form Accessibility', () {
    testWidgets('HomeHeader notification and crown buttons have tooltips', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeHeader())),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Notifications'), findsOneWidget);
      expect(find.byTooltip('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets(
      'AuthForm password visibility toggles expose accessibility tooltips',
      (tester) async {
        final authController = AuthController(
          authRepository: FakeAuthRepository(),
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<AuthController>.value(
            value: authController,
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(child: AuthForm(isSignUp: true)),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially passwords hidden -> tooltips should be "Show password"
        expect(find.byTooltip('Show password'), findsNWidgets(2));

        // Toggle first password
        await tester.tap(find.byTooltip('Show password').first);
        await tester.pumpAndSettle();

        expect(find.byTooltip('Hide password'), findsOneWidget);
        expect(find.byTooltip('Show password'), findsOneWidget);
      },
    );
  });

  group('TASK 8: Narrow Viewport (320px) RenderFlex Resilience', () {
    testWidgets(
      'Screens render without horizontal overflow on narrow 320px device',
      (tester) async {
        // Set viewport to 320 logical pixels wide (e.g., iPhone SE 1st gen)
        tester.view.physicalSize = const Size(320 * 2, 568 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. EditProfileScreen
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EditProfileScreen(initialData: dummyProfileData),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 2. FamilyProfilesScreen
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: FamilyProfilesScreen())),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 3. AddFamilyMemberScreen
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AddFamilyMemberScreen())),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 4. EditFamilyMemberScreen
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EditFamilyMemberScreen(
                memberData: {
                  'id': 'fam_1',
                  'name': 'Alexander Montgomery',
                  'relation': 'Grandfather',
                },
                index: 0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 5. RoutineDetailScreen with long text
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoutineDetailScreen(
                title: 'Nutritious High Protein Breakfast Routine',
                time: '08:30 AM',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 6. AddVisitScreen
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AddVisitScreen())),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group(
    'TASK 8: Text Scaling (1.5x - 2.0x) Resilience & Overflow Prevention',
    () {
      testWidgets(
        'MetricCard does not vertically overflow under 2.0x text scaler',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: MediaQuery(
                      data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
                      child: MetricCard(
                        icon: Icons.favorite,
                        value: '120/80',
                        label: 'Blood Pressure',
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('Header titles adapt gracefully with 1.5x text scaler', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360 * 2, 640 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
                child: RoutineDetailScreen(
                  title: 'Cardiology Morning Routine',
                  time: '09:00 AM',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    },
  );

  group('TASK 8: Color Contrast WCAG AA Compliance', () {
    testWidgets(
      'GraphCard Visits label uses AppColors.textSecondary for WCAG compliance',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: GraphCard())),
        );
        await tester.pumpAndSettle();

        final visitsTextFinder = find.text('Visits');
        expect(visitsTextFinder, findsOneWidget);

        final Text textWidget = tester.widget(visitsTextFinder);
        expect(textWidget.style?.color, equals(AppColors.textSecondary));

        // Calculate relative luminance and verify WCAG AA (>= 4.5:1) contrast against white (#FFFFFF)
        const backgroundLum = 1.0;
        // AppColors.textSecondary is #475569
        const r = 0x47 / 255.0;
        const g = 0x55 / 255.0;
        const b = 0x69 / 255.0;

        double toLinear(double c) => c <= 0.03928
            ? c / 12.92
            : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055);
        final textLum =
            0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b);

        final contrastRatio = (backgroundLum + 0.05) / (textLum + 0.05);
        expect(contrastRatio, greaterThanOrEqualTo(4.5));
      },
    );
  });
}
