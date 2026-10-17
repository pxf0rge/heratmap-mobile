import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heratmap/gen/assets.gen.dart';
import 'package:heratmap/l10n/app_translations.dart';
import 'package:heratmap/routes/app_routes.dart';
import 'package:heratmap/theme/app_colors.dart';
import 'package:heratmap/values/dimentions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();

    _navigateTimer = Timer(const Duration(milliseconds: 1800), _goHome);
  }

  Timer? _navigateTimer;

  void _goHome() {
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColors.p900,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.splashGradient),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimentions.radius24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Assets.image.logo.image(width: 52),
                ),
                const SizedBox(height: Dimentions.spaces24),
                Text(
                  AppStrings.appName.tr,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Dimentions.spaces8),
                Text(
                  AppStrings.appTagline.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: Dimentions.spaces48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
