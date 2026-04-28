import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final List<String> titles;
  final List<String>? subTitles;
  final String imageAsset;
  final PageController? controller; // To sync the sliding text

  const AuthHeader({
    super.key,
    required this.titles,
    this.subTitles,
    required this.imageAsset,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 0),
      decoration: const BoxDecoration(
        color: AppColors.lightGrey, // Using your specific theme color
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: Column(
        children: [
          // This PageView only slides the Text, NOT the whole header/dog
          SizedBox(
            height: 75,
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: titles.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text(
                      titles[index],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1,
                    ),
                    if (subTitles != null && subTitles![index].isNotEmpty)
                      Text(
                        subTitles![index],
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Image.asset(imageAsset, height: 160, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
