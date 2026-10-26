import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/widgets/profile_selector.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/routine_detail_screen.dart';
import 'package:nuroved_patient/features/routine/widgets/routine_tile.dart';

import '../../../app/app_router.dart';
import '../../settings/controllers/app_settings_controller.dart';
import '../widgets/medicine_tile.dart';

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
      listenable: Listenable.merge([_controller, _profileController]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 18.0,
                        ),
                        child: Column(
                          children: [
                            _buildProgressCard(
                              _controller.progress,
                              _controller.progressText,
                            ),
                            const SizedBox(height: 20),
                            _buildTabSwitcher(),
                            const SizedBox(height: 20),
                            _buildRoutineSection(),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          floatingActionButton: _controller.selectedTab == "Medicines"
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: FloatingActionButton(
                    heroTag: 'routine_fab',
                    tooltip: context.l10n.routineAddMedicine,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.addMedicine),
                    backgroundColor: AppColors.primaryTeal,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader() {
    // 1. Find the active member data to get the photo
    final activeMember = _profileController.familyMembers.firstWhere(
      (m) => m['name'] == _profileController.activeProfileName,
      orElse: () => _profileController.userData,
    );

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
                    Flexible(
                      child: Text(
                        context.l10n.navRoutine,
                        style: const TextStyle(
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
                imageFile: activeMember['imageFile'],
                familyNames: _profileController.familyMembers
                    .map((e) => e['name'] as String)
                    .toList(),
                onSelected: (name) {
                  setState(() {
                    _profileController.switchSubjectByName(name);
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Text(
              context.l10n.routineSubtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, String progressText) {
    final items = _controller.selectedTab == "Medicines"
        ? _controller.medicines
        : _controller.meals;
    final completed = items.where((m) => m['isCompleted'] == true).length;
    final total = items.length;

    // Base pattern for the 18 bars in your chart
    List<double> barValues = [
      0.1,
      0.1,
      0.1,
      0.1,
      0.2,
      0.3,
      0.2,
      0.4,
      0.3,
      0.5,
      0.4,
      0.6,
      0.4,
      0.3,
      0.2,
      0.1,
      0.1,
      0.1,
    ];

    // Dynamically scale the bars based on actual progress
    if (total > 0) {
      double scaleFactor = (completed / total);
      for (int i = 6; i <= 13; i++) {
        barValues[i] =
            0.2 + (scaleFactor * 0.6); // Bars grow as you complete tasks
      }
    }
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
                    Text(
                      context.l10n.routineTodaysProgress,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    if (_controller.selectedTab == "Medicines" &&
                        total > 0) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF318686,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.l10n.routineTotalMedicines(total),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF004445),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  ((total - completed) > 0
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF16A34A))
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (total - completed) > 0
                                  ? "${context.l10n.routineDueDosesSection}: ${total - completed}"
                                  : context.l10n.routineStatusTaken,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: (total - completed) > 0
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // LOGIC: Label changes based on selected tab
              _controller.selectedTab == "Medicines"
                  ? context.l10n.routineMedicineAdherence
                  : context.l10n.routineMealRoutine,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            width: double.infinity,
            child: _BarChart(values: barValues),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.routineTime12AM,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  context.l10n.routineTime6AM,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  context.l10n.routineTime12PM,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  context.l10n.routineTime6PM,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
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
              tabKey: "Routines",
              displayTitle: context.l10n.routineTabMeals,
              isActive: _controller.selectedTab == "Routines",
            ),
          ),
          Expanded(
            child: _buildTabButton(
              tabKey: "Medicines",
              displayTitle: context.l10n.routineTabMedicines,
              isActive: _controller.selectedTab == "Medicines",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String tabKey,
    required String displayTitle,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _controller.updateTab(tabKey),
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
            displayTitle,
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
    final isMedicineTab = _controller.selectedTab == "Medicines";

    return ListenableBuilder(
      listenable: _settingsController,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMedicineTab ? 14 : 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F3),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMedicineTab) ...[
                Text(
                  context.l10n.routineMondayMeals,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 20),
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
                          mealName: m['mealName']?.toString(),
                          calories: m['calories']?.toString(),
                          ingredients: m['ingredients'] is List
                              ? (m['ingredients'] as List)
                                    .map((e) => e.toString())
                                    .toList()
                              : null,
                          isCompleted: m['isCompleted'] == true,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.routineMondayMedicines,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4E4E),
                        ),
                      ),
                    ),
                    if (_controller.medicines.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF318686,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          context.l10n.routineTotalMedicines(
                            _controller.medicines.length,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF004445),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 16),
                if (_controller.medicines.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF318686,
                              ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.medication_outlined,
                              size: 32,
                              color: Color(0xFF004445),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.routineEmptyTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C4E4E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.routineEmptySubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRouter.addMedicine,
                            ),
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              context.l10n.routineAddMedicine,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._buildMedicineSections(),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMedicineSections() {
    final dueMedicines = _controller.medicines
        .where((m) => m['isCompleted'] != true)
        .toList();
    final completedMedicines = _controller.medicines
        .where((m) => m['isCompleted'] == true)
        .toList();

    return [
      _buildSectionHeader(
        title: context.l10n.routineDueDosesSection,
        count: dueMedicines.length,
        color: const Color(0xFFD97706),
        icon: Icons.access_time_rounded,
      ),
      const SizedBox(height: 12),
      if (dueMedicines.isEmpty)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF059669),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.routineNoDueDoses,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        )
      else
        ...dueMedicines.map((med) {
          final originalIndex = _findMedicineIndex(med);
          return MedicineTile(
            name: med['name']?.toString() ?? '',
            instruction: med['instruction']?.toString() ?? '',
            isCompleted: med['isCompleted'] == true,
            sourceDisplay: med['source_display']?.toString(),
            dosage: med['dosage']?.toString(),
            time: med['time']?.toString(),
            onTap: () => _controller.toggleMedicine(originalIndex),
            onDelete: () => _confirmDeleteMedicine(
              context,
              originalIndex,
              med['name']?.toString() ?? 'Medicine',
            ),
          );
        }),
      if (completedMedicines.isNotEmpty) ...[
        const SizedBox(height: 10),
        _buildSectionHeader(
          title: context.l10n.routineCompletedDosesSection,
          count: completedMedicines.length,
          color: const Color(0xFF16A34A),
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(height: 12),
        ...completedMedicines.map((med) {
          final originalIndex = _findMedicineIndex(med);
          return MedicineTile(
            name: med['name']?.toString() ?? '',
            instruction: med['instruction']?.toString() ?? '',
            isCompleted: med['isCompleted'] == true,
            sourceDisplay: med['source_display']?.toString(),
            dosage: med['dosage']?.toString(),
            time: med['time']?.toString(),
            onTap: () => _controller.toggleMedicine(originalIndex),
            onDelete: () => _confirmDeleteMedicine(
              context,
              originalIndex,
              med['name']?.toString() ?? 'Medicine',
            ),
          );
        }),
      ],
    ];
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C4E4E),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  int _findMedicineIndex(Map<String, dynamic> med) {
    final id = med['id'];
    if (id != null) {
      final idx = _controller.medicines.indexWhere((m) => m['id'] == id);
      if (idx >= 0) return idx;
    }
    final identityIdx = _controller.medicines.indexWhere(
      (m) => identical(m, med),
    );
    if (identityIdx >= 0) return identityIdx;
    return _controller.medicines.indexOf(med);
  }

  void _confirmDeleteMedicine(BuildContext context, int index, String name) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(dialogCtx.l10n.routineDeleteRoutineTitle),
        content: Text(dialogCtx.l10n.routineDeleteRoutineMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              dialogCtx.l10n.commonCancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _controller.deleteMedicine(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.routineRemovedSnackbar(name)),
                ),
              );
            },
            child: Text(
              dialogCtx.l10n.commonDelete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
      ..color = const Color(0xFFF2D1D1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = const Color(0xFF004445)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.57,
      progress * 6.28,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  _BarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      double x = (size.width / 3.1) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

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
  final List<double> values;
  const _BarChart({required this.values});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BarChartPainter(values));
}
