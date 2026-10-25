import '../models/scanned_food_product.dart';
import '../utils/result.dart';

/// Abstract service contract for looking up verified nutritional facts
/// from a product barcode database.
abstract class NutritionService {
  /// Looks up a product by its barcode string (e.g. EAN-13, EAN-8, UPC-A).
  ///
  /// Returns [Result.success] with a [ScannedFoodProduct] if found,
  /// or [Result.failure] with an appropriate [Failure] (NotFoundFailure, NetworkFailure, etc.).
  Future<Result<ScannedFoodProduct>> lookupBarcode(String barcode);
}
