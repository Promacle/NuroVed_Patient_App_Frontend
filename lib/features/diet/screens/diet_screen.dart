import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/home/screens/main_layout.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildActivityCard(),
                  const SizedBox(height: 30),
                  _buildQuickActionCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7E2D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "Diet Section",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 45),
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
        color: AppColors.navyGreen.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 15),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(painter: ConcentricRingsPainter()),
              ),
              const SizedBox(width: 25),
              const Column(
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
        SizedBox(
          height: 60,
          child: CustomPaint(
            size: Size.infinite,
            painter: MiniBarChartPainter(values: values, gradient: gradient),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Action",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickActionButton(
                label: "Diet Planner",
                icon: FontAwesomeIcons.appleWhole,
                onTap: () => Navigator.pushNamed(context, '/ai-diet-planner'),
              ),
              QuickActionButton(
                label: "Food Scanner",
                icon: Icons.qr_code_scanner,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainLayout(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
              ),
              QuickActionButton(
                label: "Meal Routine History",
                icon: Icons.timer_outlined,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/meal-routine-history',
                ), // Add this
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(widget.icon, color: AppColors.sageGreen, size: 35),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ],
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
      ..color = Colors.white.withOpacity(0.5)
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
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
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
