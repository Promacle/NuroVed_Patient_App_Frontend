import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';

/// Screen allowing patients to report application defects or sync anomalies.
///
/// In accordance with NuroVed clinical and data integrity guidelines,
/// submitted reports are recorded on the local device as diagnostics.
/// The screen clearly differentiates genuine device-recorded entries from
/// demonstration or reference entries.
class ReportProblemScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialProblems;

  const ReportProblemScreen({super.key, this.initialProblems});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _problemController = TextEditingController();
  final FocusNode _problemFocusNode = FocusNode();

  String? _validationError;
  bool _isSubmitting = false;

  late final List<Map<String, dynamic>> _pastProblems;

  static const int _maxCharacterCount = 500;
  static const int _minCharacterCount = 10;

  @override
  void initState() {
    super.initState();
    _pastProblems = widget.initialProblems != null
        ? List<Map<String, dynamic>>.from(widget.initialProblems!)
        : [
            {
              "description":
                  "Symptom analyser stalled during question flow and did not produce recommendations.",
              "time": "3 mins ago",
              "isDemo": true,
            },
            {
              "description":
                  "Medical record file preview did not refresh immediately after upload completed.",
              "time": "3 days ago",
              "isDemo": true,
            },
          ];

    _problemController.addListener(() {
      if (mounted) {
        if (_validationError != null &&
            _problemController.text.trim().length >= _minCharacterCount) {
          _validationError = null;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _problemController.dispose();
    _problemFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final l10n = context.l10n;
    final text = _problemController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _validationError = l10n.validationEnterIssue;
      });
      _problemFocusNode.requestFocus();
      return;
    }

    if (text.length < _minCharacterCount) {
      setState(() {
        _validationError = l10n.validationIssueTooShort;
      });
      _problemFocusNode.requestFocus();
      return;
    }

    setState(() {
      _validationError = null;
      _isSubmitting = true;
    });

    // Brief asynchronous pause to simulate local diagnostic registration
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    setState(() {
      _pastProblems.insert(0, {
        "description": text,
        "time": "Just now",
        "isDemo": false,
      });
      _problemController.clear();
      _isSubmitting = false;
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.reportProblemSavedSuccess,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.kMainBg,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: bottomInset + 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputCard(),
                    const SizedBox(height: 28),
                    _buildHistorySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding > 20 ? topPadding + 10 : 44,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: context.l10n.commonBack,
            child: Semantics(
              button: true,
              label: context.l10n.commonBack,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC7E2D9),
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
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.reportProblemTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.reportProblemSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    final l10n = context.l10n;
    final currentLength = _problemController.text.length;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      backgroundColor: Colors.white,
      borderColor: _validationError != null
          ? AppColors.errorRed.withValues(alpha: 0.5)
          : AppColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primaryTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportProblemDescribeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    Text(
                      l10n.reportProblemDescribeSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _problemController,
            focusNode: _problemFocusNode,
            minLines: 4,
            maxLines: 7,
            maxLength: _maxCharacterCount,
            enabled: !_isSubmitting,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.reportProblemDescribeHint,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
              filled: true,
              fillColor: AppColors.surfaceWarm,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _validationError != null
                      ? AppColors.errorRed
                      : AppColors.borderSubtle,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryTeal,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              counterText: "$currentLength / $_maxCharacterCount",
              counterStyle: TextStyle(
                fontSize: 11,
                color: currentLength > _maxCharacterCount * 0.9
                    ? AppColors.warningAmber
                    : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: AppColors.errorRed,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.darkTeal.withValues(
                  alpha: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isSubmitting
                    ? context.l10n.reportProblemSubmitting
                    : context.l10n.reportProblemSubmitButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final l10n = context.l10n;
    if (_pastProblems.isEmpty) {
      return EmptyStateView(
        icon: Icons.assignment_outlined,
        title: l10n.reportProblemEmpty,
        description: l10n.reportProblemEmptyDesc,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.reportProblemPastSection,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_pastProblems.length}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.reportProblemDeviceRecorded,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
        const SizedBox(height: 16),
        ..._pastProblems.map((problem) => _buildProblemCard(problem)),
      ],
    );
  }

  Widget _buildProblemCard(Map<String, dynamic> problem) {
    final isDemo = problem['isDemo'] == true;
    final description = (problem['description'] as String?) ?? '';
    final time = (problem['time'] as String?) ?? '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: isDemo ? AppColors.borderSubtle : AppColors.borderTeal,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDemo
                        ? const Color(0xFFF1F5F9)
                        : AppColors.surfaceMint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDemo
                            ? Icons.info_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 13,
                        color: isDemo
                            ? AppColors.textGrey
                            : AppColors.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isDemo
                              ? context.l10n.reportProblemBadgeSample
                              : context.l10n.reportProblemBadgeSaved,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDemo
                                ? AppColors.textGrey
                                : AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
