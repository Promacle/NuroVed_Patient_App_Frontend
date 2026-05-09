import 'dart:io';

import 'package:flutter/material.dart';

class FamilyMemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Callback for the delete icon

  const FamilyMemberTile({
    super.key,
    required this.member,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMain = member['isMain'] ?? false;

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F3),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(height: 10),
                Text(
                  member['name'] ?? "Unknown",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                Text(
                  member['relation'] ?? "Relative",
                  style: const TextStyle(
                    color: Color(0xFF5A6A6A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        // DELETE ICON: Only shown for non-main profiles
        if (!isMain && onDelete != null)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    final dynamic imageFile = member['imageFile'];
    return Container(
      height: 55,
      width: 55,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFDCEAE5),
      ),
      child: ClipOval(
        child: imageFile != null
            ? Image.file(
                imageFile as File,
                fit: BoxFit.cover,
              ) // Show the uploaded photo
            : const Icon(Icons.person, size: 30, color: Colors.grey),
      ),
    );
  }
}
