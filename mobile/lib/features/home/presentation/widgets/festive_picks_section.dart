import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../../category/domain/menu_category.dart';
import '../../domain/promo_content.dart';

/// "Festive Picks": banner from the Shopify metaobject `festive_banner` and a
/// row of category circles from the Shopify menu `festive-picks`. Each part
/// hides itself when the store hasn't set it up.
class FestivePicksSection extends StatelessWidget {
  final PromoBanner? banner;
  final List<MenuCategory> categories;
  final ValueChanged<String> onCollectionTap;

  const FestivePicksSection({
    super.key,
    required this.banner,
    required this.categories,
    required this.onCollectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = banner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (b != null)
          _FestiveBanner(
            banner: b,
            onPressed: () => onCollectionTap(b.collectionHandle),
          ),
        if (b != null && categories.isNotEmpty)
          const SizedBox(height: NuviSpacing.md),
        if (categories.isNotEmpty)
          _FestiveCategoryRow(
            categories: categories,
            onTap: (c) => onCollectionTap(c.collectionHandle ?? c.id),
          ),
      ],
    );
  }
}

/// Serif display style shared by the Festive Picks and Deal Zone titles.
TextStyle promoTitleStyle(double size) => TextStyle(
  fontFamily: NuviTypography.bagFont,
  fontSize: size,
  fontWeight: FontWeight.w600,
  height: 1.02,
  color: NuviColors.leafDark,
);

class _FestiveBanner extends StatelessWidget {
  final PromoBanner banner;
  final VoidCallback onPressed;

  const _FestiveBanner({required this.banner, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = (w * 0.7).clamp(256.0, 310.0);
          return Container(
            height: h,
            decoration: BoxDecoration(
              color: x.goldSoft,
              borderRadius: BorderRadius.circular(NuviRadii.sheet),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: NuviImage(
                    url: banner.imageUrl,
                    tile: NuviTile.gold,
                    alignment: Alignment.centerRight,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          NuviColors.cream.withValues(alpha: 0.96),
                          NuviColors.cream.withValues(alpha: 0.8),
                          NuviColors.cream.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.42, 0.66],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 20,
                  child: _Lantern(stringLength: 26),
                ),
                const Positioned(
                  top: 0,
                  left: 44,
                  child: _Lantern(stringLength: 14),
                ),
                Positioned(top: 46, left: w * 0.38, child: const _LeafPair()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 58, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: w * 0.5,
                        child: Text(
                          banner.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: promoTitleStyle(32),
                        ),
                      ),
                      if (banner.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: w * 0.48,
                          child: Text(
                            banner.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: x.nunito(13.5, height: 1.35),
                          ),
                        ),
                      ],
                      const Spacer(),
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
          );
        },
      ),
    );
  }
}

class _FestiveCategoryRow extends StatelessWidget {
  final List<MenuCategory> categories;
  final ValueChanged<MenuCategory> onTap;

  const _FestiveCategoryRow({required this.categories, required this.onTap});

  static const _tints = [
    NuviColors.saleSoft,
    NuviColors.goldSoft,
    NuviColors.peachSoft,
    NuviColors.sageSoft,
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Six cells fill the row exactly; any extra scroll in. Labels use
        // the full cell width, circles leave a small gap between them.
        final cell = ((constraints.maxWidth - NuviSpacing.gutter * 2) / 6)
            .clamp(58.0, 92.0);
        final d = cell - 8;
        return SizedBox(
          height: d + 40 * scale,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemExtent: cell,
            itemBuilder: (context, index) {
              final c = categories[index];
              return NuviPressable(
                onTap: () => onTap(c),
                semanticLabel: 'Shop ${c.title}',
                child: Column(
                  children: [
                    Container(
                      width: d,
                      height: d,
                      decoration: BoxDecoration(
                        color: _tints[index % _tints.length],
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NuviImage(url: c.imageUrl, tile: NuviTile.peach),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: x.nunito(
                        10.5,
                        weight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Two small leaves (sage + peach) used as a flourish beside promo titles.
class _LeafPair extends StatelessWidget {
  const _LeafPair();

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return SizedBox(
      width: 30,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: NuviLeaf(size: 16, color: x.leaf, angle: -1.2),
          ),
          Positioned(
            left: 10,
            top: 6,
            child: NuviLeaf(size: 18, color: x.peach, angle: -0.6),
          ),
        ],
      ),
    );
  }
}

/// Hanging festive lantern.
class _Lantern extends StatelessWidget {
  final double stringLength;

  const _Lantern({required this.stringLength});

  static const _svg =
      '<svg viewBox="0 0 20 30"><path d="M6 0h8l1.5 3h-11z" fill="#C99520"/>'
      '<path d="M4.5 3h11l2.5 6-2.5 13h-11L2 9z" fill="#EAB83D" '
      'stroke="#B7860B" stroke-width="0.8" stroke-linejoin="round"/>'
      '<path d="M8 6h4v13H8z" fill="#FCEFCB" opacity="0.85"/>'
      '<path d="M6 22h8l-1.2 3H7.2z" fill="#C99520"/>'
      '<circle cx="10" cy="27.5" r="1.6" fill="#C99520"/></svg>';

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Column(
      children: [
        Container(width: 1, height: stringLength, color: NuviColors.amber),
        SvgPicture.string(_svg, width: 18, height: 27),
      ],
    ),
  );
}

/// Exposed for the Deal Zone banner so both titles share the flourish.
class PromoLeafPair extends StatelessWidget {
  const PromoLeafPair({super.key});

  @override
  Widget build(BuildContext context) => const _LeafPair();
}
