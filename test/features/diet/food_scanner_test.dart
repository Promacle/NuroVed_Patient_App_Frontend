import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/errors/failures.dart';
import 'package:nuroved_patient/core/models/scanned_food_product.dart';
import 'package:nuroved_patient/core/services/fake_nutrition_service.dart';
import 'package:nuroved_patient/core/services/open_food_facts_service.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_screen.dart';
import 'package:nuroved_patient/features/diet/screens/scanned_product_result_screen.dart';

void main() {
  const sampleNutellaJson = '''
  {
    "code": "3017620422003",
    "status": 1,
    "status_verbose": "product found",
    "product": {
      "product_name": "Nutella Hazelnut Spread",
      "brands": "Ferrero",
      "serving_size": "15 g",
      "image_url": "https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.jpg",
      "nutriments": {
        "energy-kcal_100g": 539,
        "energy-kj_100g": 2252,
        "carbohydrates_100g": 57.5,
        "sugars_100g": 56.3,
        "proteins_100g": 6.3,
        "fat_100g": 30.9,
        "saturated-fat_100g": 10.6,
        "fiber_100g": 0.0,
        "salt_100g": 0.107,
        "sodium_100g": 0.0428
      }
    }
  }
  ''';

  const samplePartialNutritionJson = '''
  {
    "code": "8901030000000",
    "status": 1,
    "status_verbose": "product found",
    "product": {
      "product_name": "Organic Green Tea",
      "brands": "Nature Herb",
      "nutriments": {
        "energy-kcal_100g": 2,
        "carbohydrates_100g": 0.2
      }
    }
  }
  ''';

  const sampleUnknownJson = '''
  {
    "code": "0000000000000",
    "status": 0,
    "status_verbose": "product not found"
  }
  ''';

  final testProduct = ScannedFoodProduct.fromOpenFoodFactsJson(
    '3017620422003',
    json.decode(sampleNutellaJson) as Map<String, dynamic>,
  );

  group('OpenFoodFactsNutritionService Unit Tests', () {
    test(
      'Parses full product response correctly into ScannedFoodProduct',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, contains('3017620422003.json'));
          expect(
            request.headers['User-Agent'],
            contains('NuroVed-PatientApp/1.0.0'),
          );
          return http.Response(sampleNutellaJson, 200);
        });

        final service = OpenFoodFactsNutritionService(client: mockClient);
        final result = await service.lookupBarcode('3017620422003');

        expect(result.isSuccess, isTrue);
        final product = result.dataOrNull!;
        expect(product.barcode, '3017620422003');
        expect(product.name, 'Nutella Hazelnut Spread');
        expect(product.brand, 'Ferrero');
        expect(product.energyKcal, 539.0);
        expect(product.energyKj, 2252.0);
        expect(product.carbohydrates, 57.5);
        expect(product.sugars, 56.3);
        expect(product.proteins, 6.3);
        expect(product.fat, 30.9);
        expect(product.saturatedFat, 10.6);
        expect(product.fiber, 0.0);
        expect(product.salt, 0.107);
        expect(product.sodium, 0.0428);
        expect(product.hasNutritionData, isTrue);
        expect(product.dataSource, 'Open Food Facts');
        expect(product.attribution, contains('Open Database License (ODbL)'));
      },
    );

    test(
      'Parses partial nutrition facts without fabricating missing fields',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(samplePartialNutritionJson, 200);
        });

        final service = OpenFoodFactsNutritionService(client: mockClient);
        final result = await service.lookupBarcode('8901030000000');

        expect(result.isSuccess, isTrue);
        final product = result.dataOrNull!;
        expect(product.name, 'Organic Green Tea');
        expect(product.brand, 'Nature Herb');
        expect(product.energyKcal, 2.0);
        expect(product.carbohydrates, 0.2);
        expect(product.proteins, isNull);
        expect(product.fat, isNull);
        expect(product.saturatedFat, isNull);
        expect(product.fiber, isNull);
        expect(product.salt, isNull);
        expect(product.sodium, isNull);
      },
    );

    test('Returns NotFoundFailure for unknown barcode', () async {
      final mockClient = MockClient((request) async {
        return http.Response(sampleUnknownJson, 200);
      });

      final service = OpenFoodFactsNutritionService(client: mockClient);
      final result = await service.lookupBarcode('0000000000000');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('Handles 429 rate limit as ServerFailure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429);
      });

      final service = OpenFoodFactsNutritionService(client: mockClient);
      final result = await service.lookupBarcode('3017620422003');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'RATE_LIMIT');
    });

    test('Handles 500 server error as ServerFailure', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = OpenFoodFactsNutritionService(client: mockClient);
      final result = await service.lookupBarcode('3017620422003');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });

  group('FoodScannerScreen Widget & Integration Tests', () {
    testWidgets('Header renders with Back button and Manual Entry action', (
      tester,
    ) async {
      final fakeService = FakeNutritionService();

      await tester.pumpWidget(
        MaterialApp(home: FoodScannerScreen(nutritionService: fakeService)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food Scanner'), findsOneWidget);
      expect(find.text('Scan Retail Food Barcode'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Enter Barcode Manually'), findsOneWidget);
    });

    testWidgets('Manual barcode entry bottom sheet validates barcode length', (
      tester,
    ) async {
      final fakeService = FakeNutritionService();

      await tester.pumpWidget(
        MaterialApp(home: FoodScannerScreen(nutritionService: fakeService)),
      );
      await tester.pumpAndSettle();

      // Tap manual entry action in header
      await tester.tap(find.byTooltip('Enter Barcode Manually'));
      await tester.pumpAndSettle();

      expect(find.text('Enter Barcode Manually'), findsOneWidget);
      expect(find.text('Look Up Product'), findsOneWidget);

      // Submit empty
      await tester.tap(find.text('Look Up Product'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a barcode number.'), findsOneWidget);

      // Submit too short
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Look Up Product'));
      await tester.pumpAndSettle();
      expect(
        find.text('Barcode must contain at least 8 digits (EAN-8).'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Manual barcode entry performs successful lookup and navigates to Result Screen',
      (tester) async {
        final fakeService = FakeNutritionService(
          initialProducts: [testProduct],
        );

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name == AppRouter.scannedProductResult) {
                final product = settings.arguments as ScannedFoodProduct;
                return MaterialPageRoute(
                  builder: (_) => ScannedProductResultScreen(product: product),
                );
              }
              return MaterialPageRoute(
                builder: (_) =>
                    FoodScannerScreen(nutritionService: fakeService),
              );
            },
            home: FoodScannerScreen(nutritionService: fakeService),
          ),
        );
        await tester.pumpAndSettle();

        // Open manual entry sheet
        await tester.tap(find.byTooltip('Enter Barcode Manually'));
        await tester.pumpAndSettle();

        // Enter valid barcode
        await tester.enterText(find.byType(TextField), '3017620422003');
        await tester.tap(find.text('Look Up Product'));
        await tester.pumpAndSettle();

        // Verify navigation to ScannedProductResultScreen
        expect(find.byType(ScannedProductResultScreen), findsOneWidget);
        expect(find.text('Nutella Hazelnut Spread'), findsOneWidget);
        expect(find.text('Ferrero'), findsOneWidget);
        expect(find.text('539 kcal'), findsOneWidget);
        expect(find.text('57.5 g'), findsOneWidget); // Carbs
        expect(
          find.text('0.11 g'),
          findsOneWidget,
        ); // Salt formatted to 2 decimals
      },
    );

    testWidgets('Unknown product shows error dialog with Scan Again action', (
      tester,
    ) async {
      final fakeService = FakeNutritionService(); // empty products

      await tester.pumpWidget(
        MaterialApp(home: FoodScannerScreen(nutritionService: fakeService)),
      );
      await tester.pumpAndSettle();

      // Open manual entry sheet and submit unknown barcode
      await tester.tap(find.byTooltip('Enter Barcode Manually'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '9999999999999');
      await tester.tap(find.text('Look Up Product'));
      await tester.pumpAndSettle();

      // Dialog shown
      expect(find.text('Product Lookup'), findsOneWidget);
      expect(find.text('Scan Again'), findsOneWidget);
      expect(find.text('Enter Manually'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Scan Again'));
      await tester.pumpAndSettle();
      expect(find.text('Product Lookup'), findsNothing);
    });
  });

  group('ScannedProductResultScreen Widget Tests', () {
    testWidgets('Renders all verified nutrients, attribution, and actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: ScannedProductResultScreen(product: testProduct)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verified Nutrition Facts'), findsOneWidget);
      expect(find.text('Nutella Hazelnut Spread'), findsOneWidget);
      expect(find.text('Ferrero'), findsOneWidget);
      expect(find.text('3017620422003'), findsOneWidget);

      // Nutrients
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('539 kcal'), findsOneWidget);
      expect(find.text('Carbohydrates'), findsOneWidget);
      expect(find.text('Proteins'), findsOneWidget);
      expect(find.text('Total Fat'), findsOneWidget);
      expect(find.text('Salt'), findsOneWidget);
      expect(find.text('Sodium'), findsOneWidget);

      // Attribution
      expect(find.text('Source & Attribution'), findsOneWidget);
      expect(find.text(testProduct.attribution), findsOneWidget);

      // Actions
      expect(find.text('Scan Another Item'), findsOneWidget);
      expect(find.text('Back to Diet Overview'), findsOneWidget);
    });

    testWidgets('Unreported nutrients render with dash without crashing', (
      tester,
    ) async {
      const partialProduct = ScannedFoodProduct(
        barcode: '12345678',
        name: 'Simple Oats',
        brand: 'Organic Farm',
        carbohydrates: 20.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ScannedProductResultScreen(product: partialProduct),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Simple Oats'), findsOneWidget);
      expect(find.text('Organic Farm'), findsOneWidget);
      expect(find.text('20.0 g'), findsOneWidget);

      // Missing nutrients show dash '—'
      expect(find.text('—'), findsWidgets);
    });
  });

  group('FoodScannerScreen Lifecycle & Loading Cleanup Tests (Task 11A)', () {
    Widget buildTestApp(FakeNutritionService fakeService, {Widget? home}) {
      return MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == AppRouter.scannedProductResult) {
            final product = settings.arguments as ScannedFoodProduct;
            return MaterialPageRoute(
              builder: (_) => ScannedProductResultScreen(product: product),
            );
          }
          return MaterialPageRoute(
            builder: (_) => FoodScannerScreen(nutritionService: fakeService),
          );
        },
        home: home ?? FoodScannerScreen(nutritionService: fakeService),
      );
    }

    testWidgets(
      '1. Successful lookup dismisses loading dialog and opens ScannedProductResultScreen',
      (tester) async {
        final fakeService = FakeNutritionService(initialProducts: [testProduct])
          ..delay = const Duration(milliseconds: 150);

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('3017620422003');
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Looking up product...'), findsOneWidget);
        expect(state.isLoadingDialogVisible, isTrue);
        expect(state.isProcessing, isTrue);

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();

        expect(find.text('Looking up product...'), findsNothing);
        expect(state.isLoadingDialogVisible, isFalse);

        expect(find.byType(ScannedProductResultScreen), findsOneWidget);
        expect(find.text('Nutella Hazelnut Spread'), findsOneWidget);

        // Pop result screen and verify isProcessing is restored to false
        Navigator.pop(tester.element(find.byType(ScannedProductResultScreen)));
        await tester.pumpAndSettle();
        expect(state.isProcessing, isFalse);
      },
    );

    testWidgets(
      '2. Product not found dismisses loading dialog and shows error state',
      (tester) async {
        final fakeService = FakeNutritionService()
          ..delay = const Duration(milliseconds: 150);

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('9999999999999');
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Looking up product...'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();

        expect(find.text('Looking up product...'), findsNothing);
        expect(state.isLoadingDialogVisible, isFalse);

        expect(find.text('Product Lookup'), findsOneWidget);
        expect(find.textContaining('was not found'), findsOneWidget);
        expect(find.text('Scan Again'), findsOneWidget);

        await tester.tap(find.text('Scan Again'));
        await tester.pumpAndSettle();
        expect(state.isProcessing, isFalse);
      },
    );

    testWidgets(
      '3. Timeout or network failure dismisses loading dialog and displays error',
      (tester) async {
        final fakeService = FakeNutritionService()
          ..simulateTimeout = true
          ..delay = const Duration(milliseconds: 100);

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('12345678');
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Looking up product...'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Looking up product...'), findsNothing);
        expect(find.text('Product Lookup'), findsOneWidget);
        expect(find.textContaining('timed out'), findsOneWidget);

        await tester.tap(find.text('Scan Again'));
        await tester.pumpAndSettle();
        expect(state.isProcessing, isFalse);

        fakeService.reset();
        fakeService.simulateNetworkError = true;
        fakeService.delay = const Duration(milliseconds: 100);

        state.handleBarcode('12345678');
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Looking up product...'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Looking up product...'), findsNothing);
        expect(find.text('Product Lookup'), findsOneWidget);
        expect(find.textContaining('internet connection'), findsOneWidget);

        await tester.tap(find.text('Scan Again'));
        await tester.pumpAndSettle();
        expect(state.isProcessing, isFalse);
      },
    );

    testWidgets(
      '4. Unexpected service exception does not leave loading active or dialog stranded',
      (tester) async {
        final fakeService = FakeNutritionService()
          ..simulateException = true
          ..delay = const Duration(milliseconds: 100);

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('12345678');
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Looking up product...'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Looking up product...'), findsNothing);
        expect(state.isLoadingDialogVisible, isFalse);

        expect(find.text('Product Lookup'), findsOneWidget);
        expect(
          find.textContaining('unexpected service failure'),
          findsOneWidget,
        );

        await tester.tap(find.text('Scan Again'));
        await tester.pumpAndSettle();

        expect(state.isProcessing, isFalse);
      },
    );

    testWidgets(
      '5. Repeated barcode events do not trigger concurrent lookups',
      (tester) async {
        final fakeService = FakeNutritionService(initialProducts: [testProduct])
          ..delay = const Duration(milliseconds: 200);

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('3017620422003');
        state.handleBarcode('3017620422003');
        state.handleBarcode('8901030000000');
        state.handleBarcode('12345678');

        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        expect(fakeService.lookupCallCount, 1);
        expect(find.byType(ScannedProductResultScreen), findsOneWidget);

        Navigator.pop(tester.element(find.byType(ScannedProductResultScreen)));
        await tester.pumpAndSettle();
        expect(state.isProcessing, isFalse);
      },
    );

    testWidgets(
      '6. After error is dismissed, scanning can resume immediately',
      (tester) async {
        final fakeService = FakeNutritionService();

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('00000000');
        await tester.pumpAndSettle();

        expect(find.text('Product Lookup'), findsOneWidget);

        await tester.tap(find.text('Scan Again'));
        await tester.pumpAndSettle();

        expect(state.isProcessing, isFalse);

        fakeService.addProduct(testProduct);
        state.handleBarcode('3017620422003');
        await tester.pumpAndSettle();

        expect(find.byType(ScannedProductResultScreen), findsOneWidget);
        expect(find.text('Nutella Hazelnut Spread'), findsOneWidget);

        Navigator.pop(tester.element(find.byType(ScannedProductResultScreen)));
        await tester.pumpAndSettle();
        expect(state.isProcessing, isFalse);
      },
    );

    testWidgets(
      '7. Disposing during lookup safely cleans up dialog without unsafe context calls',
      (tester) async {
        final fakeService = FakeNutritionService()
          ..delay = const Duration(milliseconds: 300);

        await tester.pumpWidget(buildTestApp(fakeService));
        await tester.pumpAndSettle();

        final state = tester.state<FoodScannerScreenState>(
          find.byType(FoodScannerScreen),
        );

        state.handleBarcode('12345678');
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Looking up product...'), findsOneWidget);

        // Replace widget tree, forcing FoodScannerScreen to be disposed while lookup is in flight
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Center(child: Text('Other Screen'))),
          ),
        );

        // Advance time to allow pending async lookup to finish
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(find.text('Other Screen'), findsOneWidget);
        expect(find.text('Looking up product...'), findsNothing);
      },
    );

    testWidgets('8. Manual barcode lookup follows the same cleanup lifecycle', (
      tester,
    ) async {
      final fakeService = FakeNutritionService()
        ..delay = const Duration(milliseconds: 150);

      await tester.pumpWidget(buildTestApp(fakeService));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Enter Barcode Manually'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '8888888888888');
      await tester.tap(find.text('Look Up Product'));

      // One frame to start sheet dismissal and display loading dialog
      await tester.pump();
      expect(find.text('Looking up product...'), findsOneWidget);

      // Complete sheet exit animation and service lookup
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Enter Barcode Manually'), findsNothing);
      expect(find.text('Looking up product...'), findsNothing);
      expect(find.text('Product Lookup'), findsOneWidget);

      await tester.tap(find.text('Scan Again'));
      await tester.pumpAndSettle();

      final state = tester.state<FoodScannerScreenState>(
        find.byType(FoodScannerScreen),
      );
      expect(state.isProcessing, isFalse);
    });
  });
}
