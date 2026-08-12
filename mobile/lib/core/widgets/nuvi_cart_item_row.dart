import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_typography.dart';
import 'nuvi_quantity_selector.dart';

class NuviCartItemRow extends StatelessWidget {
  final String title;
  final String variant; // e.g. "Sage Green • 12-18M"
  final String price;
  final int quantity;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;

  const NuviCartItemRow({
    super.key,
    required this.title,
    required this.variant,
    required this.price,
    required this.quantity,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: NuviSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: NuviColors.surfaceVariant,
              borderRadius: BorderRadius.circular(NuviRadii.small),
            ),
            child: const Icon(Icons.image_outlined, color: NuviColors.border),
          ),
          const SizedBox(width: NuviSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: NuviTypography.textTheme.labelLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.xs),
                Text(
                  variant,
                  style: NuviTypography.textTheme.bodySmall?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: NuviSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NuviQuantitySelector(
                      quantity: quantity,
                      onChanged: onQuantityChanged,
                    ),
                    Text(
                      price,
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: NuviColors.accent,
                      ),
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
