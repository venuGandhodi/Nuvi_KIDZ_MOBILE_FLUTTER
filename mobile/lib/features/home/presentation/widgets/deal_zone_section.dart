import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/promo_content.dart';
import 'festive_picks_section.dart';

/// "Deal Zone": banner from the Shopify metaobject `deal_banner` and up to
/// three offer tiles from metaobjects of type `deal_tile`. Each part hides
/// itself when the store hasn't set it up.
class DealZoneSection extends StatelessWidget {
  final PromoBanner? banner;
  final List<DealTile> tiles;
  final ValueChanged<String> onCollectionTap;

  const DealZoneSection({
    super.key,
    required this.banner,
    required this.tiles,
    required this.onCollectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = banner;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (b != null)
            _DealBanner(
              banner: b,
              onPressed: () => onCollectionTap(b.collectionHandle),
            ),
          if (b != null && tiles.isNotEmpty)
            const SizedBox(height: NuviSpacing.s12),
          if (tiles.isNotEmpty)
            _DealTiles(
              tiles: tiles.take(3).toList(),
              onTap: (t) => onCollectionTap(t.collectionHandle),
            ),
        ],
      ),
    );
  }
}

class _DealBanner extends StatelessWidget {
  final PromoBanner banner;
  final VoidCallback onPressed;

  const _DealBanner({required this.banner, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = (w * 0.52).clamp(188.0, 250.0);
        return Container(
          height: h,
          decoration: BoxDecoration(
            color: NuviColors.peachSoft,
            borderRadius: BorderRadius.circular(NuviRadii.sheet),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // The Shopify image fills the whole banner with its own
              // background; a soft shade on the left keeps the text legible.
              Positioned.fill(
                child: NuviImage(
                  url: banner.imageUrl,
                  tile: NuviTile.peach,
                  alignment: Alignment.centerRight,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NuviColors.nightGreen.withValues(alpha: 0.5),
                        NuviColors.nightGreen.withValues(alpha: 0.22),
                        NuviColors.nightGreen.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.38, 0.62],
                    ),
                  ),
                ),
              ),
              if (banner.badgeText != null)
                Positioned(
                  right: 14,
                  bottom: 16,
                  child: _OfferTag(text: banner.badgeText!),
                ),
              Positioned(top: 18, left: w * 0.42, child: const PromoLeafPair()),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 34, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: w * 0.56,
                      child: Row(
                        children: [
                          Transform.rotate(
                            angle: -0.5,
                            child: const Icon(
                              Icons.local_offer_rounded,
                              size: 26,
                              color: NuviColors.sale,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              banner.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: promoTitleStyle(
                                30,
                              ).copyWith(color: NuviColors.cream),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (banner.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: w * 0.54,
                        child: Text(
                          banner.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: x.nunito(
                            13.5,
                            weight: FontWeight.w600,
                            height: 1.35,
                            color: NuviColors.cream,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    NuviButton(
                      text: banner.buttonText,
                      type: NuviButtonType.coral,
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
    );
  }
}

/// Cream price tag, slightly tilted, e.g. "Up to / 40% OFF".
class _OfferTag extends StatelessWidget {
  final String text;

  const _OfferTag({required this.text});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final (lead, main) = DealTile(
      title: '',
      offerText: text,
      collectionHandle: '',
    ).offerLines;
    return Transform.rotate(
      angle: -0.28,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: BoxDecoration(
          color: NuviTone.cream.tint,
          borderRadius: BorderRadius.circular(NuviRadii.small),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2478461E),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: NuviColors.amber, width: 1.2),
              ),
            ),
            if (lead != null)
              Text(
                lead,
                style: x.baloo(
                  13,
                  weight: FontWeight.w700,
                  color: NuviBagColors.coral,
                ),
              ),
            Text(
              main,
              textAlign: TextAlign.center,
              style: x
                  .baloo(
                    22,
                    weight: FontWeight.w800,
                    color: NuviBagColors.coral,
                  )
                  .copyWith(height: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealTiles extends StatelessWidget {
  final List<DealTile> tiles;
  final ValueChanged<DealTile> onTap;

  const _DealTiles({required this.tiles, required this.onTap});

  static const _tints = [NuviTile.sage, NuviTile.rose, NuviTile.gold];
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - _gap * 2) / 3;
        return SizedBox(
          height: w * 1.12 + 36 * scale,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                SizedBox(
                  width: w,
                  child: i < tiles.length
                      ? _DealTileCard(
                          tile: tiles[i],
                          tint: _tints[i],
                          onTap: () => onTap(tiles[i]),
                        )
                      : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DealTileCard extends StatelessWidget {
  final DealTile tile;
  final NuviTile tint;
  final VoidCallback onTap;

  const _DealTileCard({
    required this.tile,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final (lead, main) = tile.offerLines;
    final colors = NuviGradients.colors(tint);
    return NuviPressable(
      onTap: onTap,
      semanticLabel: '${tile.offerText} on ${tile.title}',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NuviImage(
                    url: tile.imageUrl,
                    tile: tint,
                    alignment: Alignment.topCenter,
                  ),
                  if (tile.offerText.isNotEmpty)
                    Positioned(
                      left: 6,
                      right: 14,
                      bottom: 6,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 3, 10, 4),
                            decoration: BoxDecoration(
                              color: NuviColors.cream.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (lead != null)
                                    Text(
                                      lead,
                                      style: x
                                          .baloo(
                                            11,
                                            weight: FontWeight.w700,
                                            color: NuviBagColors.coral,
                                          )
                                          .copyWith(height: 1.1),
                                    ),
                                  Text(
                                    main,
                                    style: x
                                        .baloo(
                                          17,
                                          weight: FontWeight.w800,
                                          color: NuviBagColors.coral,
                                        )
                                        .copyWith(height: 1.05),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: colors.first.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      tile.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: x.nunito(13, weight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: NuviColors.ink,
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
