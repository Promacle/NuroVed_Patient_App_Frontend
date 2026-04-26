import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/utils/skeleton_wrapper.dart'; // Import Wrapper
import 'package:nuroved_patient/features/diet/screens/food_scanner_screen.dart';
import 'package:nuroved_patient/features/home/screens/home_screen.dart';
import 'package:nuroved_patient/features/profile/screens/profile_screen.dart';
import 'package:nuroved_patient/features/records/screens/records_screen.dart';
import 'package:nuroved_patient/features/visits/screens/visits_screen.dart';

import '../widgets/custom_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex; // Add this line

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex; // Change to late

  @override
  void initState() {
    super.initState();
    // Initialize current index with the value passed to the widget
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecordsScreen(),
    const FoodScannerScreen(),
    const VisitsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // We wrap the current screen in SkeletonWrapper and give it a UniqueKey.
          // The UniqueKey forces the SkeletonWrapper to RE-INITIALIZE every time index changes.
          SkeletonWrapper(key: UniqueKey(), child: _screens[_currentIndex]),

          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex != index) {
                  setState(() => _currentIndex = index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
