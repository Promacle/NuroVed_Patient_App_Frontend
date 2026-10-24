import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/widgets/backend_status_banner.dart';
import 'package:nuroved_patient/core/widgets/empty_state_view.dart';
import 'package:nuroved_patient/core/widgets/section_header.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';

import '../widgets/graph_card.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/record_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopHeader(context),
          const BackendStatusBanner(),
          _buildBodyContent(context),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(),
          SizedBox(height: 24),
          Text(
            "Let's take the next step\nfor your health!",
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5B7D72),
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 24),
          GraphCard(),
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuickAccessGrid(),
          const SizedBox(height: 28),
          SectionHeader(
            title: "Recent Health Records",
            subtitle: "Diagnostic reports and prescriptions",
            actionText: "View All",
            onAction: () => Navigator.pushNamed(context, AppRouter.records),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: RecordsController.instance,
            builder: (context, _) {
              final records = RecordsController.instance.records;
              if (records.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: EmptyStateView(
                    icon: Icons.description_outlined,
                    title: "No medical records yet",
                    description:
                        "Upload lab tests, doctor notes, or prescriptions to track your health progress.",
                    actionLabel: "+ Upload Record",
                    onAction: () =>
                        Navigator.pushNamed(context, AppRouter.records),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: records.length > 5 ? 5 : records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return RecordCard(
                      title: record.title,
                      subtitle: record.description ?? record.recordType,
                      date: record.date,
                      type: record.recordType,
                      onView: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.recordDetails,
                          arguments: record,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
