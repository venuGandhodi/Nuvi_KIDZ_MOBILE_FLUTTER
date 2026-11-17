import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../../category/domain/menu_category.dart';

/// "Shop by Occasion": rounded photo tiles with a soft cream label strip,
/// flanked by leaf sprigs, read from the Shopify menu `shop-by-occasion`.
class OccasionSection extends StatelessWidget {
  final List<MenuCategory> occasions;
  final ValueChanged<MenuCategory> onTap;

  const OccasionSection({
    super.key,
    required this.occasions,
    required this.onTap,
  });

  static const double _gap = 10;

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
                    .clamp(74.0, 116.0);
            final photo = w * 0.78;
            final label = 36 + 10 * (scale - 1);
            return SizedBox(
              height: photo + label + 8,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  NuviSpacing.gutter,
                  0,
                  NuviSpacing.gutter,
                  8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: occasions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: _gap),
                itemBuilder: (context, index) => _OccasionTile(
                  occasion: occasions[index],
                  width: w,
                  photoHeight: photo,
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
  final double photoHeight;
  final VoidCallback onTap;

  const _OccasionTile({
    required this.occasion,
    required this.width,
    required this.photoHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${occasion.title}',
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: NuviColors.occasionLabel,
          borderRadius: BorderRadius.circular(NuviRadii.card),
          boxShadow: NuviShadows.productCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: photoHeight,
              width: double.infinity,
              child: NuviImage(url: occasion.imageUrl, tile: NuviTile.gold),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    occasion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: x.nunito(
                      14.5,
                      weight: FontWeight.w600,
                      color: NuviColors.nightGreen,
                    ),
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
