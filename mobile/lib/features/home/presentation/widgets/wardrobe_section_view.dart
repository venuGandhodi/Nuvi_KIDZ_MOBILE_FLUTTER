import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/wardrobe.dart';

/// One wardrobe block: "Girl's Wardrobe" categories (product cut-outs, 2×2)
/// on the left and "Top Picks Up To 70% Off" photo cards (2×2) on the
/// right. Either side hides itself when it has no tiles.
class WardrobeSectionView extends StatelessWidget {
  final WardrobeSection section;
  final ValueChanged<String> onCollectionTap;

  const WardrobeSectionView({
    super.key,
    required this.section,
    required this.onCollectionTap,
  });

  static const double _columnGap = 12;

  /// Tap handler, or null when the tile has no collection set.
  VoidCallback? _tap(WardrobeTile t) {
    final handle = t.collectionHandle;
    return handle == null ? null : () => onCollectionTap(handle);
  }

  static const double _tileGap = 8;

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final hasLeft = section.categories.isNotEmpty;
    final hasRight = section.topPicks.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sides = (hasLeft ? 1 : 0) + (hasRight ? 1 : 0);
          final sideWidth =
              (constraints.maxWidth - (sides > 1 ? _columnGap : 0)) / sides;
          final tile = (sideWidth - _tileGap) / 2;
          final headingStyle = x.baloo(
            18,
            weight: FontWeight.w700,
            color: NuviColors.nightGreen,
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLeft)
                SizedBox(
                  width: sideWidth,
                  child: Column(
                    children: [
                      _Heading(child: Text(section.title, style: headingStyle)),
                      _Grid(
                        tiles: section.categories,
                        builder: (t, i) => _CategoryTile(
                          tile: t,
                          size: tile,
                          sparkle: i.isOdd,
                          onTap: _tap(t),
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasLeft && hasRight) const SizedBox(width: _columnGap),
              if (hasRight)
                SizedBox(
                  width: sideWidth,
                  child: Column(
                    children: [
                      _Heading(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: section.picksTitle),
                              if (section.picksHighlight.isNotEmpty)
                                TextSpan(
                                  text: ' ${section.picksHighlight}',
                                  style: const TextStyle(
                                    color: NuviBagColors.coral,
                                  ),
                                ),
                            ],
                          ),
                          style: headingStyle,
                        ),
                      ),
                      _Grid(
                        tiles: section.topPicks,
                        builder: (t, _) =>
                            _PickTile(tile: t, width: tile, onTap: _tap(t)),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Single-line heading that shrinks instead of wrapping.
class _Heading extends StatelessWidget {
  final Widget child;

  const _Heading({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SizedBox(
      height: 26,
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    ),
  );
}

/// Two tiles per row, rows stacked.
class _Grid extends StatelessWidget {
  final List<WardrobeTile> tiles;
  final Widget Function(WardrobeTile tile, int index) builder;

  const _Grid({required this.tiles, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r * 2 < tiles.length; r++) ...[
          if (r > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var c = 0; c < 2; c++)
                if (r * 2 + c < tiles.length)
                  builder(tiles[r * 2 + c], r * 2 + c),
            ],
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    // Long names shrink slightly to fit on one line instead of "…".
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        style: context.nuvi.nunito(13, weight: FontWeight.w500),
      ),
    ),
  );
}

/// Left side: product cut-out with no card, optional badge and sparkle.
class _CategoryTile extends StatelessWidget {
  final WardrobeTile tile;
  final double size;
  final bool sparkle;
  final VoidCallback? onTap;

  const _CategoryTile({
    required this.tile,
    required this.size,
    required this.sparkle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${tile.title}',
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: NuviImage(
                      url: tile.imageUrl,
                      fit: BoxFit.contain,
                      tile: NuviTile.peach,
                    ),
                  ),
                  if (sparkle)
                    const Positioned(
                      left: -9,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: NuviSparkle(
                          size: 12,
                          color: NuviColors.inkFaint,
                        ),
                      ),
                    ),
                  if (tile.badgeText != null)
                    Positioned(
                      top: 0,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: NuviColors.tagPurple,
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                        ),
                        child: Text(
                          tile.badgeText!,
                          style: x.nunito(
                            10,
                            weight: FontWeight.w700,
                            color: NuviColors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _Label(tile.title),
          ],
        ),
      ),
    );
  }
}

/// Right side: rounded photo card with an orange offer pill.
class _PickTile extends StatelessWidget {
  final WardrobeTile tile;
  final double width;
  final VoidCallback? onTap;

  const _PickTile({
    required this.tile,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: tile.offerText == null
          ? 'Shop ${tile.title}'
          : 'Shop ${tile.title}, ${tile.offerText}',
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              width: width,
              height: width * 1.25,
              decoration: BoxDecoration(
                color: NuviColors.peachSoft,
                borderRadius: BorderRadius.circular(NuviRadii.image),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NuviImage(url: tile.imageUrl, tile: NuviTile.peach),
                  if (tile.offerText != null)
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 7,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NuviBagColors.coral,
                            borderRadius: BorderRadius.circular(NuviRadii.pill),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tile.offerText!,
                              style: x.nunito(
                                10,
                                weight: FontWeight.w700,
                                color: NuviColors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _Label(tile.title),
          ],
        ),
      ),
    );
  }
}
