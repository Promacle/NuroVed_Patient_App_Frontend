import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/widgets/feature_unavailable_card.dart';
import 'package:nuroved_patient/features/home/controllers/home_controller.dart';

class FoodScannerScreen extends StatelessWidget {
  const FoodScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: FeatureUnavailableCard(
                icon: Icons.qr_code_scanner_rounded,
                title: "Food Scanner Unavailable",
                explanation:
                    "Barcode nutritional scanning is currently unavailable in the MVP.\n\nIn accordance with NuroVed clinical honesty principles, simulated or unverified nutritional data has been disabled until verified clinical database integration is complete.",
                safetyRationale:
                    "Safety First — No Mock Nutritional Claims\nBarcode scanning is disabled until verified clinical database integration is completed to protect diabetic health.",
                primaryButtonLabel: "Return to Home",
                onPrimaryPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    HomeController().setTab(0);
                  }
                },
                secondaryButtonLabel: "Browse Diet Overview",
                onSecondaryPressed: () =>
                    Navigator.pushNamed(context, AppRouter.diet),
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
      padding: const EdgeInsets.only(top: 16, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (Navigator.canPop(context))
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Food Scanner",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Barcode Nutritional Analysis",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
