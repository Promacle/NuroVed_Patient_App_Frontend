import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/widgets/empty_state_view.dart';
import 'package:nuroved_patient/features/settings/screens/report_problem_screen.dart';

void main() {
  Widget buildTestScreen({List<Map<String, dynamic>>? initialProblems}) {
    return MaterialApp(
      home: ReportProblemScreen(initialProblems: initialProblems),
    );
  }

  group('ReportProblemScreen UI & Hierarchy Tests (Task 11B)', () {
    testWidgets(
      '1. Renders balanced header, describe issue card, and past problems section',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        // Header
        expect(find.text('Report a Problem'), findsOneWidget);
        expect(
          find.text('Describe bugs or anomalies to improve NuroVed'),
          findsOneWidget,
        );
        expect(find.byTooltip('Back'), findsOneWidget);

        // Input card
        expect(find.text('Describe your issue'), findsOneWidget);
        expect(
          find.text('Include what screen you were on and what went wrong'),
          findsOneWidget,
        );
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('0 / 500'), findsOneWidget);
        expect(find.text('Submit Report'), findsOneWidget);

        // History section
        expect(find.text('Past Reported Problems'), findsOneWidget);
        expect(find.text('Sample Reference'), findsNWidgets(2));
      },
    );

    testWidgets(
      '2. Rejects empty and whitespace-only input with clear inline validation',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        // Submit empty
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();

        expect(
          find.text('Please describe the problem you experienced.'),
          findsOneWidget,
        );

        // Submit whitespace only
        await tester.enterText(find.byType(TextField), '     ');
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();

        expect(
          find.text('Please describe the problem you experienced.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '3. Rejects input shorter than 10 characters with detail guidance',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Short bug');
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();

        expect(
          find.text('Please provide more detail (minimum 10 characters).'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '4. Submits valid input, adds genuine report card with Saved on Device badge, and clears input',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        const problemText =
            'The medication routine reminders did not play sound on iOS.';

        await tester.enterText(find.byType(TextField), problemText);
        await tester.pumpAndSettle();

        expect(find.text('${problemText.length} / 500'), findsOneWidget);

        await tester.tap(find.text('Submit Report'));
        await tester.pump(); // Start submission

        // Verify loading button state
        expect(find.text('Recording Diagnostic...'), findsOneWidget);

        // Advance to complete submission
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        // Text field is cleared
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);

        // SnackBar feedback displayed
        expect(
          find.text('Report saved to local device diagnostics.'),
          findsOneWidget,
        );

        // New card is inserted at top with genuine device badge
        expect(find.text('Saved on Device'), findsOneWidget);
        expect(find.text(problemText), findsOneWidget);
        expect(find.text('Just now'), findsOneWidget);

        // History count updated to 3
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Duplicate submissions are prevented while submission is in flight',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'A genuine healthcare bug description for testing duplicate taps.',
        );

        // Tap submit multiple times rapidly
        await tester.tap(find.text('Submit Report'));
        await tester.pump(const Duration(milliseconds: 50));

        // Submit button is in disabled/submitting state
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);

        // Finish submission
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        // Exactly one new report was added (total 3 = 1 new + 2 demo)
        expect(find.text('Saved on Device'), findsOneWidget);
      },
    );

    testWidgets(
      '6. Invalid submission preserves user entered description in text field',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        const tooShortText = 'Help me';
        await tester.enterText(find.byType(TextField), tooShortText);
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();

        // Description is preserved for the user to edit
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, tooShortText);
      },
    );

    testWidgets('7. Empty history list renders EmptyStateView gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen(initialProblems: []));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('No Past Reports'), findsOneWidget);
      expect(
        find.text(
          'Any problems you report on this device will be recorded here for local diagnostic tracking.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('8. Back button meets 48x48 touch target and navigates back', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportProblemScreen(),
                  ),
                );
              },
              child: const Text('Launch Report'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Report'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportProblemScreen), findsOneWidget);

      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(backButton);
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(ReportProblemScreen), findsNothing);
      expect(find.text('Launch Report'), findsOneWidget);
    });

    testWidgets(
      '9. Narrow viewport (320px) renders without horizontal RenderFlex overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Report a Problem'), findsOneWidget);
        expect(find.text('Describe your issue'), findsOneWidget);
      },
    );

    testWidgets(
      '10. Large text scaling (1.5x) adapts gracefully without overflow',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: buildTestScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Report a Problem'), findsOneWidget);
      },
    );
  });
}
