import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../../core/widgets/nuvi_welcome_backdrop.dart';
import '../data/onboarding_storage.dart';
import 'onboarding_assets.dart';

/// Three intro pages (Discover, Shop & Explore, Our Aim) ending at sign in.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 3;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Onboarding is shown once; afterwards the shopper lands on Get Started
  /// (sign in), where they can also continue as a guest.
  Future<void> _completeOnboarding() async {
    await ref.read(onboardingStorageProvider).setCompletedOnboarding(true);
    if (!mounted) return;
    context.go('/sign-in');
  }

  void _next() {
    if (_currentPage < _pageCount - 1) {
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
    final x = context.nuvi;
    return Scaffold(
      backgroundColor: NuviColors.cream,
      body: NuviWelcomeBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 12, 0),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: x.nunito(14, weight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    _IntroPage(
                      art: _KidsArt(),
                      icon: Icons.shopping_bag_outlined,
                      iconColor: NuviBagColors.coral,
                      iconTint: NuviColors.peachSoft,
                      title: 'Discover\nAdorable Styles',
                      body:
                          'Thoughtfully designed, comfortable and stylish '
                          'outfits for little ones.',
                    ),
                    _IntroPage(
                      art: _MascotArt(asset: kOnboardingGiftAsset),
                      icon: Icons.shopping_cart_outlined,
                      iconColor: NuviColors.leafDark,
                      iconTint: NuviColors.sageSoft,
                      title: 'Shop & Explore\nwith Ease',
                      body:
                          'Find the perfect outfits, new collections and '
                          'special deals all in one place.',
                    ),
                    _OurAimPage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 24, 24),
                child: Row(
                  children: [
                    const Spacer(),
                    _Dots(count: _pageCount, current: _currentPage),
                    const Expanded(child: SizedBox()),
                    NuviPressable(
                      onTap: _next,
                      semanticLabel: _currentPage == _pageCount - 1
                          ? 'Get started'
                          : 'Next',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: x.leaf,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3341522C),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: NuviColors.cream,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: i == current
                  ? context.nuvi.leaf
                  : NuviColors.sage.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

/// Picture, round icon badge, title and body.
class _IntroPage extends StatelessWidget {
  final Widget art;
  final IconData icon;
  final Color iconColor;
  final Color iconTint;
  final String title;
  final String body;

  const _IntroPage({
    required this.art,
    required this.icon,
    required this.iconColor,
    required this.iconTint,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            children: [
              SizedBox(height: c.maxHeight * 0.48, child: art),
              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconTint,
                    shape: BoxShape.circle,
                    border: Border.all(color: NuviColors.cream, width: 4),
                  ),
                  child: Icon(icon, size: 30, color: iconColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: x
                          .baloo(
                            30,
                            weight: FontWeight.w800,
                            color: NuviColors.nightGreen,
                          )
                          .copyWith(height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: x.nunito(15, color: NuviColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kids photo with a soft wavy bottom edge and floating hearts.
class _KidsArt extends StatelessWidget {
  const _KidsArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: const NuviWaveClipper(depth: 14, waves: 2),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0, 0.82, 1],
            ).createShader(r),
            child: Image.asset(
              kOnboardingKidsAsset,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              excludeFromSemantics: true,
            ),
          ),
        ),
        const Positioned(top: 18, right: 34, child: _Heart(size: 26)),
      ],
    );
  }
}

/// A mascot standing on a soft round glow, with hearts.
class _MascotArt extends StatelessWidget {
  final String asset;

  const _MascotArt({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FractionallySizedBox(
          widthFactor: 0.82,
          heightFactor: 0.82,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  NuviColors.white.withValues(alpha: 0.85),
                  NuviColors.cream.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Image.asset(asset, excludeFromSemantics: true),
        ),
        const Positioned(top: 12, right: 44, child: _Heart(size: 26)),
        const Positioned(top: 34, right: 26, child: _Heart(size: 20)),
      ],
    );
  }
}

class _Heart extends StatelessWidget {
  final double size;

  const _Heart({required this.size});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Transform.rotate(
      angle: 0.2,
      child: Icon(
        Icons.favorite_border_rounded,
        size: size,
        color: NuviColors.peach,
      ),
    ),
  );
}

/// "Our Aim": mission statement and four brand promises.
class _OurAimPage extends StatelessWidget {
  const _OurAimPage();

  static const _promises = [
    (Icons.eco_outlined, 'Safe &\nSkin-Friendly'),
    (Icons.diamond_outlined, 'Premium\nQuality'),
    (Icons.favorite_border_rounded, 'Comfort\nFirst'),
    (Icons.groups_outlined, 'For Every\nLittle Milestone'),
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: NuviSpacing.lg),
          const Icon(
            Icons.track_changes_rounded,
            size: 64,
            color: NuviBagColors.coral,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Our Aim',
                style: x.baloo(
                  32,
                  weight: FontWeight.w800,
                  color: NuviColors.nightGreen,
                ),
              ),
              const SizedBox(width: 10),
              const _Heart(size: 26),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To make childhood more joyful with high-quality, comfortable and '
            'stylish essentials — while being a trusted companion for modern '
            'parents.',
            textAlign: TextAlign.center,
            style: x.nunito(15, color: NuviColors.inkMuted, height: 1.5),
          ),
          const SizedBox(height: NuviSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              for (final (icon, label) in _promises)
                Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: NuviColors.peachSoft,
                        borderRadius: BorderRadius.circular(NuviRadii.pill),
                      ),
                      child: Icon(icon, size: 30, color: NuviBagColors.coral),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: x.nunito(
                        13,
                        weight: FontWeight.w600,
                        color: NuviColors.nightGreen,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
