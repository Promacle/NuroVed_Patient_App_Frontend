import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';

class FamilyMemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isActive;

  const FamilyMemberTile({
    super.key,
    required this.member,
    required this.onTap,
    this.onDelete,
    this.isActive = false,
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
              border: isActive
                  ? Border.all(color: AppColors.primaryTeal, width: 2)
                  : Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "ACTIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
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
    Widget? avatarImage;
    if (imageFile is AppPlatformFile && imageFile.bytes != null) {
      avatarImage = Image.memory(imageFile.bytes!, fit: BoxFit.cover);
    } else if (imageFile is Uint8List) {
      avatarImage = Image.memory(imageFile, fit: BoxFit.cover);
    }

    return Container(
      height: 55,
      width: 55,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child:
            avatarImage ??
            const Icon(Icons.person, color: Color(0xFF7CB9A8), size: 30),
      ),
    );
  }
}
