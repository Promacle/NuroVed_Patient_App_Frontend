import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/home/widgets/graph_card.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/widgets/profile_selector.dart';

import '../../../app/app_router.dart';
import '../controllers/visits_controller.dart';
import '../widgets/visit_timeline_item.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  final VisitsController _controller = VisitsController();

  @override
  void initState() {
    super.initState();
    _controller.loadVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GraphCard(), // Reused from Home
                  const SizedBox(height: 30),
                  const Text(
                    "Recent Visit's",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.filteredVisits.length,
                    itemBuilder: (context, index) {
                      // <--- START REPLACING HERE
                      final visit = _controller.filteredVisits[index];

                      // LOGIC: Show date if it's the first item OR if this date is different from the previous one
                      final bool showDate =
                          index == 0 ||
                          _controller.filteredVisits[index]['date'] !=
                              _controller.filteredVisits[index - 1]['date'];

                      return VisitTimelineItem(
                        date: visit['date'],
                        showDate: showDate, // Pass the calculated flag
                        title: visit['title'],
                        subtitle: visit['subtitle'],
                        icon: visit['icon'],
                        isFirst: index == 0,
                        isLast: index == _controller.filteredVisits.length - 1,
                      );
                    }, // <--- END REPLACING HERE
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          // Inside VisitsScreen's floatingActionButton:
          onPressed: () => Navigator.pushNamed(context, AppRouter.addVisit),
          backgroundColor: const Color(0xFF7CB9A8),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
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
              const Text(
                "Visits",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              ProfileSelector(
                name: ProfileController().activeProfileName.split(" ")[0],
                familyNames: ProfileController().familyMembers
                    .map((e) => e['name'] as String)
                    .toList(),
                onSelected: (name) {
                  setState(() {
                    ProfileController().activeProfileName = name;
                    _controller.loadVisits();
                  });
                },
              ),
            ],
          ),
          const Text(
            "Your Health Timeline",
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
