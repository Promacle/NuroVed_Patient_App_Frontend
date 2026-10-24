import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/widgets/backend_status_banner.dart';
import 'package:nuroved_patient/features/auth/widgets/auth_header.dart';

void main() {
  testWidgets('App launches with MyApp and renders MaterialApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets(
    'BackendStatusBanner displays unconfigured state when config absent',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BackendStatusBanner())),
      );

      expect(find.text('Backend Not Configured'), findsOneWidget);
      expect(
        find.textContaining('Operating in local in-memory mode'),
        findsOneWidget,
      );
    },
  );

  testWidgets('AuthHeader fits the title and subtitle in the allocated space', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 75,
              child: AuthHeader(
                titles: ['Sign Up For Free!', 'Create Account'],
                subTitles: ['', 'Complete your profile'],
                imageAsset: AppAssets.signUpDog,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
