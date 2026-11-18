import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../../category/domain/menu_category.dart';

/// "Shop by Occasion": four tiles across where the child photo stands on a soft
/// rounded panel and pops out above it (best with transparent-background
/// images), sparkle stars around and the occasion name below. Read from
/// the Shopify menu `shop-by-occasion`.
class OccasionSection extends StatelessWidget {
  final List<MenuCategory> occasions;
  final ValueChanged<MenuCategory> onTap;

  const OccasionSection({
    super.key,
    required this.occasions,
    required this.onTap,
  });

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LeafSprig(color: x.sage, mirrored: true),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                'Shop by Occasion',
                style: x.h2,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 14),
            _LeafSprig(color: x.sage),
          ],
        ),
        const SizedBox(height: NuviSpacing.s12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Four tiles fill the row exactly; any extra scroll in.
            final w =
                ((constraints.maxWidth - NuviSpacing.gutter * 2 - _gap * 3) / 4)
                    .clamp(74.0, 130.0);
            final pop = w * 0.2;
            final panel = w * 1.28;
            final label = 32 + 10 * (scale - 1);
            return SizedBox(
              height: pop + panel + label,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: NuviSpacing.gutter,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: occasions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: _gap),
                itemBuilder: (context, index) => _OccasionTile(
                  occasion: occasions[index],
                  index: index,
                  width: w,
                  popHeight: pop,
                  panelHeight: panel,
                  onTap: () => onTap(occasions[index]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OccasionTile extends StatelessWidget {
  final MenuCategory occasion;
  final int index;
  final double width;
  final double popHeight;
  final double panelHeight;
  final VoidCallback onTap;

  const _OccasionTile({
    required this.occasion,
    required this.index,
    required this.width,
    required this.popHeight,
    required this.panelHeight,
    required this.onTap,
  });

  /// Sparkle position per tile (left/right, fraction of image height).
  static const _stars = [
    (left: true, y: 0.32),
    (left: true, y: 0.72),
    (left: true, y: 0.16),
    (left: false, y: 0.3),
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final imageHeight = popHeight + panelHeight;
    final star = _stars[index % _stars.length];
    const radius = BorderRadius.all(Radius.circular(NuviRadii.card));
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${occasion.title}',
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            SizedBox(
              height: imageHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: panelHeight,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: NuviColors.occasionPanel,
                        borderRadius: radius,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: radius,
                      child: NuviImage(
                        url: occasion.imageUrl,
                        tile: NuviTile.gold,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: star.left ? -11 : null,
                    right: star.left ? null : -11,
                    top: imageHeight * star.y,
                    child: const _Sparkle(size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  occasion.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: x.nunito(
                    14.5,
                    weight: FontWeight.w500,
                    color: NuviColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Silver five-point sparkle star.
class _Sparkle extends StatelessWidget {
  final double size;

  const _Sparkle({required this.size});

  static const _svg =
      '<svg viewBox="0 0 24 24"><defs><linearGradient id="g" x1="0" y1="0" '
      'x2="1" y2="1"><stop offset="0" stop-color="#FAFAFC"/>'
      '<stop offset="0.55" stop-color="#C3C7CE"/>'
      '<stop offset="1" stop-color="#8E939C"/></linearGradient></defs>'
      '<path d="M12 1.8l2.9 6.6 7.2.7-5.4 4.8 1.6 7.1L12 17.3 5.7 21l1.6-7.1'
      '-5.4-4.8 7.2-.7z" fill="url(#g)" stroke="#7F848D" stroke-width="0.8" '
      'stroke-linejoin="round"/></svg>';

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.string(_svg, width: size, height: size),
  );
}

/// Small three-leaf sprig on a curved stem.
class _LeafSprig extends StatelessWidget {
  final Color color;
  final bool mirrored;

  const _LeafSprig({required this.color, this.mirrored = false});

  @override
  Widget build(BuildContext context) {
    final sprig = SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2,
            bottom: 2,
            child: NuviLeaf(size: 18, color: color, angle: -0.5),
          ),
          Positioned(
            left: 10,
            top: 2,
            child: NuviLeaf(size: 16, color: color, angle: -1.3),
          ),
          Positioned(
            right: 0,
            top: 8,
            child: NuviLeaf(size: 15, color: color, angle: -0.1),
          ),
        ],
      ),
    );
    return ExcludeSemantics(
      child: mirrored ? Transform.flip(flipX: true, child: sprig) : sprig,
    );
  }
}
