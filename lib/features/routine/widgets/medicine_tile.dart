import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MedicineTile extends StatelessWidget {
  final String name;
  final String instruction;
  final bool isCompleted;
  final VoidCallback onTap;

  const MedicineTile({
    super.key,
    required this.name,
    required this.instruction,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDF4F2),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Transform.rotate(
              angle: -0.5,
              child: const Icon(
                FontAwesomeIcons.pills,
                color: Color(0xFF397D71),
                size: 24,
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2C4E4E),
            ),
          ),
          subtitle: Text(
            instruction,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.circle,
            color: isCompleted ? const Color(0xFF397D71) : Colors.black12,
            size: 26,
          ),
        ),
      ),
    );
  }
}
