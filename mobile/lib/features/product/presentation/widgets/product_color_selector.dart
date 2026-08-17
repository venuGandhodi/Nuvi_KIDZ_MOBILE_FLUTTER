import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/product_color.dart';

class ProductColorSelector extends StatelessWidget {
  final List<ProductColor> colors;
  final ProductColor? selectedColor;
  final ValueChanged<ProductColor> onColorSelected;
  final bool dense;

  const ProductColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final activeName = selectedColor?.name ?? colors.first.name;
    final swatchSize = dense ? 26.0 : 40.0;
    final labelStyle = NuviTypography.textTheme.labelLarge?.copyWith(
      fontSize: dense ? 12 : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Color: ',
              style: labelStyle?.copyWith(
                color: NuviColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              activeName,
              style: labelStyle?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        SizedBox(height: dense ? NuviSpacing.xs : NuviSpacing.sm),
        Row(
          children: colors.map((c) {
            final isSelected = selectedColor?.id == c.id;
            return GestureDetector(
              onTap: () => onColorSelected(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: swatchSize,
                height: swatchSize,
                margin: EdgeInsets.symmetric(
                  horizontal: isSelected ? 5 : 0,
                ).copyWith(right: (isSelected ? 5 : 0) + (dense ? 8 : 12)),
                decoration: BoxDecoration(
                  color: c.color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? null
                      : Border.all(color: NuviColors.border, width: 1),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(color: NuviColors.surface, spreadRadius: 2),
                          BoxShadow(
                            color: NuviColors.primary,
                            spreadRadius: 3.5,
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
