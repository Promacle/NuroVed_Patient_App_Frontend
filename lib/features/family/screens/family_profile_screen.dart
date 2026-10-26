import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/family/screens/add_family_member_screen.dart';

import '../../profile/controllers/profile_controller.dart';
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

  // Inside your _FamilyProfilesScreenState build method:
  @override
  Widget build(BuildContext context) {
    // Use ListenableBuilder targeting the ProfileController
    return ListenableBuilder(
      listenable: ProfileController(),
      builder: (context, _) {
        final members = _controller.familyMembers;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
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

                    final isCurrentActive =
                        members[index]['id'] ==
                        ProfileController.instance.activeSubjectId;

                    return FamilyMemberTile(
                      member: members[index],
                      isActive: isCurrentActive,
                      onTap: () =>
                          _onMemberTapped(context, members[index], index),
                      onDelete: () => _confirmDeletion(context, members[index]),
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

  void _onMemberTapped(
    BuildContext context,
    Map<String, dynamic> member,
    int index,
  ) {
    final profileCtrl = ProfileController.instance;
    final memberId = member['id']?.toString() ?? '';
    final isAlreadyActive = memberId == profileCtrl.activeSubjectId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member['name'] ?? 'Family Member',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              const SizedBox(height: 15),
              if (!isAlreadyActive)
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(context.l10n.familySelectActiveProfile),
                  subtitle: Text(
                    context.l10n.familySwitchActiveProfileSubtitle,
                  ),
                  onTap: () {
                    profileCtrl.switchSubject(memberId);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.familySwitchedActiveProfile(
                            member['name'] ?? '',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF2C4E4E),
                ),
                title: Text(context.l10n.familyEditMemberProfile),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFamilyMemberScreen(
                        memberData: member,
                        index: index,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletion(BuildContext context, Map<String, dynamic> member) {
    final name = member['name'] ?? 'this profile';
    final id = member['id']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.familyRemoveProfileTitle),
        content: Text(
          context.l10n.familyRemoveProfileMessage(name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (id.isNotEmpty) {
                _controller.removeFamilyMemberById(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.familyRemovedMemberSnackbar(name),
                    ),
                    backgroundColor: AppColors.primaryTeal,
                  ),
                );
              }
            },
            child: Text(
              context.l10n.commonDelete,
              style: const TextStyle(color: Colors.red),
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
              Semantics(
                button: true,
                label: context.l10n.commonBack,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    child: Center(
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
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  context.l10n.familyProfilesTitle,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              context.l10n.familyProfilesSubtitle,
              style: const TextStyle(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "+ ${context.l10n.familyAddNewProfile}",
                textAlign: TextAlign.center,
                style: const TextStyle(
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
