import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../../category/domain/menu_category.dart';

/// "Shop by Occasion": soft mist tiles with the collection's cut-out photo
/// rising out of the top, silver sparkles and a light label, read from the
/// Shopify menu `shop-by-occasion`.
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
            NuviLeaf(size: 22, color: x.sage, angle: -2.4),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Shop by Occasion',
                style: x.h2,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            NuviLeaf(size: 22, color: x.sage, angle: -0.6),
          ],
        ),
        const SizedBox(height: NuviSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            // Four tiles fill the row exactly; any extra scroll in.
            final w =
                ((constraints.maxWidth - NuviSpacing.gutter * 2 - _gap * 3) / 4)
                    .clamp(72.0, 112.0);
            final h = w * 1.19;
            final pop = w * 0.28;
            return SizedBox(
              height: pop + h + 34 + 10 * (scale - 1),
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
                  width: w,
                  height: h,
                  popOut: pop,
                  sparkleLeft: index.isEven,
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
  final double width;
  final double height;
  final double popOut;
  final bool sparkleLeft;
  final VoidCallback onTap;

  const _OccasionTile({
    required this.occasion,
    required this.width,
    required this.height,
    required this.popOut,
    required this.sparkleLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final w = width;
    final h = height;
    final pop = popOut;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${occasion.title}',
      child: SizedBox(
        width: w,
        child: Column(
          children: [
            SizedBox(
              height: pop + h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: NuviColors.mist,
                        borderRadius: BorderRadius.circular(NuviRadii.card),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: pop + h,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(NuviRadii.card),
                      ),
                      child: NuviImage(
                        url: occasion.imageUrl,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        tile: NuviTile.lavender,
                      ),
                    ),
                  ),
                  Positioned(
                    top: sparkleLeft ? pop + 26 : pop - 6,
                    left: sparkleLeft ? -9 : null,
                    right: sparkleLeft ? null : -9,
                    child: const _SilverStar(size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              occasion.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: x.nunito(
                15.5,
                weight: FontWeight.w500,
                color: NuviColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SilverStar extends StatelessWidget {
  final double size;

  const _SilverStar({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          NuviSparkle(size: 20, color: NuviColors.silver),
          NuviSparkle(size: 11, color: NuviColors.white),
        ],
      ),
    );
  }
}
