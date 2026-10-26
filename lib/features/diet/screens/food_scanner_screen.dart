import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/failures.dart';
import '../../../core/localization/app_localizations_extension.dart';
import '../../../core/models/scanned_food_product.dart';
import '../../../core/services/nutrition_service.dart';
import '../../../core/services/open_food_facts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/result.dart';
import '../../home/controllers/home_controller.dart';

/// Screen for barcode food scanning using camera and verified Open Food Facts lookup.
class FoodScannerScreen extends StatefulWidget {
  final NutritionService? nutritionService;

  const FoodScannerScreen({super.key, this.nutritionService});

  @override
  State<FoodScannerScreen> createState() => FoodScannerScreenState();
}

class FoodScannerScreenState extends State<FoodScannerScreen>
    with WidgetsBindingObserver {
  late final NutritionService _nutritionService;
  late final MobileScannerController _scannerController;

  DialogRoute<void>? _loadingDialogRoute;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;
  bool _isCameraDeniedOrUnavailable = false;
  String _cameraErrorMessage = '';

  @visibleForTesting
  bool get isProcessing => _isProcessing;

  @visibleForTesting
  bool get isLoadingDialogVisible => _loadingDialogRoute?.isActive ?? false;

  @visibleForTesting
  Future<void> handleBarcode(String barcode) => _handleBarcode(barcode);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nutritionService =
        widget.nutritionService ?? OpenFoodFactsNutritionService();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: _cameraFacing,
      torchEnabled: _isTorchOn,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dismissLoadingDialog();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _scannerController.start();
    }
  }

  void _showLoadingDialog(String barcode) {
    if (!mounted) return;
    _dismissLoadingDialog();

    final themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(context).context,
    );

    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      themes: themes,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  dialogCtx.l10n.foodScannerLookingUpTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dialogCtx.l10n.foodScannerQueryingBarcode(barcode),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _loadingDialogRoute = route;
    Navigator.of(context).push(route);
  }

  void _dismissLoadingDialog() {
    final route = _loadingDialogRoute;
    _loadingDialogRoute = null;

    if (route != null && route.isActive) {
      try {
        if (route.isCurrent) {
          route.navigator?.pop();
        } else {
          route.navigator?.removeRoute(route);
        }
      } catch (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (route.isActive) {
            route.navigator?.removeRoute(route);
          }
        });
      }
    }
  }

  Future<void> _handleBarcode(String rawBarcode) async {
    final barcode = rawBarcode.trim();
    if (barcode.isEmpty || _isProcessing || !mounted) return;

    _isProcessing = true;
    if (mounted) {
      setState(() {});
    }

    // Provide haptic feedback on successful detection
    HapticFeedback.mediumImpact();

    Result<ScannedFoodProduct>? result;
    String? unexpectedError;

    _showLoadingDialog(barcode);

    try {
      result = await _nutritionService
          .lookupBarcode(barcode)
          .timeout(
            const Duration(seconds: 11),
            onTimeout: () => const Result.failure(
              NetworkFailure(
                message:
                    'Nutrition database lookup timed out. Please check your network connection and retry.',
              ),
            ),
          );
    } catch (e) {
      unexpectedError = 'An error occurred during barcode lookup: $e';
    } finally {
      _dismissLoadingDialog();
    }

    if (!mounted) {
      _isProcessing = false;
      return;
    }

    try {
      if (unexpectedError != null) {
        final action = await _showErrorDialog(barcode, unexpectedError);
        if (action == 'manual' && mounted) {
          _showManualEntrySheet();
        }
      } else if (result != null && result.isSuccess) {
        final product = result.dataOrNull!;
        await Navigator.pushNamed(
          context,
          AppRouter.scannedProductResult,
          arguments: product,
        );
      } else {
        final failure = result?.failureOrNull;
        final errorMessage =
            failure?.message ?? 'Failed to retrieve nutrition information.';
        final action = await _showErrorDialog(barcode, errorMessage);
        if (action == 'manual' && mounted) {
          _showManualEntrySheet();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      } else {
        _isProcessing = false;
      }
    }
  }

  Future<String?> _showErrorDialog(String barcode, String message) {
    if (!mounted) return Future.value(null);

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryTeal,
            ),
            const SizedBox(width: 8),
            Text(
              dialogCtx.l10n.foodScannerProductLookup,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 16,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    barcode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx, 'retry');
            },
            child: Text(dialogCtx.l10n.foodScannerScanAgain),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx, 'manual');
            },
            child: Text(dialogCtx.l10n.foodScannerEnterManually),
          ),
        ],
      ),
    );
  }

  void _showManualEntrySheet() {
    if (_isProcessing || !mounted) return;

    final textController = TextEditingController();
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.foodScannerManualButton,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4E4E),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textGrey),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.foodScannerManualSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.foodScannerBarcodeLabel,
                    hintText: context.l10n.foodScannerBarcodeHint,
                    errorText: localError,
                    prefixIcon: const Icon(Icons.qr_code_2_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryTeal,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_isProcessing) return;
                      final input = textController.text.trim();
                      if (input.isEmpty) {
                        setSheetState(() {
                          localError = context.l10n.foodScannerValidationEmpty;
                        });
                        return;
                      }
                      if (input.length < 8) {
                        setSheetState(() {
                          localError = context.l10n.foodScannerValidationMin;
                        });
                        return;
                      }

                      Navigator.pop(sheetCtx);
                      _handleBarcode(input);
                    },
                    child: Text(
                      context.l10n.foodScannerLookUpProduct,
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
        },
      ),
    );
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
      if (mounted) {
        setState(() {
          _cameraFacing = (_cameraFacing == CameraFacing.back)
              ? CameraFacing.front
              : CameraFacing.back;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          HomeController().setTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isCameraDeniedOrUnavailable
                    ? _buildUnavailableFallback(context)
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: (capture) {
                              if (_isProcessing) return;
                              final barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                final rawValue = barcode.rawValue;
                                if (rawValue != null && rawValue.isNotEmpty) {
                                  _handleBarcode(rawValue);
                                  break;
                                }
                              }
                            },
                            errorBuilder: (context, error, child) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_isCameraDeniedOrUnavailable) {
                                  setState(() {
                                    _isCameraDeniedOrUnavailable = true;
                                    _cameraErrorMessage =
                                        error.errorDetails?.message ??
                                        'Camera permission was denied or camera hardware is unavailable on this device.';
                                  });
                                }
                              });
                              return _buildUnavailableFallback(context);
                            },
                          ),
                          _buildScannerOverlay(),
                          _buildControlsRow(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.mintBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
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
                  } else {
                    HomeController().setTab(0);
                  }
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.foodScannerTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.foodScannerSubtitle,
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
          IconButton(
            tooltip: context.l10n.foodScannerManualButton,
            icon: const Icon(
              Icons.keyboard_alt_outlined,
              color: AppColors.primaryTeal,
            ),
            onPressed: _showManualEntrySheet,
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-transparent darkened background
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Reticle frame with corner borders
          Container(
            width: 260,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryTeal.withValues(alpha: 0.8),
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Positioned(
            bottom: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                context.l10n.foodScannerAlignPrompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsRow() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            label: _isTorchOn
                ? context.l10n.foodScannerTorchOff
                : context.l10n.foodScannerTorchOn,
            tooltip: _isTorchOn
                ? context.l10n.foodScannerTorchOff
                : context.l10n.foodScannerTorchOn,
            isActive: _isTorchOn,
            onPressed: _toggleTorch,
          ),
          _buildControlButton(
            icon: Icons.keyboard_alt_rounded,
            label: context.l10n.foodScannerManualCode,
            tooltip: context.l10n.foodScannerManualCode,
            isActive: false,
            onPressed: _showManualEntrySheet,
          ),
          _buildControlButton(
            icon: Icons.flip_camera_ios_rounded,
            label: context.l10n.foodScannerFlipLens,
            tooltip: context.l10n.foodScannerFlipLens,
            isActive: false,
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: isActive
                ? AppColors.primaryTeal
                : Colors.white.withValues(alpha: 0.25),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
            minimumSize: const Size(48, 48),
          ),
          icon: Icon(icon, size: 24),
          onPressed: onPressed,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailableFallback(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFEE2E2),
                ),
                child: const Icon(
                  Icons.videocam_off_rounded,
                  size: 38,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.foodScannerCameraUnavailable,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _cameraErrorMessage.isNotEmpty
                    ? _cameraErrorMessage
                    : context.l10n.foodScannerCameraUnavailableDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_alt_rounded),
                  label: Text(
                    context.l10n.foodScannerManualButton,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _showManualEntrySheet,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: const BorderSide(color: AppColors.primaryTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      HomeController().setTab(0);
                    }
                  },
                  child: Text(
                    context.l10n.foodScannerBackToHome,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
