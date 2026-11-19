import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../../category/domain/menu_category.dart';

/// Category grid under Deal Zone: small cream cards with the product photo,
/// its name and an optional "Sets" badge. Two rows that scroll sideways when
/// there are more than six; about six tiles show per row.
class ShopCategoryGrid extends StatelessWidget {
  final List<MenuCategory> categories;
  final ValueChanged<MenuCategory> onTap;

  const ShopCategoryGrid({
    super.key,
    required this.categories,
    required this.onTap,
  });

  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final rows = categories.length > 6 ? 2 : 1;
    final columns = (categories.length / rows).ceil();
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return LayoutBuilder(
      builder: (context, constraints) {
        // ~6.3 tiles visible so the next column peeks in when it scrolls.
        final perRow = columns > 6 ? 6.3 : 6.0;
        final w =
            ((constraints.maxWidth - NuviSpacing.gutter - _gap * 6) / perRow)
                .clamp(54.0, 96.0);
        final h = w * 1.22 + 20 * (scale - 1);
        return SizedBox(
          height: h * rows + _gap * (rows - 1) + 6,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.gutter,
              6,
              NuviSpacing.gutter,
              0,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: columns,
            separatorBuilder: (_, _) => const SizedBox(width: _gap),
            // Row-major order: the first row reads left to right, then the
            // second row continues underneath.
            itemBuilder: (context, col) => Column(
              children: [
                for (var row = 0; row < rows; row++) ...[
                  if (row > 0) const SizedBox(height: _gap),
                  if (row * columns + col < categories.length)
                    _Tile(
                      category: categories[row * columns + col],
                      width: w,
                      height: h,
                      onTap: () => onTap(categories[row * columns + col]),
                    )
                  else
                    SizedBox(width: w, height: h),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final MenuCategory category;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _Tile({
    required this.category,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final badge = category.badgeText;
    final label = x.nunito(9.5, weight: FontWeight.w600, height: 1.1);
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${category.title}',
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: NuviBagColors.card,
                  borderRadius: BorderRadius.circular(NuviRadii.small),
                  border: Border.all(color: NuviColors.orderBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F78461E),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 5, 4, 0),
                        child: NuviImage(
                          url: category.imageUrl,
                          fit: BoxFit.contain,
                          tile: NuviTile.peach,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(3, 2, 3, 5),
                      // One size for every name; multi-word names wrap to two
                      // lines, a single long word shrinks instead of breaking.
                      child: _Label(text: category.title, style: label),
                    ),
                  ],
                ),
              ),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: NuviColors.tagPurple,
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                  child: Text(
                    badge,
                    style: x.nunito(
                      9,
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
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _Label({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    if (!text.trim().contains(' ')) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, maxLines: 1, style: style),
      );
    }
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
