import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_icon_button.dart';
import '../../../../core/widgets/nuvi_quantity_selector.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
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
    final x = context.nuvi;
    final imagePath = item.product.imageUrl ?? item.product.assetPath;

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
            child: NuviImage(
              url: imagePath,
              width: 82,
              height: 100,
              tile: NuviTile.peach,
            ),
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
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: x.nunito(
                            14.5,
                            weight: FontWeight.w800,
                            color: NuviBagColors.ink,
                          ),
                        ),
                      ),
                    ),
                    NuviIconButton(
                      icon: Icons.delete_outline_rounded,
                      iconSize: 20,
                      size: 32,
                      color: NuviBagColors.muted,
                      semanticLabel: 'Remove ${item.product.title}',
                      onPressed: onRemove,
                    ),
                  ],
                ),
                if (item.displayVariantInfo.isNotEmpty)
                  Text(
                    item.displayVariantInfo,
                    style: x.nunito(12.5, color: NuviBagColors.muted),
                  ),
                const SizedBox(height: NuviSpacing.sm),
                Row(
                  children: [
                    NuviQuantityStepper(
                      value: item.quantity,
                      borderColor: NuviBagColors.line,
                      onDecrease: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.quantity - 1);
                        } else {
                          onRemove();
                        }
                      },
                      onIncrease: () => onQuantityChanged(item.quantity + 1),
                    ),
                    const Spacer(),
                    Text(
                      item.formattedLineTotal,
                      style: x.bagSerif(
                        17,
                        weight: FontWeight.w600,
                        color: NuviBagColors.ink,
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
