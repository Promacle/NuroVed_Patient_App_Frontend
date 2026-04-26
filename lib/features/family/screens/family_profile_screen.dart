import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/family/screens/add_family_member_screen.dart';

import '../../settings/controllers/app_settings_controller.dart';
import '../controllers/family_controller.dart';
import '../widgets/family_member_tile.dart';
import 'edit_family_member_screen.dart';

class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});

  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  final FamilyController _controller = FamilyController();
  final AppSettingsController _settingsController = AppSettingsController();

  @override
  Widget build(BuildContext context) {
    final members = _controller.familyMembers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemCount: members.length + 1,
              itemBuilder: (context, index) {
                if (index == members.length) {
                  return _buildAddMemberCard(context);
                }
                return FamilyMemberTile(
                  member: members[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFamilyMemberScreen(
                          memberData: members[index],
                          index: index,
                        ),
                      ),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
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
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.sageGreen,
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
                "Family Profile",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: Text(
              "Manage Your Families Profiles Information",
              style: TextStyle(
                color: Color(0xFF5A6A6A),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddFamilyMemberScreen(),
          ),
        );
        if (mounted) setState(() {});
      },
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1ED).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "+ Add New\nFamily Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5A5A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(15),
        ),
      );
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 3), paint);
        distance += 5;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
