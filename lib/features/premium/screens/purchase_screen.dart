import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/constants/app_assets.dart';
import 'package:nuroved_patient/features/premium/screens/premium_status_screen.dart';

import '../../../app/app_router.dart';

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
    // Dynamic calculations based on selected plan
    bool isYearly = widget.planName.contains('Yearly');

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
                    _buildStatusCard(isYearly),
                    const SizedBox(height: 25),
                    _buildPaymentMethods(),
                    const SizedBox(height: 25),
                    _buildSecureBadge(),
                    const SizedBox(height: 30),
                    _buildCalculationSection(
                      serviceCharge,
                      discount,
                      gst,
                      total,
                    ),
                    const SizedBox(height: 30),
                    _buildPayButton(total, serviceCharge, discount, gst),
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
          GestureDetector(
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
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NuroVed Purchase",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Promacle private limited",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isYearly) {
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
              const Text(
                "Your account will be active for",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                isYearly ? "365 Days" : "30 Days",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4E4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "NuroVed special Offer",
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isYearly ? "70% Off Yearly" : "65% Off Monthly",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    "you will save ₹${isYearly ? '2100' : '166'} on ${isYearly ? 'yearly' : 'monthly'}",
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),
                ],
              ),
              Switch(
                value: _isOfferApplied,
                onChanged: (val) => setState(() => _isOfferApplied = val),
                activeColor: const Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Method",
          style: TextStyle(
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

  Widget _buildSecureBadge() {
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
        const Text(
          "100% Secure & Safe payments",
          style: TextStyle(color: Colors.black38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCalculationSection(
    double serviceCharge,
    double discount,
    double gst,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          _buildCalcRow(
            "Service Charge",
            "₹${serviceCharge.toStringAsFixed(2)}",
          ),
          _buildCalcRow(
            "Discount",
            "- ₹${discount.toStringAsFixed(2)}",
            isDiscount: true,
          ),
          _buildCalcRow("GST", "₹${gst.toStringAsFixed(2)}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount To Pay",
                style: TextStyle(
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

  // Update _buildPayButton method
  Widget _buildPayButton(
    double total,
    double serviceCharge,
    double discount,
    double gst,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _navigateToStatus(
              context,
              PremiumPurchaseStatus.success,
              total,
              serviceCharge,
              discount,
              gst,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F8F6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Pay",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToStatus(
                  context,
                  PremiumPurchaseStatus.failed,
                  total,
                  serviceCharge,
                  discount,
                  gst,
                ),
                child: const Text(
                  "Demo: Failed",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToStatus(
                  context,
                  PremiumPurchaseStatus.renew,
                  total,
                  serviceCharge,
                  discount,
                  gst,
                ),
                child: const Text(
                  "Demo: Renew",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToStatus(
    BuildContext context,
    PremiumPurchaseStatus status,
    double total,
    double serviceCharge,
    double discount,
    double gst,
  ) {
    Navigator.pushNamed(
      context,
      AppRouter.premiumStatus,
      arguments: {
        'status': status,
        'amount': total,
        'planName': widget.planName,
        'serviceCharge': serviceCharge,
        'discount': discount,
        'gst': gst,
      },
    );
  }
}
