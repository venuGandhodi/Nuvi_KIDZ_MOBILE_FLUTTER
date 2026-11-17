import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/category.dart';

/// Large category cards (Girls / Boys / New Born) from the Shopify main menu:
/// soft gradient, icon, coloured title, subtitle, white "Shop Now" pill and
/// the collection photo on the right.
class CategoryCardsSection extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String>? onCategorySelected;

  const CategoryCardsSection({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cards = categories
        .where((c) => c.name.trim().toLowerCase() != 'home')
        .toList();
    if (cards.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ((constraints.maxWidth - NuviSpacing.gutter * 2) * 0.74)
            .clamp(240.0, 320.0);
        final height = width * 0.82 + 24 * (scale - 1);
        return SizedBox(
          height: height + 16,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.gutter,
              4,
              NuviSpacing.gutter,
              12,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: NuviSpacing.s12),
            itemBuilder: (context, index) => _CategoryCard(
              category: cards[index],
              style: _CardStyle.forCategory(cards[index].name, index),
              width: width,
              onTap: () => onCategorySelected?.call(cards[index].id),
            ),
          ),
        );
      },
    );
  }
}

class _CardStyle {
  final List<Color> gradient;
  final Color accent;
  final Widget Function(Color color) icon;
  final String subtitle;

  const _CardStyle(this.gradient, this.accent, this.icon, this.subtitle);

  static _CardStyle forCategory(String name, int index) {
    final n = name.toLowerCase();
    if (n.contains('girl')) return _girls;
    if (n.contains('boy')) return _boys;
    if (n.contains('born') || n.contains('baby') || n.contains('infant')) {
      return _baby;
    }
    return [_girls, _boys, _baby][index % 3];
  }

  static final _girls = _CardStyle(
    const [Color(0xFFFBE4E8), Color(0xFFF2D3D8)],
    const Color(0xFFA8455C),
    (c) => Icon(Icons.local_florist_outlined, size: 30, color: c),
    'Stylish outfits for her',
  );

  static final _boys = _CardStyle(
    const [Color(0xFFE3F0E7), Color(0xFFC9DCE2)],
    const Color(0xFF2F5E43),
    (c) => Icon(Icons.favorite_outline_rounded, size: 30, color: c),
    'Everyday styles for him',
  );

  static final _baby = _CardStyle(
    const [Color(0xFFFCF0D6), Color(0xFFF1E1C6)],
    const Color(0xFFB5462E),
    (c) => SvgPicture.string(
      '<svg viewBox="0 0 24 24"><path d="M3 8l4.5 3.5L12 5l4.5 6.5L21 8l-2 10H5L3 8z" fill="#E8B53E" stroke="#C99520" stroke-width="1" stroke-linejoin="round"/></svg>',
      width: 30,
      height: 30,
    ),
    'Cosy picks for little ones',
  );
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final _CardStyle style;
  final double width;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.style,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${category.name}',
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: style.gradient),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1478461E),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: width * 0.5,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.28],
                ).createShader(rect),
                child: NuviImage(
                  url: category.imageUrl,
                  tile: NuviTile.peach,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 0, 20),
              child: SizedBox(
                width: width * 0.64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(child: style.icon(style.accent)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: width * 0.47,
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: x.baloo(
                          25,
                          weight: FontWeight.w700,
                          color: style.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: width * 0.47,
                      child: Text(
                        style.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: x.nunito(15, color: NuviColors.inkMuted),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: NuviColors.white,
                        borderRadius: BorderRadius.circular(NuviRadii.pill),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: x.nunito(
                              15,
                              weight: FontWeight.w800,
                              color: NuviColors.nightGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: NuviColors.nightGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
