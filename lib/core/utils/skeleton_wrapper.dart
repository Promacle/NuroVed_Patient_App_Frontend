import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonWrapper extends StatefulWidget {
  final Widget child;
  final Future<void>? waitTask;
  const SkeletonWrapper({super.key, required this.child, this.waitTask});

  @override
  State<SkeletonWrapper> createState() => _SkeletonWrapperState();
}

class _SkeletonWrapperState extends State<SkeletonWrapper> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    // If a task is provided, start in 'not loading' to see if it finishes during the grace period.
    // If no task is provided, we show loading immediately for a quick transition.
    _isLoading = widget.waitTask == null;
    _load();
  }

  void _load() async {
    if (widget.waitTask != null) {
      bool isTaskDone = false;
      widget.waitTask!.then((_) => isTaskDone = true);

      // Grace period: Wait 150ms. If the task finishes, we skip the shimmer entirely.
      await Future.delayed(const Duration(milliseconds: 150));

      if (isTaskDone) {
        // Fast connection: No shimmer needed.
        if (mounted) setState(() => _isLoading = false);
      } else {
        // Slow connection: Show shimmer until the task completes.
        if (mounted) setState(() => _isLoading = true);
        await widget.waitTask;
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // General navigation transition: Reduced delay from 1300ms to 500ms for a snappier feel.
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
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
