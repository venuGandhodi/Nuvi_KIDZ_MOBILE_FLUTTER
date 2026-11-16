import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_section_header.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/home_hero.dart';

/// Rounded hero banner (~500pt tall at 390pt wide) with the mascot peeking
/// in, followed by the four-item trust row.
class HeroBannerSection extends StatelessWidget {
  final HomeHero? hero;
  final String? imageUrl;
  final VoidCallback? onShopCollectionPressed;
  final VoidCallback? onSecondaryPressed;

  const HeroBannerSection({
    super.key,
    this.hero,
    this.imageUrl,
    this.onShopCollectionPressed,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final displayImageUrl =
        hero?.imageUrl ??
        imageUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAFpju392Q1xn2AJbOH6i84veMzV8CIixbhDvSfev46-u4_JZayJQIFnXhrHEVwvacS8R3Yqz5xKPu96JKK13KMhQKxFxLkLnJXz9NyUwcIZ4wn0co3f1eqH4Qpm3q-U4Ugpoqku-8t-1F7pb_aL95IXewiYYQ8_64qWmtarZhwe1gnvFEtqcpH2u82uIp_phTTft_zPdY8hPZjpq2y0BYUg1FsGCMEoLThIKZ_Q5E5vMJdLVJRJbMjsQ';

    final title = hero?.title ?? 'Autumn Adventures\nAwait';
    final description =
        hero?.description ??
        'Discover our new collection of cozy, organic cotton essentials designed for little explorers.';
    final buttonText = hero?.buttonText ?? 'Shop the Collection';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = (constraints.maxWidth * 1.4).clamp(380.0, 560.0);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: NuviColors.skyBlue,
                      borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
                      boxShadow: NuviShadows.soft,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NuviImage(
                          url: displayImageUrl,
                          tile: NuviTile.lavender,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.25, 0.72],
                              colors: [
                                NuviColors.nightGreen.withValues(alpha: 0),
                                NuviColors.nightGreen.withValues(alpha: 0.86),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 22,
                          left: 22,
                          child: NuviSparkle(size: 16, color: x.gold),
                        ),
                        Positioned(
                          top: 46,
                          left: 44,
                          child: NuviSparkle(size: 9, color: NuviColors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NuviEyebrow(
                                'New collection',
                                lines: false,
                                color: x.gold,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                style: x.h1.copyWith(
                                  color: NuviColors.white,
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: x.nunito(
                                  14,
                                  color: NuviColors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                ),
                              ),
                              const SizedBox(height: NuviSpacing.md),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  NuviButton(
                                    text: buttonText,
                                    isFullWidth: false,
                                    onPressed: onShopCollectionPressed,
                                  ),
                                  if (onSecondaryPressed != null)
                                    _GhostButton(
                                      text: 'Top picks',
                                      onPressed: onSecondaryPressed!,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: -18,
                    right: 6,
                    child: NuviMascot(size: 76),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: NuviSpacing.md),
        const _TrustRow(),
      ],
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GhostButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: NuviSpacing.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NuviRadii.pill),
            border: Border.all(color: NuviColors.white, width: 1.5),
            color: NuviColors.white.withValues(alpha: 0.12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, style: x.button.copyWith(color: NuviColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  static const _items = [
    (Icons.local_shipping_outlined, 'Free\nShipping'),
    (Icons.autorenew_rounded, 'Easy\nReturns'),
    (Icons.lock_outline_rounded, 'Secure\nPayments'),
    (Icons.workspace_premium_outlined, 'Assured\nQuality'),
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: NuviColors.card,
          borderRadius: BorderRadius.circular(NuviRadii.card),
          border: Border.all(color: NuviColors.line),
        ),
        child: Row(
          children: [
            for (final (icon, label) in _items)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: x.goldSoft,
                      ),
                      child: Icon(icon, size: 19, color: NuviColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: x.nunito(11, weight: FontWeight.w700, height: 1.2),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
