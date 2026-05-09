import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Brand Serif Font (for NuroVed)
  static const TextStyle brandLogo = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.bold,
    fontFamily: 'serif',
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF3B4D61),
  );

  static const TextStyle bodyGrey = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textGrey,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 13,
    decoration: TextDecoration.underline,
    color: AppColors.primaryTeal,
    fontWeight: FontWeight.bold,
  );
}
