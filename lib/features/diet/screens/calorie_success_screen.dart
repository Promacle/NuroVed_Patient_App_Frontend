import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalorieSuccessScreen extends StatelessWidget {
  final DateTime timestamp;

  const CalorieSuccessScreen({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
    String formattedTime = DateFormat('hh : mm : ss a').format(timestamp);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA8D5C2), Color(0xFFE8F2EF), Color(0xFFF0F6F4)],
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
            const Text(
              "Calorie Saved\nSuccessfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
            const Spacer(flex: 2),
            // Date and Time Info
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
            // Action Button
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Diet Section
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/diet',
                    (route) => route.isFirst,
                  );
                },
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
                child: const Text(
                  "See in Diet Section",
                  style: TextStyle(
                    color: Color(0xFF2C4E4E),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
