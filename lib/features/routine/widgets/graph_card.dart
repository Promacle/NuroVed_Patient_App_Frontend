import 'package:flutter/material.dart';

import '../../routine/controllers/routine_controller.dart';

class GraphCard extends StatefulWidget {
  const GraphCard({super.key});

  @override
  State<GraphCard> createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final RoutineController _routineController = RoutineController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuart,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _routineController,
      builder: (context, _) {
        // Calculate dynamic values based on medicines
        // We use mock history but the last points are driven by current medicine progress
        final meds = _routineController.medicines;
        final completedCount = meds
            .where((m) => m['isCompleted'] == true)
            .length;

        // Base mock data for the timeline
        List<double> values = [12, 14, 11, 15, 13, 16, 14, 18, 15, 19];

        // The last two points reflect current medicine completion (scaled for the graph)
        // If 3 meds are done, it goes higher.
        double currentProgressValue = 15 + (completedCount * 3.0);
        values.add(currentProgressValue - 2); // penultimate point
        values.add(currentProgressValue); // latest point

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
                    "Medicine Timeline",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  Text(
                    "${(completedCount / meds.length * 100).toInt()}% Done",
                    style: const TextStyle(
                      color: Color(0xFF7CB9A8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildProgressBar(),
              const SizedBox(height: 30),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _DetailedChartPainter(_animation.value, values),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return Row(
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
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
      ],
    );
  }
}

class _DetailedChartPainter extends CustomPainter {
  final double progress;
  final List<double> values;
  _DetailedChartPainter(this.progress, this.values);

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingX = 35.0;
    const double paddingY = 10.0;
    final double gWidth = size.width - (paddingX * 2);
    final double gHeight = size.height - (paddingY * 2);

    final linePaint = Paint()
      ..color = const Color(0xFF7CB9A8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = const Color(0xFF7CB9A8).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    final double xStep = gWidth / (values.length - 1);

    // Grid and Labels (0 to 25 scale)
    for (int i = 0; i <= 5; i++) {
      double yVal = (i * 5).toDouble();
      double yPos = (paddingY + gHeight) - (yVal / 25 * gHeight);
      canvas.drawLine(
        Offset(paddingX, yPos),
        Offset(size.width - paddingX, yPos),
        gridPaint,
      );
    }

    final path = Path();
    final fillPath = Path();
    fillPath.moveTo(paddingX, paddingY + gHeight);

    int pointsToDraw = (values.length * progress).ceil();
    for (int i = 0; i < pointsToDraw; i++) {
      double x = paddingX + (i * xStep);
      double y = (paddingY + gHeight) - (values[i] / 25 * gHeight);

      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    if (pointsToDraw > 0) {
      canvas.drawPath(
        fillPath
          ..lineTo(paddingX + ((pointsToDraw - 1) * xStep), paddingY + gHeight)
          ..close(),
        fillPaint,
      );
      canvas.drawPath(path, linePaint);

      // Draw active node for the latest point
      if (progress == 1.0) {
        double x = paddingX + ((values.length - 1) * xStep);
        double y = (paddingY + gHeight) - (values.last / 25 * gHeight);
        canvas.drawCircle(
          Offset(x, y),
          6,
          Paint()..color = const Color(0xFF004D40),
        );
        canvas.drawCircle(
          Offset(x, y),
          8,
          Paint()
            ..color = const Color(0xFF004D40).withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedChartPainter oldDelegate) => true;
}
