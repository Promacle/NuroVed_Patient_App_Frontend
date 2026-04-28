import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonWrapper extends StatefulWidget {
  final Widget child;
  const SkeletonWrapper({super.key, required this.child});

  @override
  State<SkeletonWrapper> createState() => _SkeletonWrapperState();
}

class _SkeletonWrapperState extends State<SkeletonWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _isLoading ? _buildShimmerUI() : widget.child,
    );
  }

  Widget _buildShimmerUI() {
    return Scaffold(
      backgroundColor: AppColors.kMainBg,
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Header Skeleton
              Container(
                height: 300,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                ),
              ),
              // Content Skeletons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      height: 100,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
}
