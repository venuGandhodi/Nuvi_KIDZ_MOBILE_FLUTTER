import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../data/onboarding_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Automatically navigate after 1.8 seconds
    _timer = Timer(const Duration(milliseconds: 1800), _proceedToNextScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _proceedToNextScreen() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timer?.cancel();

    final storage = ref.read(onboardingStorageProvider);
    final hasCompleted = await storage.hasCompletedOnboarding();

    if (!mounted) return;
    if (hasCompleted) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _proceedToNextScreen,
      child: Scaffold(
        backgroundColor: NuviColors.primary,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Center content
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/brand/nuvi_elephant_mascot.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.favorite,
                                size: 80,
                                color: NuviColors.accent,
                              ),
                        ),
                        const SizedBox(height: NuviSpacing.lg),
                        Text(
                          'Tiny styles, big smiles ♡',
                          style: NuviTypography.textTheme.headlineMedium
                              ?.copyWith(
                                color: const Color(0xFFF6EAD8),
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom prompt
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: NuviSpacing.xxl,
                  child: Center(
                    child: Text(
                      'Tap to continue',
                      style: NuviTypography.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
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
