import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app.dart';
import 'package:nuroved_patient/core/widgets/backend_status_banner.dart';

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
}
