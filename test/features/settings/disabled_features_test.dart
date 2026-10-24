import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/features/access/screens/access_screen.dart';
import 'package:nuroved_patient/features/diet/screens/ai_diet_planner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/diet_output_screen.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_screen.dart';
import 'package:nuroved_patient/features/premium/screens/purchase_screen.dart';
import 'package:nuroved_patient/features/settings/screens/settings_screen.dart';

void main() {
  group('Disabled Features & Honest State Tests', () {
    testWidgets('FoodScannerScreen displays honest unavailable state without mock data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food Scanner Unavailable'), findsOneWidget);
      expect(
        find.textContaining('Safety First — No Mock Nutritional Claims'),
        findsOneWidget,
      );
      expect(find.text('Scan Food Item'), findsNothing);
    });

    testWidgets('AiDietPlannerScreen displays honest unavailable state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AiDietPlannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meal Generation Unavailable'), findsOneWidget);
      expect(
        find.textContaining('Safety First — Clinical Validation Required'),
        findsOneWidget,
      );
    });

    testWidgets('DietOutputScreen displays honest unavailable state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: DietOutputScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meal Plan Unavailable'), findsOneWidget);
    });

    testWidgets('PurchaseScreen displays honest unavailable state without fake pay buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PurchaseScreen(
            planName: 'Yearly Premium',
            price: '₹67',
            period: '/Month',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('In-App Purchases Unavailable in MVP'), findsOneWidget);
      expect(find.text('Return to App'), findsOneWidget);
      expect(find.text('Pay'), findsNothing);
      expect(find.text('Demo: Failed'), findsNothing);
      expect(find.text('Demo: Renew'), findsNothing);
    });

    testWidgets('AccessScreen in Access Request tab displays clinician direct sharing coming soon', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AccessScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Access Request" tab
      final accessRequestTab = find.text('Access Request');
      expect(accessRequestTab, findsOneWidget);
      await tester.tap(accessRequestTab);
      await tester.pumpAndSettle();

      expect(find.text('Clinician Direct Sharing Coming Soon'), findsOneWidget);
      expect(
        find.textContaining('A clinician\'s identity is never proven by an unverified name or typed email'),
        findsOneWidget,
      );
      expect(find.text('Go to Manage Access'), findsOneWidget);
    });

    testWidgets('SettingsScreen opens Privacy Policy and Terms of Service dialogs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Privacy Policy
      final privacyTile = find.text('Privacy Policy');
      expect(privacyTile, findsOneWidget);
      await tester.ensureVisible(privacyTile);
      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('NuroVed Privacy & Data Protection'),
        findsOneWidget,
      );

      // Close dialog
      final closeBtn = find.text('Close');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      // Tap Terms of Service
      final termsTile = find.text('Terms of Service');
      expect(termsTile, findsOneWidget);
      await tester.ensureVisible(termsTile);
      await tester.tap(termsTile);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('NuroVed Terms of Service'),
        findsOneWidget,
      );
    });
  });
}
