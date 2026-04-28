import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

class RoutineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onTap;

  const RoutineTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFD1E2D2) : AppColors.navyGreen,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.restaurant_outlined,
              color: const Color(0xFF2C4E4E),
              size: 32,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Text(
                "Done",
                style: TextStyle(
                  color: Color(0xFF2C4E4E),
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2C4E4E)),
          ],
        ),
      ),
    );
  }
}
