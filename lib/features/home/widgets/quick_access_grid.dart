import 'package:flutter/material.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionData(
        icon: Icons.description_outlined,
        label: 'Records',
        onTap: () => Navigator.pushNamed(context, AppRouter.records),
      ),
      _ActionData(
        icon: Icons.calendar_month_outlined,
        label: 'Visits',
        onTap: () => Navigator.pushNamed(context, AppRouter.visits),
      ),
      _ActionData(
        icon: Icons.access_time_rounded,
        label: 'Routine',
        onTap: () => Navigator.pushNamed(context, AppRouter.routine),
      ),
      _ActionData(
        icon: Icons.restaurant_outlined,
        label: 'Diet Section',
        onTap: () => Navigator.pushNamed(context, AppRouter.diet),
      ),
      _ActionData(
        icon: Icons.health_and_safety_outlined,
        label: 'Access',
        onTap: () => Navigator.pushNamed(context, AppRouter.access),
      ),
      _ActionData(
        icon: Icons.family_restroom_outlined,
        label: 'Family',
        onTap: () => Navigator.pushNamed(context, AppRouter.familyProfiles),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderTeal.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: QuickAccessItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    onTap: items[i].onTap,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 3; i < 6; i++) ...[
                if (i > 3) const SizedBox(width: 8),
                Expanded(
                  child: QuickAccessItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    onTap: items[i].onTap,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class QuickAccessItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickAccessItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<QuickAccessItem> createState() => _QuickAccessItemState();
}

class _QuickAccessItemState extends State<QuickAccessItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            constraints: const BoxConstraints(minHeight: 86),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.sageGreen,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sageGreen.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: AppColors.primaryTeal,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
