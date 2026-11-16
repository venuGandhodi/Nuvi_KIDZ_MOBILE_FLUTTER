import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_color_swatch.dart';
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
    final x = context.nuvi;
    final activeName = selectedColor?.name ?? colors.first.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Colour: ',
                style: x.baloo(
                  15,
                  weight: FontWeight.w700,
                  color: NuviColors.pdpInk,
                ),
              ),
              TextSpan(
                text: activeName,
                style: x.nunito(
                  15,
                  weight: FontWeight.w600,
                  color: NuviColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 2,
          children: colors.map((c) {
            return NuviColorSwatch(
              color: c.color,
              semanticLabel: c.name,
              isSelected: selectedColor?.id == c.id,
              onTap: () => onColorSelected(c),
            );
          }).toList(),
        ),
      ],
    );
  }
}
