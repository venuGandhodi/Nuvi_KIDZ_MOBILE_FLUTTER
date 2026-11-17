import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_icons.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/category.dart';

/// One scrolling row of round, softly tinted category icons with labels.
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
    return SizedBox(
      height: 104 + 20 * (scale - 1),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryIcon(
            category: category,
            tile: NuviGradients.forLabel(category.name, index),
            selected: category.id == selectedCategoryId,
            onTap: () => onCategorySelected?.call(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final Category category;
  final NuviTile tile;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryIcon({
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
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: NuviGradients.tile(tile),
                border: selected ? Border.all(color: x.gold, width: 2) : null,
              ),
              child: ClipOval(
                child: isHome
                    ? Center(
                        child: NuviIcons.home(color: NuviColors.ink, size: 26),
                      )
                    : NuviImage(url: category.imageUrl, tile: tile),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: x.nunito(12.5, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
