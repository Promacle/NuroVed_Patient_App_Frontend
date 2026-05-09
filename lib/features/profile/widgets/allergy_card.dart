import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

class AllergyCard extends StatelessWidget {
  final List<String> allergies;

  const AllergyCard({super.key, required this.allergies});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_outline_rounded,
                color: AppColors.errorRed,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                "Known Allergies",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergies
                .map(
                  (allergy) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E6DF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      allergy,
                      style: const TextStyle(
                        color: Color(0xFF5A8E82),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
