import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_icon_button.dart';
import 'nuvi_quantity_selector.dart';
import 'nuvi_skeleton.dart';

class NuviCartItemRow extends StatelessWidget {
  final String title;
  final String variant;
  final String price;
  final int quantity;
  final String? imageUrl;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const NuviCartItemRow({
    super.key,
    required this.title,
    required this.variant,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.all(NuviSpacing.s12),
      decoration: BoxDecoration(
        color: NuviBagColors.card,
        borderRadius: BorderRadius.circular(NuviRadii.card),
        border: Border.all(color: NuviBagColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(NuviRadii.small),
            child: NuviImage(url: imageUrl, width: 76, height: 92),
          ),
          const SizedBox(width: NuviSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: x.nunito(14, weight: FontWeight.w700),
                      ),
                    ),
                    NuviIconButton(
                      icon: Icons.delete_outline_rounded,
                      iconSize: 20,
                      size: 32,
                      color: NuviBagColors.muted,
                      semanticLabel: 'Remove $title',
                      onPressed: onRemove,
                    ),
                  ],
                ),
                Text(variant, style: x.small),
                const SizedBox(height: NuviSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NuviQuantitySelector(
                      quantity: quantity,
                      onChanged: onQuantityChanged,
                    ),
                    Text(
                      price,
                      style: x.price.copyWith(color: NuviBagColors.ink),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
