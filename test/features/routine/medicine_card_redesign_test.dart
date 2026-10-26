import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/routine_screen.dart';
import 'package:nuroved_patient/features/routine/widgets/medicine_tile.dart';
import 'package:nuroved_patient/features/routine/widgets/routine_tile.dart';
import 'package:nuroved_patient/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences testPrefs;
  late LocaleController localeController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    testPrefs = await SharedPreferences.getInstance();
    localeController = LocaleController.instance;
    await localeController.init(preferences: testPrefs);
    await localeController.setLanguageCode('en', preferences: testPrefs);

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
      initialFamily: [
        const FamilyMember(
          id: 'subject-family-001',
          name: 'Spouse Test',
          relation: 'Spouse',
        ),
      ],
    );
    RoutineController.resetForTesting();
  });

  Widget buildTestTile({
    required Widget child,
    Locale locale = const Locale('en'),
    double width = 360,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }

  Widget buildRoutineScreenApp({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RoutineScreen(),
    );
  }

  group('MedicineTile Layout & Responsiveness', () {
    testWidgets(
      'renders standard medicine name, chips, and badge without overflow',
      (tester) async {
        await tester.pumpWidget(
          buildTestTile(
            child: MedicineTile(
              name: 'Atorvastatin 10mg',
              dosage: '10mg',
              instruction: '1 tablet * 09:00 * Take before bed',
              isCompleted: false,
              sourceDisplay: 'Verified Prescription',
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Atorvastatin 10mg'), findsOneWidget);
        expect(find.text('10mg • 1 tablet'), findsOneWidget);
        expect(find.text('09:00'), findsOneWidget);
        expect(find.text('Take before bed'), findsOneWidget);
        expect(find.text('Verified Prescription'), findsOneWidget);
        expect(find.text('Pending'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders long compound medicine name naturally without character stacking',
      (tester) async {
        const longName =
            'Amoxicillin and Clavulanate Potassium 875mg/125mg Tablets';
        await tester.pumpWidget(
          buildTestTile(
            width: 320,
            child: MedicineTile(
              name: longName,
              instruction:
                  '1 tablet * 08:00 * Take with breakfast and full glass of water',
              isCompleted: false,
              sourceDisplay: 'Verified Prescription',
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(longName), findsOneWidget);
        final textWidget = tester.widget<Text>(find.text(longName));
        expect(textWidget.softWrap, isTrue);

        final renderBox = tester.renderObject<RenderBox>(find.text(longName));
        expect(renderBox.size.width, greaterThan(120.0));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('expands and collapses multi-line instructions on tap', (
      tester,
    ) async {
      const longInstruction =
          'Take with a full glass of water immediately after a meal. Do not crush, chew, or break the controlled-release tablet. Monitor blood glucose closely for 2 weeks.';

      await tester.pumpWidget(
        buildTestTile(
          child: MedicineTile(
            name: 'Metformin 500mg',
            instruction: '1 tablet * 08:00 * $longInstruction',
            isCompleted: false,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Show more'), findsOneWidget);
      expect(find.text('Show less'), findsNothing);

      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
      expect(find.text('Show more'), findsNothing);

      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();

      expect(find.text('Show more'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports Gujarati localization cleanly', (tester) async {
      await tester.pumpWidget(
        buildTestTile(
          locale: const Locale('gu'),
          child: MedicineTile(
            name: 'એટોરવાસ્ટેટિન ૧૦ મિગ્રા',
            instruction: '૧ ગોળી * ૦૯:૦૦ * રાત્રે સૂતા પહેલા લો',
            isCompleted: false,
            sourceDisplay: 'Verified Prescription',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ચકાસાયેલ પ્રિસ્ક્રિપ્શન'), findsOneWidget);
      expect(find.text('બાકી'), findsOneWidget);
      expect(find.text('એટોરવાસ્ટેટિન ૧૦ મિગ્રા'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports Hindi localization cleanly', (tester) async {
      await tester.pumpWidget(
        buildTestTile(
          locale: const Locale('hi'),
          child: MedicineTile(
            name: 'एटोरवास्टेटिन 10mg',
            instruction: '1 गोली * 09:00 * सोने से पहले लें',
            isCompleted: true,
            sourceDisplay: 'Verified Prescription',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('सत्यापित पर्ची'), findsOneWidget);
      expect(find.text('ली गई'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('zero overflow on 320px narrow constraint', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestTile(
          width: 320,
          child: MedicineTile(
            name: 'Atorvastatin Calcium Extended Release 40mg',
            instruction: '2 tablets * 21:00 * Take at bedtime with water',
            isCompleted: false,
            sourceDisplay: 'Verified Prescription',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('invokes onTap and onDelete callbacks', (tester) async {
      bool tapped = false;
      bool deleted = false;

      await tester.pumpWidget(
        buildTestTile(
          child: MedicineTile(
            name: 'Aspirin 75mg',
            instruction: '1 tablet * 09:00',
            isCompleted: false,
            onTap: () => tapped = true,
            onDelete: () => deleted = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      expect(tapped, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });
  });

  group('RoutineScreen Medicines Tab Redesign', () {
    testWidgets('renders Routine tab by default and preserves meals', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutineScreenApp());
      await tester.pumpAndSettle();

      expect(find.text('Meals'), findsOneWidget);
      expect(find.text('Medicines'), findsOneWidget);
      expect(find.byType(RoutineTile), findsWidgets);
    });

    testWidgets(
      'switches to Medicines tab and renders Due and Completed sections',
      (tester) async {
        await tester.pumpWidget(buildRoutineScreenApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Medicines'));
        await tester.pumpAndSettle();

        expect(find.text('Due Doses'), findsOneWidget);
        expect(find.text('Completed Doses'), findsOneWidget);

        expect(find.text('3 Total'), findsWidgets);
        expect(find.text('Due Doses: 2'), findsOneWidget);

        expect(find.byType(MedicineTile), findsNWidgets(3));
        expect(find.text('Atorvastatin 10mg'), findsOneWidget);
        expect(find.text('Aspirin 75mg'), findsOneWidget);
        expect(find.text('Metformin 500mg'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'tapping completion checkbox moves medicine to completed section',
      (tester) async {
        await tester.pumpWidget(buildRoutineScreenApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Medicines'));
        await tester.pumpAndSettle();

        expect(find.text('Due Doses: 2'), findsOneWidget);

        final uncompletedCheckboxes = find.byIcon(Icons.radio_button_unchecked);
        expect(uncompletedCheckboxes, findsNWidgets(2));
        await tester.tap(uncompletedCheckboxes.first);
        await tester.pumpAndSettle();

        expect(find.text('Due Doses: 1'), findsOneWidget);
        expect(find.text('2/3 Completed'), findsOneWidget);
      },
    );

    testWidgets('renders empty state when subject has no medicines', (
      tester,
    ) async {
      final controller = RoutineController();
      controller.setSubject('subject-family-001');

      await tester.pumpWidget(buildRoutineScreenApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Medicines'));
      await tester.pumpAndSettle();

      expect(find.text('No reminders for today'), findsOneWidget);
      expect(
        find.text('Add your daily medicines or wellness routines.'),
        findsOneWidget,
      );
      expect(find.text('Add Medicine'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'shows all scheduled doses completed banner when all medicines are taken',
      (tester) async {
        final controller = RoutineController();
        for (int i = 0; i < controller.medicines.length; i++) {
          if (controller.medicines[i]['isCompleted'] != true) {
            controller.toggleMedicine(i);
          }
        }

        await tester.pumpWidget(buildRoutineScreenApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Medicines'));
        await tester.pumpAndSettle();

        expect(find.text('All scheduled doses completed!'), findsOneWidget);
        expect(find.text('3/3 Completed'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('delete button triggers confirmation dialog', (tester) async {
      await tester.pumpWidget(buildRoutineScreenApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Medicines'));
      await tester.pumpAndSettle();

      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsWidgets);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Routine'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Routine'), findsNothing);
    });
  });
}
