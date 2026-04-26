import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/widgets/profile_selector.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/routine_detail_screen.dart';
import 'package:nuroved_patient/features/routine/widgets/routine_tile.dart';

import '../../settings/controllers/app_settings_controller.dart';
import '../widgets/medicine_tile.dart';
import 'add_medicine_screen.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final RoutineController _controller = RoutineController();
  final ProfileController _profileController = ProfileController();
  final AppSettingsController _settingsController = AppSettingsController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildProgressCard(
                              _controller.progress,
                              _controller.progressText,
                            ),
                            const SizedBox(height: 25),
                            _buildTabSwitcher(),
                            const SizedBox(height: 25),
                            _buildRoutineSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // lib/features/routine/screens/routine_screen.dart
          floatingActionButton: _controller.selectedTab == "Medicines"
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMedicineScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.sageGreen,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 35),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Flexible(
                      child: Text(
                        "Medicines",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ProfileSelector(
                name: _profileController.activeProfileName.split(" ")[0],
                familyNames: _profileController.familyMembers
                    .map((e) => e['name'] as String)
                    .toList(),
                onSelected: (name) {
                  setState(() => _profileController.activeProfileName = name);
                  _controller.setProfile(name);
                },
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 60),
            child: Text(
              "Never Miss What Matters",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, String progressText) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4F2),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(90, 90),
                      painter: _CircularProgressPainter(progress: progress),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF004445),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progressText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004445),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Today's progress",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Routine",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 80, width: double.infinity, child: _BarChart()),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "12AM",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text("6AM", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  "12PM",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text("6PM", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E6E4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              "Routines",
              _controller.selectedTab == "Routines",
            ),
          ),
          Expanded(
            child: _buildTabButton(
              "Medicines",
              _controller.selectedTab == "Medicines",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () => _controller.updateTab(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFF2C4E4E) : Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineSection() {
    bool isMedicineTab = _controller.selectedTab == "Medicines";

    return ListenableBuilder(
      listenable: _settingsController,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMedicineTab ? "Monday Medicines" : "Monday Meals",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.black12),
              const SizedBox(height: 20),
              if (!isMedicineTab)
                ..._controller.meals.map(
                  (m) => RoutineTile(
                    title: m['title'],
                    subtitle: _settingsController.formatTime(m['time']),
                    isCompleted: m['isCompleted'],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutineDetailScreen(
                          title: m['title'],
                          time: m['time'].split(" * ").length > 1
                              ? m['time'].split(" * ")[1]
                              : m['time'],
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(_controller.medicines.length, (index) {
                  final med = _controller.medicines[index];
                  final parts = med['instruction'].split(" * ");
                  if (parts.length >= 2) {
                    parts[1] = _settingsController.formatTime(parts[1]);
                  }
                  final formattedInstruction = parts.join(" * ");

                  return MedicineTile(
                    name: med['name'],
                    instruction: formattedInstruction,
                    isCompleted: med['isCompleted'],
                    onTap: () => _controller.toggleMedicine(index),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  _CircularProgressPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    final trackPaint = Paint()
      ..color = const Color(0xFF004445)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = const Color(0xFFF2D1D1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.5,
      progress * 6.28,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    final dashedPaint = Paint()
      ..color = const Color(0xFF004445)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 4; i++) {
      double x = (size.width / 3.1) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    double dashWidth = 4, dashSpace = 4, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height - 10),
        Offset(startX + dashWidth, size.height - 10),
        dashedPaint,
      );
      startX += dashWidth + dashSpace;
    }
    final values = [
      0.1,
      0.1,
      0.1,
      0.1,
      0.6,
      0.5,
      0.3,
      0.5,
      0.2,
      0.4,
      0.5,
      0.7,
      0.4,
      0.3,
      0.2,
      0.1,
      0.1,
      0.1,
    ];
    final barWidth = 6.0;
    final spacing =
        (size.width - (values.length * barWidth)) / (values.length - 1);
    for (int i = 0; i < values.length; i++) {
      double x = i * (barWidth + spacing) + barWidth / 2;
      double barHeight = values[i] * (size.height - 20);
      final barPaint = Paint()
        ..shader =
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF318686), Color(0xFF004445)],
            ).createShader(
              Rect.fromLTWH(
                x - barWidth / 2,
                size.height - 10 - barHeight,
                barWidth,
                barHeight,
              ),
            );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - barWidth / 2,
            size.height - 10 - barHeight,
            barWidth,
            barHeight,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BarChartPainter());
}
