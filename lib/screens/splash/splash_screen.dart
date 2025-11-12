import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // ✅ Start animation
    _animationController.forward();

    // ✅ Navigate after splash
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for animation + slight delay
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // ✅ Navigate to home (MQTT will connect there)
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF29B6F6),
      body: Stack(
        children: [
          // ✅ Logo & Text (Centered with offset up)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Push content up
                    const SizedBox(
                        height: 0), // Adjust this for more/less space

                    // Logo
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => const Icon(
                          Icons.eco,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Loading Indicator (Absolute bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 80, // Distance from bottom
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
