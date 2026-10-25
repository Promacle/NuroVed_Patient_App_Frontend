import '../errors/failures.dart';
import '../models/scanned_food_product.dart';
import '../utils/result.dart';
import 'nutrition_service.dart';

/// In-memory mock implementation of [NutritionService] for deterministic unit and widget testing.
class FakeNutritionService implements NutritionService {
  final Map<String, ScannedFoodProduct> _products = {};

  bool simulateTimeout = false;
  bool simulateNetworkError = false;
  bool simulateRateLimit = false;
  bool simulateServerError = false;
  bool simulateException = false;
  int lookupCallCount = 0;
  Duration delay = Duration.zero;

  FakeNutritionService({List<ScannedFoodProduct>? initialProducts}) {
    if (initialProducts != null) {
      for (final p in initialProducts) {
        _products[p.barcode] = p;
      }
    }
  }

  void addProduct(ScannedFoodProduct product) {
    _products[product.barcode] = product;
  }

  void clearProducts() {
    _products.clear();
  }

  void reset() {
    simulateTimeout = false;
    simulateNetworkError = false;
    simulateRateLimit = false;
    simulateServerError = false;
    simulateException = false;
    lookupCallCount = 0;
    delay = Duration.zero;
  }

  @override
  Future<Result<ScannedFoodProduct>> lookupBarcode(String barcode) async {
    lookupCallCount++;

    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (simulateException) {
      throw Exception('Simulated unexpected service failure');
    }

    final sanitizedBarcode = barcode.trim();
    if (sanitizedBarcode.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Barcode cannot be empty.'),
      );
    }

    if (simulateTimeout) {
      return const Result.failure(
        NetworkFailure(
          message:
              'Nutrition database lookup timed out. Please check your network connection and retry.',
        ),
      );
    }

    if (simulateNetworkError) {
      return const Result.failure(
        NetworkFailure(
          message:
              'Unable to reach Open Food Facts. Please verify your internet connection.',
        ),
      );
    }

    if (simulateRateLimit) {
      return const Result.failure(
        ServerFailure(
          message:
              'Open Food Facts rate limit reached. Please wait a moment and try again.',
          code: 'RATE_LIMIT',
        ),
      );
    }

    if (simulateServerError) {
      return const Result.failure(
        ServerFailure(
          message:
              'Open Food Facts servers are currently experiencing issues. Please try again later.',
        ),
      );
    }

    final product = _products[sanitizedBarcode];
    if (product != null) {
      return Result.success(product);
    }

    return Result.failure(
      NotFoundFailure(
        message:
            'Product with barcode "$sanitizedBarcode" was not found in Open Food Facts database.',
      ),
    );
  }
}
