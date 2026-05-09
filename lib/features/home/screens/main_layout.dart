import 'package:flutter/material.dart';
import 'package:nuroved_patient/features/diet/screens/food_scanner_screen.dart';
import 'package:nuroved_patient/features/home/screens/home_screen.dart';
import 'package:nuroved_patient/features/profile/screens/profile_screen.dart';
import 'package:nuroved_patient/features/records/screens/records_screen.dart';
import 'package:nuroved_patient/features/visits/screens/visits_screen.dart';

import '../../../app/app_router.dart';
import '../controllers/home_controller.dart';
import '../widgets/custom_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex; // Add this line

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final HomeController _homeController = HomeController(); // Access singleton

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Records
    GlobalKey<NavigatorState>(), // Food Scanner
    GlobalKey<NavigatorState>(), // Visits
    GlobalKey<NavigatorState>(), // Profile
  ];

  @override
  void initState() {
    super.initState();
    // Initialize current index with the value passed to the widget
    _homeController.setTab(widget.initialIndex);
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        // If it's the root of the tab, show the main feature page
        if (settings.name == '/' || settings.name == null) {
          return MaterialPageRoute(builder: (_) => rootPage);
        }
        // Otherwise, use our central AppRouter for sub-pages
        return AppRouter.generateRoute(settings);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _homeController,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            final currentNavigator =
                _navigatorKeys[_homeController.currentIndex].currentState;

            // Nested navigation back button logic
            if (currentNavigator != null && currentNavigator.canPop()) {
              currentNavigator.pop();
            } else if (_homeController.currentIndex != 0) {
              _homeController.setTab(0);
            } else {
              if (context.mounted) Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            // Enables the background content to show behind the floating bar
            extendBody: true,
            body: IndexedStack(
              index: _homeController.currentIndex,
              children: [
                _buildTabNavigator(0, const HomeScreen()),
                _buildTabNavigator(1, const RecordsScreen()),
                _buildTabNavigator(2, const FoodScannerScreen()),
                _buildTabNavigator(3, const VisitsScreen()),
                _buildTabNavigator(4, const ProfileScreen()),
              ],
            ),
            // Floating navigation bar with blur effect
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
              child: CustomBottomNav(
                currentIndex: _homeController.currentIndex,
                onTap: (index) {
                  if (index == _homeController.currentIndex) {
                    // Smart Reset: Tapping active icon returns to root
                    _navigatorKeys[index].currentState?.popUntil(
                      (route) => route.isFirst,
                    );
                  } else {
                    _homeController.setTab(index);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
