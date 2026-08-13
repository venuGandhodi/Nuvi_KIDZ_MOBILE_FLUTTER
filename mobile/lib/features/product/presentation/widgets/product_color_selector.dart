import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/product_color.dart';

class ProductColorSelector extends StatelessWidget {
  final List<ProductColor> colors;
  final ProductColor? selectedColor;
  final ValueChanged<ProductColor> onColorSelected;

  const ProductColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final activeName = selectedColor?.name ?? colors.first.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Color: ',
              style: NuviTypography.textTheme.labelLarge?.copyWith(
                color: NuviColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              activeName,
              style: NuviTypography.textTheme.labelLarge?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: NuviSpacing.sm),
        Row(
          children: colors.map((c) {
            final isSelected = selectedColor?.id == c.id;
            return GestureDetector(
              onTap: () => onColorSelected(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: c.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? NuviColors.primary : NuviColors.border,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: NuviColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
