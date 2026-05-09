import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _whiteScreenFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 1. Scale Sequence (Scale up -> stay -> scale down)
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.0,
              end: 1.8,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 35,
          ),
          TweenSequenceItem(tween: ConstantTween<double>(1.8), weight: 10),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.8,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOutCubic)),
            weight: 35,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.60),
          ),
        );

    // 2. Rotation Sequence (Rotate 180 -> Rotate back)
    _rotationAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0,
              end: math.pi,
            ).chain(CurveTween(curve: Curves.easeInOutCubic)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: math.pi,
              end: 0,
            ).chain(CurveTween(curve: Curves.easeInOutCubic)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.10, 0.60),
          ),
        );

    // 3. Background Transition (Teal to White)
    _whiteScreenFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeIn),
      ),
    );

    // 4. Text Reveal Logic
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.95, curve: Curves.easeOut),
      ),
    );

    // Navigation Logic
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, AppRouter.splash);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      body: Stack(
        children: [
          // White background fade-in
          FadeTransition(
            opacity: _whiteScreenFade,
            child: Container(color: Colors.white),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:
                      MainAxisSize.min, // Vital for centering the group
                  children: [
                    // LOGO CONTAINER
                    Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: _whiteScreenFade.value > 0.6
                                ? null
                                : [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            AppAssets.appLogo,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                    ),

                    // TEXT REVEAL
                    if (_controller.value > 0.65) ...[
                      // Dynamic gap that pushes the text out smoothly
                      SizedBox(width: 15 * _textOpacityAnimation.value),

                      Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: const Text(
                          'NuroVed',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
