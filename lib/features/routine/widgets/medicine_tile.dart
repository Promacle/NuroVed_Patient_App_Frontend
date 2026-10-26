import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';

class MedicineTile extends StatelessWidget {
  final String name;
  final String instruction;
  final bool isCompleted;
  final String? sourceDisplay;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MedicineTile({
    super.key,
    required this.name,
    required this.instruction,
    required this.isCompleted,
    required this.onTap,
    this.sourceDisplay,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = sourceDisplay == 'Verified Prescription';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap, // Entire tile is now clickable
        behavior: HitTestBehavior.opaque,
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
                child: const FaIcon(
                  FontAwesomeIcons.pills,
                  color: Color(0xFF397D71),
                  size: 24,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                ),
                if (sourceDisplay != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? const Color(0xFFE0F2FE)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isVerified
                            ? const Color(0xFFBAE6FD)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      sourceDisplay == 'Verified Prescription'
                          ? context.l10n.routineSourceVerifiedPrescription
                          : (sourceDisplay == 'Self-Entered'
                              ? context.l10n.routineSourceSelfEntered
                              : sourceDisplay!),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isVerified
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                instruction,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.black38,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.circle,
                  color: isCompleted ? const Color(0xFF397D71) : Colors.black12,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
