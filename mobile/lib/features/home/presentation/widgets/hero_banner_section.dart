import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/home_hero.dart';

/// Rounded hero card showing the Shopify hero image full-width (the image
/// carries its own artwork and wording) with a leaf-green CTA on top. The
/// whole card is tappable.
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
    final displayImageUrl =
        hero?.imageUrl ??
        imageUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAFpju392Q1xn2AJbOH6i84veMzV8CIixbhDvSfev46-u4_JZayJQIFnXhrHEVwvacS8R3Yqz5xKPu96JKK13KMhQKxFxLkLnJXz9NyUwcIZ4wn0co3f1eqH4Qpm3q-U4Ugpoqku-8t-1F7pb_aL95IXewiYYQ8_64qWmtarZhwe1gnvFEtqcpH2u82uIp_phTTft_zPdY8hPZjpq2y0BYUg1FsGCMEoLThIKZ_Q5E5vMJdLVJRJbMjsQ';
    final buttonText = hero?.buttonText ?? 'Shop the Collection';
    final title = hero?.title.replaceAll('\n', ' ').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: NuviPressable(
        onTap: onShopCollectionPressed,
        semanticLabel: title == null || title.isEmpty ? buttonText : title,
        child: Container(
          decoration: BoxDecoration(
            color: NuviColors.peachSoft,
            borderRadius: BorderRadius.circular(NuviRadii.sheet),
            boxShadow: NuviShadows.soft,
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              children: [
                Positioned.fill(
                  child: NuviImage(url: displayImageUrl, tile: NuviTile.peach),
                ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: NuviButton(
                    text: buttonText,
                    type: NuviButtonType.leaf,
                    isFullWidth: false,
                    height: 42,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: onShopCollectionPressed,
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
