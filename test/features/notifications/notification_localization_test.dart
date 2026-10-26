import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:nuroved_patient/features/notifications/screens/notification_screen.dart';
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
          home: const NotificationsScreen(),
        );
      },
    );
  }

  group('NotificationsScreen Localization Tests', () {
    testWidgets('renders English strings by default', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text("Time For Mom's Medicine"), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Your Data is Encrypted'), findsOneWidget);
    });

    testWidgets('switches reactively to Gujarati', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      await controller.setLanguageCode('gu', preferences: testPrefs);
      await tester.pumpAndSettle();

      expect(find.text('સૂચના'), findsOneWidget);
      expect(find.text('બધા વાંચેલા તરીકે ચિહ્નિત કરો'), findsOneWidget);
      expect(find.text('આજે'), findsOneWidget);
      expect(find.text('આ અઠવાડિયે'), findsOneWidget);
      expect(find.text('તમારો ડેટા એન્ક્રિપ્ટેડ છે'), findsOneWidget);
    });

    testWidgets('switches reactively to Hindi', (tester) async {
      await tester.pumpWidget(buildReactiveApp());
      await tester.pumpAndSettle();

      await controller.setLanguageCode('hi', preferences: testPrefs);
      await tester.pumpAndSettle();

      expect(find.text('अधिसूचना'), findsOneWidget);
      expect(find.text('सभी को पढ़ा हुआ चिह्नित करें'), findsOneWidget);
      expect(find.text('आज'), findsOneWidget);
      expect(find.text('इस सप्ताह'), findsOneWidget);
      expect(find.text('आपका डेटा एन्क्रिप्टेड है'), findsOneWidget);
    });
  });
}
