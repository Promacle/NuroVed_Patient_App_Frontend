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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isConstrained =
            constraints.maxHeight.isFinite && constraints.maxHeight < 280;
        final bool showImage =
            !constraints.maxHeight.isFinite || constraints.maxHeight >= 220;
        final double topPadding = isConstrained ? 0 : 50;
        final double bottomPadding = isConstrained ? 0 : 8;
        final double textHeight = isConstrained
            ? (showImage ? 60.0 : constraints.maxHeight.clamp(40.0, 96.0))
            : 96.0;

        Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: textHeight,
              child: PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            titles[index],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading1,
                          ),
                        ),
                        if (subTitles != null &&
                            index < subTitles!.length &&
                            subTitles![index].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              subTitles![index],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            if (showImage) ...[
              const SizedBox(height: 10),
              Flexible(
                child: Image.asset(
                  imageAsset,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        );

        return Container(
          width: double.infinity,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          decoration: const BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
          ),
          child: isConstrained
              ? SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: content,
                )
              : content,
        );
      },
    );
  }
}
