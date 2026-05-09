import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/widgets/diet_planner_widgets.dart';

class FoodScannerHistoryScreen extends StatelessWidget {
  const FoodScannerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          const DietPlannerHeader(
            title: "Food Scanner",
            subtitle: "Scan Barcode To Analyse Packaged Food",
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFC7E2D9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHistoryCard(
                      name: "Lay's Sour Cream & Onion",
                      status: "INTAKED",
                      statusColor: const Color(0xFF397D71),
                      calories: "160 kcal",
                      fat: "10 g",
                      sodium: "170 mg",
                      sugar: "1 g",
                    ),
                    const SizedBox(height: 15),
                    _buildHistoryCard(
                      name: "CocaCola Soft Drink",
                      status: "IGNORED",
                      statusColor: const Color(0xFF5A6A6A),
                      calories: "320 kcal",
                      fat: "45 g",
                      sodium: "320 mg",
                      sugar: "70 g",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String name,
    required String status,
    required Color statusColor,
    required String calories,
    required String fat,
    required String sodium,
    required String sugar,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ),
              const Text(
                " . ",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNutritionInfo("Calories", calories),
              _buildNutritionInfo("Total Fat", fat),
              _buildNutritionInfo("Sodium", sodium),
              _buildNutritionInfo("Sugar", sugar),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF5A6A6A),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C4E4E),
          ),
        ),
      ],
    );
  }
}
