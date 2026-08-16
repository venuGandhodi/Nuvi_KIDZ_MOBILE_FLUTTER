import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../data/onboarding_storage.dart';

class OnboardingPageData {
  final String scriptTagline;
  final String headline;
  final String subtitle;
  final String imagePath;
  final double imageSize;

  const OnboardingPageData({
    required this.scriptTagline,
    required this.headline,
    required this.subtitle,
    required this.imagePath,
    this.imageSize = 160.0,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      scriptTagline: 'Welcome to the universe',
      headline: 'Every festival is brighter in little celebrations.',
      subtitle:
          'Ethnic wear, everyday sets, footwear and accessories for 0–8 years.',
      imagePath: 'assets/images/brand/nuvi_elephant_mascot.png',
      imageSize: 150.0,
    ),
    OnboardingPageData(
      scriptTagline: 'Tiny styles, big smiles',
      headline: 'Thoughtfully selected styles for every little moment.',
      subtitle: 'Comfortable fabrics crafted with love for playful days.',
      imagePath: 'assets/images/brand/nuvi_elephant_mascot.png',
      imageSize: 150.0,
    ),
    OnboardingPageData(
      scriptTagline: 'Made for little memories',
      headline:
          'Discover outfits made for festivals, playtime and everyday joy.',
      subtitle: 'Premium quality and timeless charm for 0–8 years.',
      imagePath: 'assets/images/brand/nuvi_kidz_logo.png',
      imageSize: 200.0,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final storage = ref.read(onboardingStorageProvider);
    await storage.setCompletedOnboarding(true);
    if (!mounted) return;
    context.go('/home');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFDFBF7);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NuviSpacing.lg,
                vertical: NuviSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: NuviColors.primary,
                      textStyle: NuviTypography.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NuviSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: NuviSpacing.xxl),

                        // Image Graphic
                        Image.asset(
                          page.imagePath,
                          width: page.imageSize,
                          height: page.imageSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.favorite,
                                size: 80,
                                color: NuviColors.primary,
                              ),
                        ),
                        const SizedBox(height: NuviSpacing.xxl),

                        // Script Tagline
                        Text(
                          page.scriptTagline,
                          style: NuviTypography.textTheme.headlineSmall
                              ?.copyWith(
                                color: const Color(0xFFB85D43),
                                fontFamily: 'Quicksand',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: NuviSpacing.md),

                        // Bold Headline
                        Text(
                          page.headline,
                          style: NuviTypography.textTheme.displayMedium
                              ?.copyWith(
                                color: NuviColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                height: 1.3,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: NuviSpacing.md),

                        // Subtitle Body Text
                        Text(
                          page.subtitle,
                          style: NuviTypography.textTheme.bodyMedium?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.65),
                            fontSize: 15,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFFD49B35)
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                ),
              ),
            ),
            const SizedBox(height: NuviSpacing.xl),

            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NuviSpacing.xl,
                vertical: NuviSpacing.md,
              ),
              child: isLastPage
                  ? SizedBox(
                      width: double.infinity,
                      child: NuviButton(
                        text: 'GET STARTED',
                        type: NuviButtonType.primary,
                        onPressed: _completeOnboarding,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: NuviButton(
                        text: 'NEXT',
                        type: NuviButtonType.primary,
                        onPressed: _nextPage,
                      ),
                    ),
            ),
            const SizedBox(height: NuviSpacing.md),
          ],
        ),
      ),
    );
  }
}
