import 'package:flutter/material.dart';

class FamilyMemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onTap;

  const FamilyMemberTile({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 10),
              spreadRadius: -5,
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
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C4E4E),
              ),
            ),
            Text(
              member['relation'] ?? "Relative",
              style: const TextStyle(
                color: Color(0xFF5A6A6A),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: ClipOval(
        child: member['image'] != null
            ? Image.network(member['image'], fit: BoxFit.cover)
            : Icon(Icons.person, size: 30, color: Colors.grey.shade400),
      ),
    );
  }
}
