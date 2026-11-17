import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/home_hero.dart';

/// "Styled by NUVI" banner, read from the Shopify metaobject `styled_banner`.
class StyledBannerSection extends StatelessWidget {
  final HomeHero banner;
  final VoidCallback onPressed;

  const StyledBannerSection({
    super.key,
    required this.banner,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: Container(
        constraints: const BoxConstraints(minHeight: 176),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [NuviColors.cream, x.peachSoft]),
          borderRadius: BorderRadius.circular(NuviRadii.sheet),
          border: Border.all(color: NuviColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -30,
                    bottom: -40,
                    width: 190,
                    height: 150,
                    child: ClipPath(
                      clipper: const NuviBlobClipper(seed: 4),
                      child: ColoredBox(color: x.peach.withValues(alpha: 0.35)),
                    ),
                  ),
                  NuviImage(url: banner.imageUrl, tile: NuviTile.peach),
                ],
              ),
            ),
            Positioned(
              right: 150,
              top: 26,
              child: Icon(
                Icons.favorite_outline_rounded,
                size: 34,
                color: x.peach,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title,
                          style: x.h2.copyWith(color: NuviColors.leafDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          banner.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: x.nunito(13.5, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  NuviButton(
                    text: banner.buttonText,
                    type: NuviButtonType.leaf,
                    isFullWidth: false,
                    height: 40,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: onPressed,
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
