import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:nuroved_patient/features/settings/screens/settings_screen.dart';
import 'package:nuroved_patient/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences testPrefs;
  late LocaleController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    testPrefs = await SharedPreferences.getInstance();
    controller = LocaleController.instance;
    await controller.init(preferences: testPrefs);
    await controller.setLanguageCode('en', preferences: testPrefs);
  });

  Widget buildReactiveApp() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          locale: controller.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        );
      },
    );
  }

  group('Language Selection & Dynamic Localization Tests (Task 13A)', () {
    testWidgets(
      '1. Initial state displays English settings and native label in language tile',
      (tester) async {
        await tester.pumpWidget(buildReactiveApp());
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Language bottom sheet presents all supported languages with native names',
      (tester) async {
        await tester.pumpWidget(buildReactiveApp());
        await tester.pumpAndSettle();

        // Tap Language card
        await tester.tap(find.text('Language'));
        await tester.pumpAndSettle();

        // Check modal bottom sheet title & language options
        expect(find.text('Select Language'), findsOneWidget);
        expect(
          find.text('English'),
          findsNWidgets(2),
        ); // Tile subtitle + bottom sheet option
        expect(find.text('ગુજરાતી'), findsOneWidget);
        expect(find.text('हिन्दी'), findsOneWidget);

        // English option has the checkmark icon
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      },
    );

    testWidgets(
      '3. Selecting Gujarati immediately updates UI to Gujarati without app restart',
      (tester) async {
        await tester.pumpWidget(buildReactiveApp());
        await tester.pumpAndSettle();

        // Open language sheet
        await tester.tap(find.text('Language'));
        await tester.pumpAndSettle();

        // Tap Gujarati
        await tester.tap(find.text('ગુજરાતી'));
        await tester.pumpAndSettle();

        // Bottom sheet is dismissed
        expect(find.text('Select Language'), findsNothing);

        // UI instantly updates to Gujarati strings
        expect(find.text('સેટિંગ્સ'), findsOneWidget);
        expect(find.text('પસંદગીઓ'), findsOneWidget);
        expect(find.text('ભાષા'), findsOneWidget);
        expect(find.text('ગુજરાતી'), findsOneWidget);

        // Controller and persistence verification
        expect(controller.locale.languageCode, equals('gu'));
        expect(
          testPrefs.getString(LocaleController.prefKeyLanguage),
          equals('gu'),
        );
      },
    );

    testWidgets(
      '4. Selecting Hindi immediately updates UI to Hindi and persists preference',
      (tester) async {
        await tester.pumpWidget(buildReactiveApp());
        await tester.pumpAndSettle();

        // Open language sheet
        await tester.tap(find.text('Language'));
        await tester.pumpAndSettle();

        // Tap Hindi
        await tester.tap(find.text('हिन्दी'));
        await tester.pumpAndSettle();

        // Bottom sheet is dismissed
        expect(find.text('Select Language'), findsNothing);

        // UI instantly updates to Hindi strings
        expect(find.text('सेटिंग्स'), findsOneWidget);
        expect(find.text('प्राथमिकताएं'), findsOneWidget);
        expect(find.text('भाषा'), findsOneWidget);
        expect(find.text('हिन्दी'), findsOneWidget);

        // Controller and persistence verification
        expect(controller.locale.languageCode, equals('hi'));
        expect(
          testPrefs.getString(LocaleController.prefKeyLanguage),
          equals('hi'),
        );
      },
    );

    testWidgets(
      '5. Switching back from Hindi/Gujarati to English works seamlessly',
      (tester) async {
        // Start in Hindi
        await controller.setLanguageCode('hi', preferences: testPrefs);

        await tester.pumpWidget(buildReactiveApp());
        await tester.pumpAndSettle();

        expect(find.text('सेटिंग્સ'), findsNothing);
        expect(find.text('सेटिंग्स'), findsOneWidget);

        // Open language sheet by tapping 'भाषा'
        await tester.tap(find.text('भाषा'));
        await tester.pumpAndSettle();

        // Select English
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        // Assert instantaneous update back to English
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(controller.locale.languageCode, equals('en'));
        expect(
          testPrefs.getString(LocaleController.prefKeyLanguage),
          equals('en'),
        );
      },
    );
  });
}
