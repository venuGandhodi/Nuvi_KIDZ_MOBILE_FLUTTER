import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_icons.dart';
import '../../domain/category.dart';

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
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: NuviSpacing.lg),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isHome = category.name.trim().toLowerCase() == 'home';
          return GestureDetector(
            onTap: () => onCategorySelected?.call(category.id),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: NuviColors.surfaceVariant,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1F999080),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isHome
                      ? Center(
                          child: NuviIcons.home(
                            color: NuviColors.primary,
                            size: 24,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                          child: category.imageUrl != null
                              ? Image.network(
                                  category.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _fallbackIcon(),
                                )
                              : _fallbackIcon(),
                        ),
                ),
                const SizedBox(height: NuviSpacing.xs),
                Text(
                  category.name,
                  style: NuviTypography.textTheme.labelLarge?.copyWith(
                    fontSize: 11.5,
                    color: NuviColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: NuviColors.surfaceVariant,
      child: const Icon(Icons.child_care, color: NuviColors.primary),
    );
  }
}
