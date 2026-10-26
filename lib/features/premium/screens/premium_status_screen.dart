import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuroved_patient/features/home/controllers/home_controller.dart';

import '../../../core/localization/app_localizations_extension.dart';

enum PremiumPurchaseStatus { success, failed, renew }

class PremiumStatusScreen extends StatelessWidget {
  final PremiumPurchaseStatus status;
  final double amount;
  final String planName;
  final double serviceCharge;
  final double discount;
  final double gst;

  const PremiumStatusScreen({
    super.key,
    required this.status,
    required this.amount,
    required this.planName,
    required this.serviceCharge,
    required this.discount,
    required this.gst,
  });

  void _navigateToHome(BuildContext context) {
    final nav = Navigator.of(context);
    nav.popUntil((route) => route.isFirst);
    HomeController().setTab(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    LinearGradient backgroundGradient;
    Color iconBackgroundColor;
    IconData statusIcon;
    String statusTitle;
    String statusMessage;
    String actionButtonLabel;

    switch (status) {
      case PremiumPurchaseStatus.success:
        backgroundGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF004445), Color(0xFF2D796D)],
        );
        iconBackgroundColor = const Color(0xFF2E8B57);
        statusIcon = Icons.check;
        statusTitle = l10n.premiumWelcomeTitle;
        statusMessage = l10n.premiumStatusActivated;
        actionButtonLabel = l10n.premiumJumpToHome;
        break;
      case PremiumPurchaseStatus.failed:
        backgroundGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBC0000), Color(0xFFFF8787)],
        );
        iconBackgroundColor = const Color(0xFFFF5252);
        statusIcon = Icons.close;
        statusTitle = l10n.premiumPaymentFailedTitle;
        statusMessage = l10n.premiumStatusFailed;
        actionButtonLabel = l10n.premiumRetry;
        break;
      case PremiumPurchaseStatus.renew:
        backgroundGradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE59900), Color(0xFFFFC727)],
        );
        iconBackgroundColor = const Color(0xFFE68900);
        statusIcon = Icons.info_outline;
        statusTitle = l10n.premiumRenewTitle;
        statusMessage = l10n.premiumStatusExpired;
        actionButtonLabel = l10n.premiumRenewNow;
        break;
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(now);
    final formattedTime = DateFormat('hh : mm : ss a').format(now);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (status == PremiumPurchaseStatus.success) {
          _navigateToHome(context);
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(gradient: backgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Semantics(
                      button: true,
                      label: l10n.commonBack,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (status == PremiumPurchaseStatus.success) {
                            _navigateToHome(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
                  Text(
                    statusTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Replaced Expanded with direct Padding to work in ScrollView
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: ClipPath(
                            clipper: ReceiptClipper(),
                            child: Container(
                              width: double.infinity,
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 30,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 30),
                                  Text(
                                    l10n.premiumPaymentTotal,
                                    style: const TextStyle(
                                      color: Colors.black26,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "₹${amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    statusMessage,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  if (status ==
                                      PremiumPurchaseStatus.success) ...[
                                    _buildSimpleRow(l10n.premiumDate, formattedDate),
                                    const SizedBox(height: 15),
                                    _buildSimpleRow(l10n.premiumTime, formattedTime),
                                  ] else ...[
                                    _buildDetailRow(
                                      l10n.premiumBilledTo,
                                      "Krishna Kumar",
                                    ),
                                    _buildDetailRow(l10n.premiumDate, formattedDate),
                                    _buildDetailRow(l10n.premiumTime, formattedTime),
                                    const SizedBox(height: 10),
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    _buildDetailRow(
                                      l10n.premiumBilledAmount,
                                      "₹${serviceCharge.toStringAsFixed(2)}",
                                    ),
                                    _buildDetailRow(
                                      l10n.premiumSavings,
                                      "- ₹${discount.toStringAsFixed(2)}",
                                      valueColor: const Color(0xFFFBC02D),
                                    ),
                                    _buildDetailRow(
                                      l10n.premiumGst,
                                      "+ ₹${gst.toStringAsFixed(2)}",
                                      valueColor: const Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.premiumAmountPaid,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "₹${amount.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 40),
                                  if (status != PremiumPurchaseStatus.success)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFF8A80,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          actionButtonLabel,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: iconBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              statusIcon,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(80, 0, 80, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => _navigateToHome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.premiumJumpToHome,
                          style: const TextStyle(
                            color: Color(0xFF1B4E4E),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black26,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black38, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 15);
    double x = 0;
    double y = size.height - 15;
    double increment = size.width / 12;
    while (x < size.width) {
      x += increment;
      path.arcToPoint(
        Offset(x, y),
        radius: Radius.circular(increment / 2),
        clockwise: false,
      );
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
