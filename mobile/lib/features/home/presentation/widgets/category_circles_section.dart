import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_icons.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_section_header.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/category.dart';

/// "Shop tiny styles": one horizontal row of rounded category cards on tile
/// gradients (Girls rose, Boys mint, …).
class CategoryCirclesSection extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String>? onCategorySelected;

  const CategoryCirclesSection({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
          child: NuviSectionHeader(
            eyebrow: 'Explore',
            title: 'Shop tiny styles',
            centered: true,
          ),
        ),
        const SizedBox(height: NuviSpacing.md),
        SizedBox(
          height: 176 + 22 * (scale - 1) * 2,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: NuviSpacing.gutter,
              vertical: 4,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: NuviSpacing.gridGap),
            itemBuilder: (context, index) => _CategoryCard(
              category: categories[index],
              tile: NuviGradients.forLabel(categories[index].name, index),
              selected: categories[index].id == selectedCategoryId,
              onTap: () => onCategorySelected?.call(categories[index].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final NuviTile tile;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.tile,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final isHome = category.name.trim().toLowerCase() == 'home';
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${category.name}',
      child: Container(
        width: 116,
        decoration: BoxDecoration(
          gradient: NuviGradients.tile(tile),
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
          border: Border.all(
            color: selected ? x.gold : NuviColors.white,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: NuviShadows.productCard,
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(NuviRadii.image),
                child: isHome
                    ? ColoredBox(
                        color: NuviColors.white.withValues(alpha: 0.6),
                        child: Center(
                          child: NuviIcons.home(
                            color: NuviColors.ink,
                            size: 30,
                          ),
                        ),
                      )
                    : SizedBox.expand(
                        child: NuviImage(url: category.imageUrl, tile: tile),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: x.baloo(15, weight: FontWeight.w700),
            ),
            Text(
              'Shop now ›',
              maxLines: 1,
              style: x.nunito(
                11.5,
                weight: FontWeight.w700,
                color: NuviColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
