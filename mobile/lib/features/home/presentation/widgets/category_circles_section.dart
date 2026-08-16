import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: NuviSpacing.lg),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == selectedCategoryId;
              return GestureDetector(
                onTap: () => onCategorySelected?.call(category.id),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? NuviColors.secondary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(NuviRadii.pill),
                        child: category.imageUrl != null
                            ? Image.network(
                                category.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: NuviColors.surfaceVariant,
                                      child: const Icon(
                                        Icons.child_care,
                                        color: NuviColors.primary,
                                      ),
                                    ),
                              )
                            : Container(
                                color: NuviColors.surfaceVariant,
                                child: const Icon(
                                  Icons.child_care,
                                  color: NuviColors.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: NuviSpacing.xs),
                    Text(
                      category.name,
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? NuviColors.primary
                            : NuviColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
