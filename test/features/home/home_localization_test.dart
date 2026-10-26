import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:nuroved_patient/features/home/screens/home_screen.dart';
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
          home: const Scaffold(body: HomeScreen()),
        );
      },
    );
  }

  group('HomeScreen Localization Tests', () {
    testWidgets('renders English strings by default', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      expect(find.text("Let's take the next step\nfor your health!"), findsOneWidget);
      expect(find.text('Health Timeline'), findsOneWidget);
      expect(find.text('Recent Records'), findsOneWidget);
    });

    testWidgets('switches reactively to Gujarati', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      await controller.setLanguageCode('gu', preferences: testPrefs);
      await tester.pumpAndSettle();

      expect(find.text('ચાલો તમારા સ્વાસ્થ્ય માટે\nઆગળનું પગલું ભરીએ!'), findsOneWidget);
      expect(find.text('આરોગ્ય સમયરેખા'), findsOneWidget);
      expect(find.text('તાજેતરના રેકોર્ડ્સ'), findsOneWidget);
    });

    testWidgets('switches reactively to Hindi', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      await controller.setLanguageCode('hi', preferences: testPrefs);
      await tester.pumpAndSettle();

      expect(find.text('आइए आपके स्वास्थ्य के लिए\nअगला कदम उठाएं!'), findsOneWidget);
      expect(find.text('स्वास्थ्य समयरेखा'), findsOneWidget);
      expect(find.text('हाल के रिकॉर्ड्स'), findsOneWidget);
    });
  });
}
