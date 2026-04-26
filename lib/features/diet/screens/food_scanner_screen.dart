import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:nuroved_patient/features/diet/widgets/diet_planner_widgets.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _showResult = false;
  bool _isFlashOn = false;

  // 1. Scanner Controller
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    // 2. Scanning Line Animation (Constrained within the frame)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 20, end: 230).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 3. Real Camera Feed
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !_showResult) {
                // Trigger result when barcode is detected
                setState(() => _showResult = true);
              }
            },
          ),

          // 4. Scanner UI Overlay
          _buildScannerView(),

          // 5. Result Bottom Overlay
          if (_showResult) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),

        // Instruction Pill
        Positioned(
          top: 165,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF6ED940)),
                  SizedBox(width: 10),
                  Text(
                    "Align barcode within the frame",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Animated Scanner Frame (Over the camera)
        Center(
          child: AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: ScannerOverlayPainter(
                    linePosition: _scanAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),

        // Control Buttons
        Positioned(
          bottom: 130,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSmallControlButton(
                icon: _isFlashOn
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
                onTap: () {
                  _scannerController.toggleTorch();
                  setState(() => _isFlashOn = !_isFlashOn);
                },
              ),
              _buildMainScanButton(),
              _buildSmallControlButton(
                icon: Icons.cameraswitch_rounded,
                onTap: () => _scannerController.switchCamera(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFFD2E8E2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: 110, // Padding to avoid overlap with BottomNav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: AppColors.primaryTeal,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lay's Sour Cream & Onion",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C4E4E),
                          ),
                        ),
                        Text(
                          "Potato Chips\nPepsiCo\n170 g",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A6A6A),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/food-scanner-history'),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFF2C4E4E),
                      size: 35,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildSummarySection("Nutrition Summary", "(Per 28g)", [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNutritionTile("Calories", "160 kcal"),
                    _buildNutritionTile("Total Fat", "10 g"),
                    _buildNutritionTile("Sodium", "170 mg"),
                    _buildNutritionTile("Sugar", "1 g"),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              _buildSummarySection("Ingredients", "", [
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    _buildIngredientTag("Potatoes"),
                    _buildIngredientTag(
                      "Vegetable oil (Sunflower, Corn, Canola)",
                    ),
                    _buildIngredientTag("Maltodextrin"),
                    _buildIngredientTag("Salt"),
                    _buildIngredientTag("Sour Cream & Onion Seasoning"),
                    _buildIngredientTag("Sugar"),
                  ],
                ),
              ]),
              const SizedBox(height: 35),
              // Update the Intake button in _buildResultOverlay
              DietPlannerActionButton(
                label: "Intake",
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/calorie-success',
                    arguments: DateTime.now(),
                  );
                },
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => setState(() => _showResult = false),
                child: CustomPaint(
                  painter: DashedBorderPainter(),
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    alignment: Alignment.center,
                    child: const Text(
                      "Ignore and Skip",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A6A6A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    String title,
    String subtitle,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C4E4E),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      " $subtitle",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ),
              const Text(
                "View All",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNutritionTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4E4E),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF2C4E4E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 25, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Column(
        children: [
          Text(
            "Food Scanner",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Scan Barcode To Analyse Packaged Food",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildMainScanButton() {
    return GestureDetector(
      onTap: () => setState(() => _showResult = true),
      child: Container(
        width: 95,
        height: 95,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.sageGreen,
            size: 45,
          ),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double linePosition;
  ScannerOverlayPainter({required this.linePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 40.0;
    const rad = 25.0;

    // Corners
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, rad)
        ..arcToPoint(const Offset(rad, 0), radius: const Radius.circular(rad))
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - rad, 0)
        ..arcToPoint(
          Offset(size.width, rad),
          radius: const Radius.circular(rad),
        )
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - rad)
        ..arcToPoint(Offset(rad, size.height), radius: Radius.circular(rad))
        ..lineTo(len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - rad, size.height)
        ..arcToPoint(
          Offset(size.width, size.height - rad),
          radius: const Radius.circular(rad),
        )
        ..lineTo(size.width, size.height - len),
      paint,
    );

    // Moving Line
    final linePaint = Paint()
      ..color = const Color(0xFF6ED940)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(20, linePosition),
      Offset(size.width - 20, linePosition),
      linePaint,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFF6ED940).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
      Rect.fromLTWH(20, linePosition - 4, size.width - 40, 8),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.linePosition != linePosition;
}
