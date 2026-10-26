import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/models/scanned_food_product.dart';
import '../../../core/theme/app_colors.dart';

/// Screen displaying verified nutritional values retrieved from Open Food Facts.
class ScannedProductResultScreen extends StatelessWidget {
  final ScannedFoodProduct product;

  const ScannedProductResultScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProductCard(context),
                    const SizedBox(height: 16),
                    _buildNutritionCard(context),
                    const SizedBox(height: 16),
                    _buildAttributionCard(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: context.l10n.commonBack,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.foodScannerVerifiedFacts,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.foodScannerNutritionDataSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primaryTeal,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? context.l10n.foodScannerProductNameNotSpecified,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand ?? context.l10n.foodScannerBrandNotSpecified,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 18,
                color: AppColors.textGrey,
              ),
              const SizedBox(width: 6),
              Text(
                product.barcode,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  product.servingSize != null
                      ? context.l10n.foodScannerServingPrefix(product.servingSize!)
                      : context.l10n.foodScannerBasisPrefix(product.servingBasis),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.foodScannerNutritionFacts,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.servingBasis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNutrientRow(
            label: context.l10n.foodScannerCalories,
            value: product.energyKcal != null
                ? "${product.energyKcal!.toStringAsFixed(product.energyKcal! % 1 == 0 ? 0 : 1)} kcal"
                : (product.energyKj != null
                      ? "${product.energyKj!.toStringAsFixed(0)} kJ"
                      : null),
            icon: Icons.local_fire_department_rounded,
            highlight: true,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerCarbs,
            value: product.carbohydrates != null
                ? "${product.carbohydrates!.toStringAsFixed(1)} g"
                : null,
            icon: Icons.grain_rounded,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerSugars,
            value: product.sugars != null
                ? "${product.sugars!.toStringAsFixed(1)} g"
                : null,
            isIndented: true,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerProteins,
            value: product.proteins != null
                ? "${product.proteins!.toStringAsFixed(1)} g"
                : null,
            icon: Icons.fitness_center_rounded,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerTotalFat,
            value: product.fat != null
                ? "${product.fat!.toStringAsFixed(1)} g"
                : null,
            icon: Icons.opacity_rounded,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerSaturates,
            value: product.saturatedFat != null
                ? "${product.saturatedFat!.toStringAsFixed(1)} g"
                : null,
            isIndented: true,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerFiber,
            value: product.fiber != null
                ? "${product.fiber!.toStringAsFixed(1)} g"
                : null,
            icon: Icons.spa_rounded,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerSalt,
            value: product.salt != null
                ? "${product.salt!.toStringAsFixed(2)} g"
                : null,
            icon: Icons.shutter_speed_rounded,
          ),
          _buildNutrientRow(
            label: context.l10n.foodScannerSodium,
            value: product.sodium != null
                ? "${product.sodium!.toStringAsFixed(3)} g"
                : null,
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.foodScannerUnreportedNotice,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow({
    required String label,
    required String? value,
    IconData? icon,
    bool highlight = false,
    bool isIndented = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: highlight
                  ? AppColors.primaryTeal
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
          ] else if (isIndented) ...[
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: isIndented
                    ? AppColors.textGrey
                    : const Color(0xFF2C4E4E),
              ),
            ),
          ),
          Text(
            value ?? "—",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: value != null
                  ? (highlight ? AppColors.primaryTeal : AppColors.textPrimary)
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 18,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.foodScannerSourceAttribution,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.attribution,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.foodScannerMedicalDisclaimer,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: Text(
              context.l10n.foodScannerScanAnother,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryTeal,
              side: const BorderSide(color: AppColors.primaryTeal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Text(
              context.l10n.foodScannerBackToDiet,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
