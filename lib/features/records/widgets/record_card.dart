import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';

class RecordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Add this

  const RecordCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE1ECE7).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 6), // Sharp shadow
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The Trash/Delete Icon exactly as shown in photo
          Positioned(
            top: 3,
            right: -1,
            child: IconButton(
              // Changed from Icon to IconButton
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Color(0xFF81C7AD),
              ),
              onPressed: onDelete, // Call the delete function
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Creates space between elements
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Larger Document Icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppAssets.docIcon,
                    height: 50, // Increased size to match photo
                    width: 50,
                  ),
                ),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),

                // Subtitle (Allowed to take 2 lines if needed for space)
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7A7A7A),
                    height: 1.2,
                  ),
                ),

                // Pill shaped View Button
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C7AD),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
