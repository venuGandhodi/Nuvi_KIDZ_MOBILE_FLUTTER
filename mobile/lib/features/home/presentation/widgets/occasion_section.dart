import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../../category/domain/menu_category.dart';

/// "Shop by Occasion": photo tiles with a tinted label strip, read from the
/// Shopify menu `shop-by-occasion`.
class OccasionSection extends StatelessWidget {
  final List<MenuCategory> occasions;
  final ValueChanged<MenuCategory> onTap;

  const OccasionSection({
    super.key,
    required this.occasions,
    required this.onTap,
  });

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
        const SizedBox(height: NuviSpacing.s12),
        SizedBox(
          height: 112 + 18 * (scale - 1),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
            scrollDirection: Axis.horizontal,
            itemCount: occasions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final occasion = occasions[index];
              final tone = NuviTone.all[index % NuviTone.all.length];
              return NuviPressable(
                onTap: () => onTap(occasion),
                semanticLabel: 'Shop ${occasion.title}',
                child: Container(
                  width: 98,
                  decoration: BoxDecoration(
                    color: tone.tint,
                    borderRadius: BorderRadius.circular(NuviRadii.card),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: NuviImage(
                            url: occasion.imageUrl,
                            tile: NuviTile.gold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Text(
                          occasion.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: x.nunito(
                            13.5,
                            weight: FontWeight.w700,
                            color: NuviColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
