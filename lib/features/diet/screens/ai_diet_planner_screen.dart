import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/widgets/feature_unavailable_card.dart';

import '../widgets/diet_planner_widgets.dart';

class AiDietPlannerScreen extends StatelessWidget {
  const AiDietPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          const DietPlannerHeader(
            title: "Ai Diet Planner",
            subtitle: "Personalized Nutritional Planning",
          ),
          Expanded(
            child: FeatureUnavailableCard(
              icon: Icons.restaurant_menu_rounded,
              title: "Meal Generation Unavailable",
              explanation:
                  "Automated meal generation is disabled in the MVP.\n\nIn accordance with NuroVed clinical guidelines, automated dietary advice requires clinical validation to guarantee patient safety. This feature will be enabled once medical safety protocols are complete.",
              safetyRationale:
                  "Safety First — Clinical Validation Required\nAutomated dietary advice requires rigorous clinical validation before generating meal recommendations for diabetic care.",
              primaryButtonLabel: "Back to Diet Overview",
              onPrimaryPressed: () => Navigator.pop(context),
              secondaryButtonLabel: "View Medicine Routines",
              onSecondaryPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRouter.routine),
            ),
          ),
        ],
      ),
    );
  }
}
