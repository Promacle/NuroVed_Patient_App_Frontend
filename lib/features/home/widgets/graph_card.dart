import 'package:flutter/material.dart';

class GraphCard extends StatefulWidget {
  const GraphCard({super.key});

  @override
  State<GraphCard> createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Health Timeline",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "Visits",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 4,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(height: 1, width: 20, color: Colors.grey.shade300),
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade200),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _DetailedChartPainter(_animation.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedChartPainter extends CustomPainter {
  final double progress;
  _DetailedChartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingX = 35.0;
    const double paddingY = 10.0;
    final double gWidth = size.width - (paddingX * 2);
    final double gHeight = size.height - (paddingY * 2);

    final linePaint = Paint()
      ..color = const Color(0xFF7CB9A8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = const Color(0xFF7CB9A8).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;
    final baseLinePaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.5;

    final List<double> values = [
      19,
      14,
      17.5,
      16,
      17.5,
      21.5,
      24.5,
      17,
      18,
      18,
      23,
      15,
    ];
    final double xStep = gWidth / (values.length - 1);

    // Grid and Labels
    for (int i = 0; i <= 5; i++) {
      double yVal = (i * 5).toDouble();
      double yPos = (paddingY + gHeight) - (yVal / 25 * gHeight);
      canvas.drawLine(
        Offset(paddingX, yPos),
        Offset(size.width - paddingX, yPos),
        gridPaint,
      );
      _drawLabel(canvas, Offset(paddingX - 25, yPos - 7), "${yVal.toInt()}");
      _drawLabel(
        canvas,
        Offset(size.width - paddingX + 8, yPos - 7),
        "${yVal.toInt()}",
      );
    }

    canvas.drawLine(
      Offset(paddingX, paddingY + gHeight),
      Offset(size.width - paddingX, paddingY + gHeight),
      baseLinePaint,
    );

    // Animated Path logic
    final path = Path();
    final fillPath = Path();
    fillPath.moveTo(paddingX, paddingY + gHeight);

    // Limit index based on animation progress
    int pointsToDraw = (values.length * progress).ceil();
    if (pointsToDraw < 1) pointsToDraw = 0;

    for (int i = 0; i < pointsToDraw; i++) {
      double x = paddingX + (i * xStep);
      double y = (paddingY + gHeight) - (values[i] / 25 * gHeight);

      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);

      fillPath.lineTo(x, y);
      _drawVerticalDashedLine(
        canvas,
        x,
        paddingY,
        paddingY + gHeight,
        gridPaint,
      );
    }

    if (pointsToDraw > 0) {
      canvas.drawPath(
        fillPath
          ..lineTo(paddingX + ((pointsToDraw - 1) * xStep), paddingY + gHeight)
          ..close(),
        fillPaint,
      );
      canvas.drawPath(path, linePaint);

      // Draw Nodes
      for (int i = 0; i < pointsToDraw; i++) {
        double x = paddingX + (i * xStep);
        double y = (paddingY + gHeight) - (values[i] / 25 * gHeight);
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
        canvas.drawCircle(
          Offset(x, y),
          4,
          linePaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  void _drawVerticalDashedLine(
    Canvas canvas,
    double x,
    double startY,
    double endY,
    Paint paint,
  ) {
    double currY = startY;
    while (currY < endY) {
      canvas.drawLine(Offset(x, currY), Offset(x, currY + 4), paint);
      currY += 8;
    }
  }

  void _drawLabel(Canvas canvas, Offset offset, String text) {
    TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _DetailedChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
