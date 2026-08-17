import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/cart_item.dart';

class CartItemRow extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemRow({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = item.product.imageUrl ?? item.product.assetPath;

    return Container(
      padding: const EdgeInsets.all(NuviSpacing.md),
      decoration: BoxDecoration(
        color: NuviColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: NuviColors.textTertiary.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Thumbnail Image
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: NuviColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath != null && imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, color: NuviColors.border),
                    )
                  : const Icon(Icons.image, color: NuviColors.border),
            ),
          ),
          const SizedBox(width: NuviSpacing.md),

          // Details & Actions Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Remove Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.title,
                        style: NuviTypography.textTheme.labelLarge?.copyWith(
                          fontSize: 14.5,
                          color: NuviColors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: NuviColors.onSurface.withValues(alpha: 0.5),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onRemove,
                    ),
                  ],
                ),

                // Variant Text
                if (item.displayVariantInfo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.displayVariantInfo,
                    style: NuviTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: NuviColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: NuviSpacing.md),

                // Quantity Selector & Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Control Pill
                    Container(
                      decoration: BoxDecoration(
                        color: NuviColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(NuviRadii.pill),
                        border: Border.all(
                          color: NuviColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(NuviRadii.pill),
                            onTap: () {
                              if (item.quantity > 1) {
                                onQuantityChanged(item.quantity - 1);
                              } else {
                                onRemove();
                              }
                            },
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: Center(
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: NuviColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: NuviTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: NuviColors.primary,
                                    ),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(NuviRadii.pill),
                            onTap: () => onQuantityChanged(item.quantity + 1),
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: Center(
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: NuviColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price Display
                    Text(
                      item.formattedLineTotal,
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        fontSize: 15,
                        color: NuviColors.accent,
                        fontWeight: FontWeight.w800,
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
