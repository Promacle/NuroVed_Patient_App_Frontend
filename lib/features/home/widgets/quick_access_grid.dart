import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuroved_patient/app/app_router.dart'; // Import router

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EF), // Updated to light mint

        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickAccessItem(
            icon: FontAwesomeIcons.hospitalUser,
            label: 'Access',
            onTap: () => Navigator.pushNamed(context, AppRouter.access),
          ),
          QuickAccessItem(
            icon: FontAwesomeIcons.appleWhole,
            label: 'Diet Section',
            onTap: () => Navigator.pushNamed(context, AppRouter.diet),
          ),
          QuickAccessItem(
            icon: FontAwesomeIcons.clock,
            label: 'Routine',
            onTap: () => Navigator.pushNamed(context, AppRouter.routine),
          ),
        ],
      ),
    );
  }
}

class QuickAccessItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap; // Add onTap callback

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
  late Animation<double> _blurAnimation;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() => setState(() {}));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _blurAnimation = Tween<double>(begin: 12.0, end: 4.0).animate(_controller);
    _offsetAnimation = Tween<double>(begin: 6.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: 95,
          height: 105,
          decoration: BoxDecoration(
            color: const Color(0xFF7CB9A8), // Teal card background
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7CB9A8).withOpacity(0.4),
                blurRadius: _blurAnimation.value,
                offset: Offset(0, _offsetAnimation.value),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    widget.icon,
                    color: const Color(0xFF7CB9A8),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white, // Label text is now white
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
