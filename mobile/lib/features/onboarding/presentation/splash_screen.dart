import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/widgets/nuvi_welcome_backdrop.dart';
import 'onboarding_assets.dart';
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
        backgroundColor: NuviColors.cream,
        body: NuviWelcomeBackdrop(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, c) => Column(
                  children: [
                    SizedBox(height: c.maxHeight * 0.12),
                    Image.asset(
                      kNuviLogoAsset,
                      width: (c.maxWidth * 0.6).clamp(180.0, 260.0),
                      semanticLabel: 'NUVI KIDZ. Tiny styles, big smiles',
                    ),
                    const Spacer(),
                    Image.asset(
                      kOnboardingBackpackAsset,
                      width: (c.maxWidth * 0.78).clamp(240.0, 360.0),
                      excludeFromSemantics: true,
                    ),
                    SizedBox(height: c.maxHeight * 0.08),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
