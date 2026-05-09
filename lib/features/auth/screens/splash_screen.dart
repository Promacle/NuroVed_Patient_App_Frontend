import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/launcher_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF427D72), Color(0xFFF1F6F5)],
          ),
        ),
        child: Stack(
          children: [
            // Doctor Image - Scaled up and positioned to start below the text
            Positioned(
              top: MediaQuery.of(context).size.height * 0.26,
              bottom: -650,
              left: 0,
              right: 0,
              child: Image.asset(
                AppAssets.doctorPatient,
                fit: BoxFit.cover, // Makes the image "Big and Close"
                alignment: const Alignment(
                  0,
                  -0.6,
                ), // Focuses on the face/upper body
              ),
            ),

            // White gradient fade at the very bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.4),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Title and Subtitle on the clear teal background
                  const Text(
                    "NuroVed Your\nHealth, Your Control",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "We believe healthcare needs consistent attention, that's why we're here for you",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(), // Pushes buttons to overlay on the doctor image
                  // Action Buttons overlayed on the image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            "Signup",
                            () =>
                                Navigator.pushNamed(context, AppRouter.signup),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildActionButton(
                            "Login",
                            () => Navigator.pushNamed(context, AppRouter.login),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer text at the bottom
                  _buildFooterText(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF769E93),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF769E93),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF2C4E4E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          children: [
            const TextSpan(text: "Before continuing read all the "),
            TextSpan(
              text: "terms of\nservice",
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Color(0xFF5D2E2E),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    LauncherUtils.launchURL('https://google.com/terms'),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "privacy policy",
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Color(0xFF5D2E2E),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    LauncherUtils.launchURL('https://google.com/privacy'),
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
    );
  }
}
