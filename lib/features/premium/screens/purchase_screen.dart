import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../../../core/localization/app_localizations_extension.dart';

class PurchaseScreen extends StatefulWidget {
  final String planName;
  final String price;
  final String period;

  const PurchaseScreen({
    super.key,
    required this.planName,
    required this.price,
    required this.period,
  });

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  int _selectedMethod = 0; // 0 for PhonePe, 1 for Paytm, 2 for GPay, 3 for BHIM
  bool _isOfferApplied = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Dynamic calculations based on selected plan
    bool isYearly = widget.planName.toLowerCase().contains('yearly') ||
        widget.planName == l10n.premiumYearlyPlan;

    // Values matched to the reference photo for Yearly, and proportional for Monthly
    double serviceCharge = isYearly ? 2870.00 : 255.00;
    double discount = _isOfferApplied ? (isYearly ? 2100.00 : 166.00) : 0.00;
    double gst = isYearly ? 34.02 : 3.02;
    double total = serviceCharge - discount + gst;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatusCard(context, isYearly),
                    const SizedBox(height: 25),
                    _buildPaymentMethods(context),
                    const SizedBox(height: 25),
                    _buildSecureBadge(context),
                    const SizedBox(height: 30),
                    _buildCalculationSection(
                      context,
                      serviceCharge,
                      discount,
                      gst,
                      total,
                    ),
                    const SizedBox(height: 30),
                    _buildPayButton(context, total, serviceCharge, discount, gst),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4E4E), Color(0xFF2C5E5E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: context.l10n.commonBack,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.purchaseTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  context.l10n.purchaseCompanySubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isYearly) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.purchaseActiveDuration,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                l10n.purchaseDaysCount(isYearly ? 365 : 30),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4E4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            l10n.purchaseSpecialOffer,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isYearly ? l10n.purchaseOffYearly : l10n.purchaseOffMonthly,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    l10n.purchaseYouWillSave(
                      isYearly ? '2100' : '166',
                      isYearly ? l10n.purchaseYearly : l10n.purchaseMonthly,
                    ),
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),
                ],
              ),
              Switch(
                value: _isOfferApplied,
                onChanged: (val) => setState(() => _isOfferApplied = val),
                activeThumbColor: const Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.purchaseSelectMethod,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4E4E),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMethodItem(
              0,
              AppAssets.phonePeIcon,
              "PhonePe",
              const Color(0xFF6739B7),
            ),
            _buildMethodItem(
              1,
              AppAssets.paytmIcon,
              "Paytm",
              const Color(0xFF002E6E),
            ),
            _buildMethodItem(
              2,
              AppAssets.googlePayIcon,
              "Google Pay",
              const Color(0xFF5E7BEF),
            ),
            _buildMethodItem(
              3,
              AppAssets.bhimIcon,
              "BHIM",
              const Color(0xFF008D3D),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodItem(int index, String asset, String label, Color color) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        width: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                asset,
                height: 35,
                width: 35,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.payment, size: 30, color: Colors.grey),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white10,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureBadge(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppAssets.paymentSecureShield,
          height: 35,
          errorBuilder: (c, e, s) =>
              const Icon(Icons.security, color: Color(0xFF004D40)),
        ),
        const SizedBox(width: 10),
        Text(
          context.l10n.purchaseSecureBadge,
          style: const TextStyle(color: Colors.black38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCalculationSection(
    BuildContext context,
    double serviceCharge,
    double discount,
    double gst,
    double total,
  ) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          _buildCalcRow(
            l10n.purchaseServiceCharge,
            "₹${serviceCharge.toStringAsFixed(2)}",
          ),
          _buildCalcRow(
            l10n.purchaseDiscount,
            "- ₹${discount.toStringAsFixed(2)}",
            isDiscount: true,
          ),
          _buildCalcRow(l10n.premiumGst, "₹${gst.toStringAsFixed(2)}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.purchaseTotalAmountToPay,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "₹${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDiscount ? const Color(0xFFFBC02D) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(
    BuildContext context,
    double total,
    double serviceCharge,
    double discount,
    double gst,
  ) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2E4DD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F4F0),
            ),
            child: const Icon(
              Icons.credit_card_off_rounded,
              size: 26,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.purchaseUnavailableTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4E4E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.purchaseUnavailableDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C4E4E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.purchaseReturnToApp,
                style: const TextStyle(
                  color: Colors.white,
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
}
