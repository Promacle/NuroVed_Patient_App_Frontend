import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';

class CalorieSuccessScreen extends StatelessWidget {
  final DateTime timestamp;

  const CalorieSuccessScreen({super.key, required this.timestamp});

  void _handleBack(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      _navigateToDiet(context);
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
      nav.pushNamed(AppRouter.diet);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
    String formattedTime = DateFormat('hh : mm : ss a').format(timestamp);

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
              colors: [Color(0xFFA8D5C2), Color(0xFFE8F2EF), Color(0xFFF0F6F4)],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Semantics(
                      button: true,
                      label: context.l10n.commonBack,
                      child: GestureDetector(
                        onTap: () => _handleBack(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC4E2D5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF2C4E4E),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Success Checkmark
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B8E6D),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 40),
                Text(
                  context.l10n.dietCalorieSavedSuccess,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 60),
                // Date and Time Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      _buildDataRow(context.l10n.recordsDateLabel, formattedDate),
                      const SizedBox(height: 20),
                      _buildDataRow(context.l10n.commonTime, formattedTime),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                // Action Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: ElevatedButton(
                    onPressed: () => _navigateToDiet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      context.l10n.dietSeeInDietSection,
                      style: const TextStyle(
                        color: Color(0xFF2C4E4E),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2C4E4E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
