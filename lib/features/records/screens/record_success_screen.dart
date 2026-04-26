import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../home/screens/main_layout.dart';

class RecordSuccessScreen extends StatelessWidget {
  final String profileName;
  final DateTime date;

  const RecordSuccessScreen({
    super.key,
    required this.profileName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    String formattedTime = DateFormat('hh : mm : ss a').format(date);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA8D5C2), // Light mint from image top
              AppColors.mintBackground, // Your theme mint
              Color(0xFFE2EDEA), // Lighter mint at bottom
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
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
            const Spacer(flex: 2),
            // Green Success Checkmark
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF3B8E6D),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 40),
            const Text(
              "New Record Saved\nSuccessfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(flex: 2),
            // Date and Time Info Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  _buildDataRow("Date", formattedDate),
                  const SizedBox(height: 20),
                  _buildDataRow("Time", formattedTime),
                ],
              ),
            ),
            const Spacer(flex: 3),
            // See in Records Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    // Use pushAndRemoveUntil to reset the app state to the Records Tab
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainLayout(initialIndex: 1),
                      ),
                      (route) => false, // Clears the success screen from memory
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.darkTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "See in Records",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
