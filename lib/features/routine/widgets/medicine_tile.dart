import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/core/localization/app_localizations_extension.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

/// Responsive, production-grade medication card widget.
///
/// Fixes narrow-width constraint defects by eliminating rigid [ListTile] slots,
/// allowing the medicine name to occupy the full available width, and placing
/// status badges and dosage chips in a responsive [Wrap] layout.
class MedicineTile extends StatefulWidget {
  final String name;
  final String instruction;
  final bool isCompleted;
  final String? sourceDisplay;
  final String? dosage;
  final String? time;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MedicineTile({
    super.key,
    required this.name,
    required this.instruction,
    required this.isCompleted,
    required this.onTap,
    this.sourceDisplay,
    this.dosage,
    this.time,
    this.onDelete,
  });

  @override
  State<MedicineTile> createState() => _MedicineTileState();
}

class _MedicineTileState extends State<MedicineTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isVerified = widget.sourceDisplay == 'Verified Prescription';
    final isCompleted = widget.isCompleted;

    // Structured metadata resolution
    String? displayDosage = widget.dosage;
    String? displayTime = widget.time;
    String displayInstruction = widget.instruction;

    if (widget.instruction.contains(" * ")) {
      final parts = widget.instruction.split(" * ");
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        final doseUnit = parts[0].trim();
        if (displayDosage == null || displayDosage.isEmpty) {
          displayDosage = doseUnit;
        } else if (!displayDosage.toLowerCase().contains(
              doseUnit.toLowerCase(),
            ) &&
            !doseUnit.toLowerCase().contains(displayDosage.toLowerCase())) {
          displayDosage = "$displayDosage • $doseUnit";
        }
      }
      if (parts.length > 1 &&
          (displayTime == null || displayTime.isEmpty) &&
          parts[1].trim().isNotEmpty) {
        displayTime = parts[1].trim();
      }
      if (parts.length > 2) {
        displayInstruction = parts.sublist(2).join(" • ").trim();
      } else if (parts.length == 2) {
        displayInstruction = "";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? AppColors.primaryTeal.withValues(alpha: 0.35)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Icon + Name (Full available width) + Actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leading Medication Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primaryTeal.withValues(alpha: 0.14)
                              : const Color(0xFFEDF6F3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.pills,
                            color: isCompleted
                                ? AppColors.primaryTeal
                                : const Color(0xFF397D71),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Middle: Medicine Name spanning available horizontal width
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF1E293B),
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.primaryTeal,
                                height: 1.25,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Trailing Actions: Delete + Completion Checkbox
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.onDelete != null)
                            Semantics(
                              button: true,
                              label: context.l10n.commonDelete,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                onPressed: widget.onDelete,
                                tooltip: context.l10n.commonDelete,
                              ),
                            ),
                          Semantics(
                            button: true,
                            label: isCompleted
                                ? context.l10n.routineStatusTaken
                                : context.l10n.routineStatusPending,
                            child: IconButton(
                              icon: Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isCompleted
                                    ? AppColors.primaryTeal
                                    : const Color(0xFF94A3B8),
                                size: 26,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              onPressed: widget.onTap,
                              tooltip: isCompleted
                                  ? context.l10n.routineStatusTaken
                                  : context.l10n.routineStatusPending,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Row 2: Metadata Chips & Status Badges
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Scheduled Time Chip
                      if (displayTime != null && displayTime.isNotEmpty)
                        _buildChip(
                          icon: Icons.access_time_rounded,
                          label: displayTime,
                          bgColor: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF334155),
                          iconColor: const Color(0xFF64748B),
                        ),

                      // Dosage Chip
                      if (displayDosage != null && displayDosage.isNotEmpty)
                        _buildChip(
                          icon: Icons.medication_liquid_outlined,
                          label: displayDosage,
                          bgColor: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF334155),
                          iconColor: const Color(0xFF64748B),
                        ),

                      // Verification Source Badge
                      if (widget.sourceDisplay != null)
                        _buildSourceBadge(context, isVerified),

                      // Status Badge (Taken / Pending)
                      _buildStatusBadge(context, isCompleted),
                    ],
                  ),

                  // Row 3: Instructions & Notes Section
                  if (displayInstruction.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2, right: 6),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  displayInstruction,
                                  maxLines: _isExpanded ? null : 3,
                                  overflow: _isExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (displayInstruction.length > 80)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isExpanded = !_isExpanded),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _isExpanded
                                        ? context
                                              .l10n
                                              .routineShowLessInstructions
                                        : context
                                              .l10n
                                              .routineShowMoreInstructions,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryTeal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(BuildContext context, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_user_outlined : Icons.edit_note,
            size: 11,
            color: isVerified
                ? const Color(0xFF0369A1)
                : const Color(0xFF475569),
          ),
          const SizedBox(width: 4),
          Text(
            widget.sourceDisplay == 'Verified Prescription'
                ? context.l10n.routineSourceVerifiedPrescription
                : (widget.sourceDisplay == 'Self-Entered'
                      ? context.l10n.routineSourceSelfEntered
                      : widget.sourceDisplay!),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isVerified
                  ? const Color(0xFF0369A1)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check : Icons.schedule,
            size: 11,
            color: isCompleted
                ? const Color(0xFF166534)
                : const Color(0xFF92400E),
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted
                ? context.l10n.routineStatusTaken
                : context.l10n.routineStatusPending,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? const Color(0xFF166534)
                  : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}
