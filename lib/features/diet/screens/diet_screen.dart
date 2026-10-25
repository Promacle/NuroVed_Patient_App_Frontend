import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.kMainBg,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildDisclaimerBanner(),
                    const SizedBox(height: 16),
                    _buildActivityCard(),
                    const SizedBox(height: 24),
                    _buildQuickActionCard(context),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D7B8)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: Color(0xFFB57D24),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Diet suggestions are for nutritional tracking only and do not constitute medical diagnosis or treatment.",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF7A571A),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.only(
        top: max(topPadding, 20.0) + 12,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE8F2EF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Back',
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC7E2D9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2C4E4E),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  "Diet Section",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 59),
            child: Text(
              "Calculate Your Every Single Bite",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5A6A6A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navyGreen.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 15),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 12, color: Colors.white),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Sample preview metrics - not clinical measurements",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const IgnorePointer(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(painter: ConcentricRingsPainter()),
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "350/1000 kCAL",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    Text(
                      "1/3 MEALS",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6ED940),
                      ),
                    ),
                    Text(
                      "4/8 HRS",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF56BFDB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildChartSection(
            "kcal intake",
            [2, 3, 5, 8, 12, 10, 8, 9, 6, 7, 10, 13, 11, 10, 9, 7, 5, 4, 3],
            const LinearGradient(
              colors: [Color(0xFF059597), Color(0xFF004445)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          const SizedBox(height: 15),
          _buildChartSection(
            "Meals",
            [1, 2, 4, 6, 10, 8, 7, 9, 11, 12, 11, 9, 7, 6, 4, 3, 2, 1, 0.5],
            const LinearGradient(
              colors: [Color(0xFF6ED940), Color(0xFFA5FF7E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          const SizedBox(height: 15),
          _buildChartSection(
            "Sleep",
            [0, 0, 0, 0, 0, 8, 9, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 0, 0],
            const LinearGradient(
              colors: [Color(0xFF56BFDB), Color(0xFF77E2FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    String label,
    List<double> values,
    Gradient gradient,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4E4E),
          ),
        ),
        const SizedBox(height: 5),
        IgnorePointer(
          child: SizedBox(
            height: 60,
            child: CustomPaint(
              size: Size.infinite,
              painter: MiniBarChartPainter(values: values, gradient: gradient),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "Quick Action",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickActionButton(
                label: "Diet Planner",
                icon: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.sageGreen,
                  size: 34,
                ),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.aiDietPlanner),
              ),
              const SizedBox(width: 8),
              QuickActionButton(
                label: "Food Scanner",
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.sageGreen,
                  size: 34,
                ),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.foodScanner),
              ),
              const SizedBox(width: 8),
              QuickActionButton(
                label: "Meal Routine History",
                icon: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.sageGreen,
                  size: 34,
                ),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.mealRoutineHistory),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            hoverColor: const Color(0xFFC7E2D9).withValues(alpha: 0.25),
            splashColor: const Color(0xFFC7E2D9).withValues(alpha: 0.35),
            highlightColor: const Color(0xFFC7E2D9).withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: icon,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConcentricRingsPainter extends CustomPainter {
  const ConcentricRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, (size.width / 2) - 5, bgPaint);
    canvas.drawCircle(center, (size.width / 2) - 20, bgPaint);
    canvas.drawCircle(center, (size.width / 2) - 35, bgPaint);

    // Outer Ring (kCAL) - Teal
    final outerPaint = Paint()
      ..color = const Color(0xFF059597)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (size.width / 2) - 5),
      -pi / 2,
      2 * pi * 0.7,
      false,
      outerPaint,
    );

    // Middle Ring (Meals) - Lime
    final middlePaint = Paint()
      ..color = const Color(0xFF6ED940)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (size.width / 2) - 20),
      -pi / 2,
      2 * pi * 0.33,
      false,
      middlePaint,
    );

    // Inner Ring (Sleep) - Blue
    final innerPaint = Paint()
      ..color = const Color(0xFF56BFDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (size.width / 2) - 35),
      -pi / 2,
      2 * pi * 0.5,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MiniBarChartPainter extends CustomPainter {
  final List<double> values;
  final Gradient gradient;

  MiniBarChartPainter({required this.values, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Draw grid
    for (var i = 0; i <= 4; i++) {
      double x = size.width * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height - 15), axisPaint);
    }

    // Draw dotted baseline
    double dashWidth = 3, dashSpace = 3, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height - 15),
        Offset(startX + dashWidth, size.height - 15),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Labels
    const textStyle = TextStyle(color: Colors.grey, fontSize: 8);
    _drawText(canvas, "12AM", Offset(5, size.height - 12), textStyle);
    _drawText(
      canvas,
      "6AM",
      Offset(size.width * 0.25 + 5, size.height - 12),
      textStyle,
    );
    _drawText(
      canvas,
      "12PM",
      Offset(size.width * 0.5 + 5, size.height - 12),
      textStyle,
    );
    _drawText(
      canvas,
      "6PM",
      Offset(size.width * 0.75 + 5, size.height - 12),
      textStyle,
    );

    // Bars
    if (values.isEmpty) return;
    final barWidth = (size.width / values.length) * 0.6;
    final spacing = (size.width / values.length) * 0.4;
    final maxValue = values.reduce(max);

    for (int i = 0; i < values.length; i++) {
      final barHeight = (values[i] / maxValue) * (size.height - 25);
      if (barHeight == 0) continue;

      final x = i * (barWidth + spacing) + spacing / 2;
      final rect = Rect.fromLTWH(
        x,
        size.height - 15 - barHeight,
        barWidth,
        barHeight,
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
