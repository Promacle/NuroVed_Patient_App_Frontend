import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:nuroved_patient/features/access/screens/access_screen.dart';
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
          home: const AccessScreen(),
        );
      },
    );
  }

  group('AccessScreen Localization Tests', () {
    testWidgets('renders English strings by default', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      expect(find.text('Care Access'), findsOneWidget);
      expect(find.text('Manage Access'), findsOneWidget);
      expect(find.text('Access Request'), findsOneWidget);
      expect(find.text('Grant New Access'), findsOneWidget);
    });

    testWidgets('switches reactively to Gujarati', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      await controller.setLanguageCode('gu', preferences: testPrefs);
      await tester.pumpAndSettle();

      expect(find.text('કેર એક્સેસ'), findsOneWidget);
      expect(find.text('ઍક્સેસ મેનેજ કરો'), findsOneWidget);
      expect(find.text('ઍક્સેસ વિનંતી'), findsOneWidget);
      expect(find.text('નવી ઍક્સેસ આપો'), findsOneWidget);
    });

    testWidgets('switches reactively to Hindi', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      await controller.setLanguageCode('hi', preferences: testPrefs);
      await tester.pumpAndSettle();

      expect(find.text('केयर एक्सेस'), findsOneWidget);
      expect(find.text('एक्सेस प्रबंधित करें'), findsOneWidget);
      expect(find.text('एक्सेस अनुरोध'), findsOneWidget);
      expect(find.text('नया एक्सेस प्रदान करें'), findsOneWidget);
    });
  });
}
