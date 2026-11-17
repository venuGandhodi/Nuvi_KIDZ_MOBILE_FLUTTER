import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/category.dart';

/// Category cards (Girls / Boys / New Born) from the Shopify main menu.
/// Exactly three cards share the screen width: collection photo on top
/// fading into a soft gradient, a small icon badge, coloured title and a
/// white "Shop Now" pill.
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

  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    final cards = categories
        .where((c) => c.name.trim().toLowerCase() != 'home')
        .take(3)
        .toList();
    if (cards.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - NuviSpacing.gutter * 2 - _gap * 2) / 3;
        final height = width * 1.42 + 30 * (scale - 1);
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            NuviSpacing.gutter,
            4,
            NuviSpacing.gutter,
            8,
          ),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  SizedBox(
                    width: width,
                    child: i < cards.length
                        ? _CategoryCard(
                            category: cards[i],
                            style: _CardStyle.forCategory(cards[i].name, i),
                            onTap: () => onCategorySelected?.call(cards[i].id),
                          )
                        : null,
                  ),
                ],
              ],
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

  const _CardStyle(this.gradient, this.accent, this.icon);

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
    (c) => Icon(Icons.local_florist_outlined, size: 16, color: c),
  );

  static final _boys = _CardStyle(
    const [Color(0xFFE3F0E7), Color(0xFFC9DCE2)],
    const Color(0xFF2F5E43),
    (c) => Icon(Icons.favorite_outline_rounded, size: 16, color: c),
  );

  static final _baby = _CardStyle(
    const [Color(0xFFFCF0D6), Color(0xFFF1E1C6)],
    const Color(0xFFB5462E),
    (c) => SvgPicture.string(
      '<svg viewBox="0 0 24 24"><path d="M3 8l4.5 3.5L12 5l4.5 6.5L21 8l-2 10H5L3 8z" fill="#E8B53E" stroke="#C99520" stroke-width="1" stroke-linejoin="round"/></svg>',
      width: 16,
      height: 16,
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final _CardStyle style;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${category.name}',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: style.gradient,
          ),
          borderRadius: BorderRadius.circular(NuviRadii.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1478461E),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.72, 1.0],
                    ).createShader(rect),
                    child: NuviImage(
                      url: category.imageUrl,
                      tile: NuviTile.peach,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ExcludeSemantics(
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: NuviColors.photoButton,
                          shape: BoxShape.circle,
                        ),
                        child: style.icon(style.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              child: Column(
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: x.baloo(
                      17,
                      weight: FontWeight.w700,
                      color: style.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: NuviColors.white,
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: x.nunito(
                              11.5,
                              weight: FontWeight.w800,
                              color: NuviColors.nightGreen,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: NuviColors.nightGreen,
                          ),
                        ],
                      ),
                    ),
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
