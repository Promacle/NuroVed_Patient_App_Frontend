import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../widgets/graph_card.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/record_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Inside lib/features/home/screens/home_screen.dart
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // No Scaffold here!
      child: Column(children: [_buildTopHeader(), _buildBodyContent()]),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
      decoration: const BoxDecoration(
        color: AppColors.kTopBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(),
          SizedBox(height: 30),
          Text(
            "Let's take the next step\nfor your health!",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Color(0xFF718E84),
              height: 1.2,
            ),
          ),
          SizedBox(height: 30),
          GraphCard(),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuickAccessGrid(),
          const SizedBox(height: 30),
          const Text(
            "Recent Record Access :-",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.kDarkText,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 260,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: const [
                RecordCard(
                  title: 'Blood Test Report',
                  subtitle: 'Blood test report for dengue.',
                ),
                RecordCard(
                  title: 'Covid-19 Vaccine',
                  subtitle: 'Vaccine report from hope hospital.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
