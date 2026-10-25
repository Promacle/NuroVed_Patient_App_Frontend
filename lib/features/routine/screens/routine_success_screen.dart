import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuroved_patient/app/app_router.dart';

class RoutineSuccessScreen extends StatelessWidget {
  const RoutineSuccessScreen({super.key});

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _navigateToDiet(BuildContext context) {
    final nav = Navigator.of(context);
    bool reachedDiet = false;
    nav.popUntil((route) {
      if (route.settings.name == AppRouter.diet ||
          route.settings.name == '/diet') {
        reachedDiet = true;
        return true;
      }
      return route.isFirst;
    });
    if (!reachedDiet) {
      if (nav.canPop()) {
        nav.pop();
      } else {
        nav.pushReplacementNamed(AppRouter.diet);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Real-time date and time
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final timeStr = DateFormat('hh : mm : ss a').format(now);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF86C8B7), // Mint green from photo
                Color(0xFFD6EAE3),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Semantics(
                        button: true,
                        label: 'Back',
                        child: GestureDetector(
                          onTap: () => _handleBack(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Success Icon Circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF397D71),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Meal has been taken calorie\nhas been saved",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 80),
                    // Data Rows
                    _buildInfoRow("Date", dateStr),
                    const SizedBox(height: 15),
                    _buildInfoRow("Time", timeStr),
                    const SizedBox(height: 60),
                    // See in Diet Section Button
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _navigateToDiet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF004445),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "See in Diet Section",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF7A8A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
