import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/home_hero.dart';

/// Rounded hero card: photo on the right, cream wash on the left carrying the
/// title, description and a leaf-green CTA, with a leaf sprig in the corner.
class HeroBannerSection extends StatelessWidget {
  final HomeHero? hero;
  final String? imageUrl;
  final VoidCallback? onShopCollectionPressed;

  const HeroBannerSection({
    super.key,
    this.hero,
    this.imageUrl,
    this.onShopCollectionPressed,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: Container(
        constraints: const BoxConstraints(minHeight: 236),
        decoration: BoxDecoration(
          color: NuviColors.peachSoft,
          borderRadius: BorderRadius.circular(NuviRadii.sheet),
          boxShadow: NuviShadows.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.62,
                  heightFactor: 1,
                  child: NuviImage(url: displayImageUrl, tile: NuviTile.peach),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.42, 0.62],
                    colors: [
                      NuviColors.cream,
                      NuviColors.cream.withValues(alpha: 0.92),
                      NuviColors.cream.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -6,
              left: -4,
              child: NuviLeaf(size: 46, color: x.sage, angle: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 34, 0, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.58,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: x.h1.copyWith(
                            color: NuviColors.leafDark,
                            fontSize: 27,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: x.nunito(
                            13.5,
                            weight: FontWeight.w600,
                            color: NuviColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  NuviButton(
                    text: buttonText,
                    type: NuviButtonType.leaf,
                    isFullWidth: false,
                    height: 42,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: onShopCollectionPressed,
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
