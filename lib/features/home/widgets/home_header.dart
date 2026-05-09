import 'dart:io'; // Needed for the profile photo file
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app/app_router.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController(); // Access the controller

    // ListenableBuilder makes the header rebuild when the photo changes
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final imageFile = controller.userData['imageFile'];

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                // 1. NAVIGATION LOGIC: Click to go to profile
                onTap: () {
                  // Index 4 is the ProfileScreen in your MainLayout screens list
                  HomeController().setTab(4);
                },
                child: _GlassContainer(
                  borderRadius: BorderRadius.circular(40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // 2. PHOTO LOGIC: Show image if it exists, else show icon
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFE8F2EF),
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile as File)
                            : null,
                        child: imageFile == null
                            ? const Icon(
                                Icons.person,
                                color: Color(0xFF7CB9A8),
                                size: 28,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Welcome Back,",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              controller.userData['name'] ?? "User",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF2C4E4E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // ... (Notification and Crown buttons remain exactly as they were)
            _GlassContainer(
              width: 55,
              height: 55,
              shape: BoxShape.circle,
              child: IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Color(0xFF7CB9A8),
                  size: 26,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.notifications),
              ),
            ),
            const SizedBox(width: 12),
            _GlassContainer(
              width: 55,
              height: 55,
              shape: BoxShape.circle,
              child: IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.premium),
                icon: const FaIcon(
                  FontAwesomeIcons.crown,
                  color: Color(0xFF7CB9A8),
                  size: 22,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Keep your _GlassContainer class at the bottom as it was
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          borderRadius ??
          (shape == BoxShape.circle
              ? BorderRadius.circular(100)
              : BorderRadius.zero),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: borderRadius,
            shape: shape,
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
