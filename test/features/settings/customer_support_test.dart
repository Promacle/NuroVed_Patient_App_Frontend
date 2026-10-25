import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/features/settings/screens/customer_support_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableScreen() {
    return const MaterialApp(home: CustomerSupportScreen());
  }

  group('CustomerSupportScreen - Rendering & Initial State', () {
    testWidgets(
      'builds without exceptions and renders header and toggle buttons',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        expect(find.byType(CustomerSupportScreen), findsOneWidget);
        expect(find.text('Customer Support'), findsOneWidget);
        expect(find.text('About Us'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget); // Search bar
        expect(find.text('Contact Us'), findsOneWidget);
        expect(find.text('FAQ'), findsOneWidget);
      },
    );

    testWidgets(
      'renders all 5 contact options in Contact Us section by default',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        expect(find.text('Customer Service'), findsOneWidget);
        expect(find.text('Website'), findsOneWidget);
        expect(find.text('Whatsapp'), findsOneWidget);
        expect(find.text('Facebook'), findsOneWidget);
        expect(find.text('Instagram'), findsOneWidget);
      },
    );
  });

  group('CustomerSupportScreen - Tab Switching & FAQ Expandables', () {
    testWidgets(
      'switching between Contact Us and FAQ renders corresponding content',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Initially on Contact Us
        expect(find.text('Customer Service'), findsOneWidget);

        // Tap FAQ toggle
        await tester.tap(find.text('FAQ'));
        await tester.pumpAndSettle();

        // Contact options are no longer shown
        expect(find.text('Customer Service'), findsNothing);

        // FAQ questions are displayed
        expect(
          find.text('What is NuroVed and how does it work?'),
          findsOneWidget,
        );
        expect(
          find.text('How is NuroVed different from other health apps?'),
          findsOneWidget,
        );
        expect(
          find.text('Is my health data safe with NuroVed?'),
          findsOneWidget,
        );

        // Switch back to Contact Us
        await tester.tap(find.text('Contact Us'));
        await tester.pumpAndSettle();

        expect(find.text('Customer Service'), findsOneWidget);
        expect(
          find.text('What is NuroVed and how does it work?'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'FAQ expandable items toggle question answers open and closed',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Switch to FAQ
        await tester.tap(find.text('FAQ'));
        await tester.pumpAndSettle();

        const answerSnippet = 'NuroVed is an AI-powered health companion';

        // Answer should not be visible initially
        expect(find.textContaining(answerSnippet), findsNothing);

        // Tap first FAQ question to expand
        await tester.tap(find.text('What is NuroVed and how does it work?'));
        await tester.pumpAndSettle();

        // Answer is now visible
        expect(find.textContaining(answerSnippet), findsOneWidget);

        // Tap again to collapse
        await tester.tap(find.text('What is NuroVed and how does it work?'));
        await tester.pumpAndSettle();

        // Answer is collapsed
        expect(find.textContaining(answerSnippet), findsNothing);
      },
    );
  });

  group('CustomerSupportScreen - Search Filtering', () {
    testWidgets(
      'search filters contact options and displays empty state when unmatched',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Enter search query matching "Whatsapp"
        await tester.enterText(find.byType(TextField), 'whats');
        await tester.pumpAndSettle();

        expect(find.text('Whatsapp'), findsOneWidget);
        expect(find.text('Customer Service'), findsNothing);
        expect(find.text('Facebook'), findsNothing);

        // Enter search query with no match
        await tester.enterText(find.byType(TextField), 'zzzznotfound');
        await tester.pumpAndSettle();

        expect(
          find.text('No contact options match your search.'),
          findsOneWidget,
        );

        // Clear search restores all options
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        expect(find.text('Customer Service'), findsOneWidget);
        expect(find.text('Website'), findsOneWidget);
        expect(find.text('Whatsapp'), findsOneWidget);
      },
    );

    testWidgets('search filters FAQs correctly', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Switch to FAQ
      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      // Search for "allergies"
      await tester.enterText(find.byType(TextField), 'allergies');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Can NuroVed handle specific needs like allergies or medical conditions?',
        ),
        findsOneWidget,
      );
      expect(find.text('What is NuroVed and how does it work?'), findsNothing);

      // Search for unmatched query
      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No FAQs match your search.'), findsOneWidget);
    });
  });

  group('CustomerSupportScreen - Navigation & Contact Action Safety', () {
    testWidgets('tapping Back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerSupportScreen(),
                    ),
                  );
                },
                child: const Text('Open Support'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Support'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerSupportScreen), findsOneWidget);

      // Tap Back button
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerSupportScreen), findsNothing);
      expect(find.text('Open Support'), findsOneWidget);
    });

    testWidgets(
      'Customer Service action displays honest unconfigured message',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Customer Service'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.textContaining('Direct phone support is currently unconfigured'),
          findsOneWidget,
        );

        // Close dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets('Whatsapp action displays honest unconfigured message', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Whatsapp'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.textContaining('WhatsApp support is currently unconfigured'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'Facebook and Instagram actions display clear inactive channel message',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Facebook'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Facebook'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.textContaining('The Facebook support channel is not yet active'),
          findsOneWidget,
        );

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);

        await tester.ensureVisible(find.text('Instagram'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Instagram'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.textContaining(
            'The Instagram support channel is not yet active',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Website action handles URL launch without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Tapping website triggers launchUrl / fallback dialog safely
      await tester.tap(find.text('Website'));
      await tester.pumpAndSettle();

      // Either launched or dialog displayed, neither throws
      expect(tester.takeException(), isNull);
    });
  });
}
