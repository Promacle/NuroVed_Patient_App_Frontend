/// Model representing verified product and nutritional facts retrieved from
/// a nutrition database (e.g., Open Food Facts).
class ScannedFoodProduct {
  final String barcode;
  final String? name;
  final String? brand;
  final String? imageUrl;
  final String? servingSize;
  final String servingBasis;
  final double? energyKcal;
  final double? energyKj;
  final double? proteins;
  final double? carbohydrates;
  final double? sugars;
  final double? fat;
  final double? saturatedFat;
  final double? fiber;
  final double? sodium;
  final double? salt;
  final String dataSource;
  final String attribution;

  const ScannedFoodProduct({
    required this.barcode,
    this.name,
    this.brand,
    this.imageUrl,
    this.servingSize,
    this.servingBasis = 'per 100g',
    this.energyKcal,
    this.energyKj,
    this.proteins,
    this.carbohydrates,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.fiber,
    this.sodium,
    this.salt,
    this.dataSource = 'Open Food Facts',
    this.attribution =
        'Data from Open Food Facts (openfoodfacts.org), available under the Open Database License (ODbL).',
  });

  /// Returns `true` if at least one verified nutritional fact was returned.
  bool get hasNutritionData =>
      energyKcal != null ||
      energyKj != null ||
      proteins != null ||
      carbohydrates != null ||
      sugars != null ||
      fat != null ||
      saturatedFat != null ||
      fiber != null ||
      sodium != null ||
      salt != null;

  /// Safe parser from Open Food Facts v2 API response JSON
  factory ScannedFoodProduct.fromOpenFoodFactsJson(
    String barcode,
    Map<String, dynamic> json,
  ) {
    final product = (json['product'] as Map<String, dynamic>?) ?? {};
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};

    double? parseNutrient(List<String> keys) {
      for (final key in keys) {
        final val = nutriments[key];
        if (val != null) {
          if (val is num) return val.toDouble();
          if (val is String) {
            final parsed = double.tryParse(val);
            if (parsed != null) return parsed;
          }
        }
      }
      return null;
    }

    final String? productName = product['product_name'] as String?;
    final String? brands = product['brands'] as String?;
    final String? imageUrl = product['image_url'] as String?;
    final String? servingSize = product['serving_size'] as String?;

    return ScannedFoodProduct(
      barcode: barcode,
      name: (productName != null && productName.trim().isNotEmpty)
          ? productName.trim()
          : null,
      brand: (brands != null && brands.trim().isNotEmpty)
          ? brands.trim()
          : null,
      imageUrl: (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl.trim()
          : null,
      servingSize: (servingSize != null && servingSize.trim().isNotEmpty)
          ? servingSize.trim()
          : null,
      servingBasis: 'per 100g',
      energyKcal: parseNutrient([
        'energy-kcal_100g',
        'energy-kcal_value',
        'energy-kcal',
      ]),
      energyKj: parseNutrient([
        'energy-kj_100g',
        'energy-kj_value',
        'energy-kj',
        'energy_100g',
      ]),
      proteins: parseNutrient(['proteins_100g', 'proteins_value', 'proteins']),
      carbohydrates: parseNutrient([
        'carbohydrates_100g',
        'carbohydrates_value',
        'carbohydrates',
      ]),
      sugars: parseNutrient(['sugars_100g', 'sugars_value', 'sugars']),
      fat: parseNutrient(['fat_100g', 'fat_value', 'fat']),
      saturatedFat: parseNutrient([
        'saturated-fat_100g',
        'saturated-fat_value',
        'saturated-fat',
      ]),
      fiber: parseNutrient(['fiber_100g', 'fiber_value', 'fiber']),
      sodium: parseNutrient(['sodium_100g', 'sodium_value', 'sodium']),
      salt: parseNutrient(['salt_100g', 'salt_value', 'salt']),
      dataSource: 'Open Food Facts',
      attribution:
          'Data from Open Food Facts (openfoodfacts.org), available under the Open Database License (ODbL).',
    );
  }

  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'name': name,
    'brand': brand,
    'imageUrl': imageUrl,
    'servingSize': servingSize,
    'servingBasis': servingBasis,
    'energyKcal': energyKcal,
    'energyKj': energyKj,
    'proteins': proteins,
    'carbohydrates': carbohydrates,
    'sugars': sugars,
    'fat': fat,
    'saturatedFat': saturatedFat,
    'fiber': fiber,
    'sodium': sodium,
    'salt': salt,
    'dataSource': dataSource,
    'attribution': attribution,
  };
}
