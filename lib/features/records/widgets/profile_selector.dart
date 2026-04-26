import 'package:flutter/material.dart';

// lib/features/records/widgets/profile_selector.dart

class ProfileSelector extends StatelessWidget {
  final String name;
  final List<String> familyNames;
  final Function(String) onSelected;

  const ProfileSelector({
    super.key,
    required this.name,
    required this.familyNames,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 45),
      itemBuilder: (context) => familyNames.map((String familyName) {
        return PopupMenuItem<String>(
          value: familyName,
          child: Text(familyName),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFE1ECE7),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }
}
