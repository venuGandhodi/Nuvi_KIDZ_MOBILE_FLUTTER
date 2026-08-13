import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/delivery_method.dart';

class ShippingMethodSelector extends StatelessWidget {
  final DeliveryMethod selectedMethod;
  final ValueChanged<DeliveryMethod> onMethodSelected;

  const ShippingMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Method',
          style: NuviTypography.textTheme.labelLarge?.copyWith(
            color: NuviColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: NuviSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildShippingCard(
                method: DeliveryMethod.standard,
                isSelected: selectedMethod.id == DeliveryMethod.standard.id,
              ),
            ),
            const SizedBox(width: NuviSpacing.md),
            Expanded(
              child: _buildShippingCard(
                method: DeliveryMethod.express,
                isSelected: selectedMethod.id == DeliveryMethod.express.id,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShippingCard({
    required DeliveryMethod method,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onMethodSelected(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(NuviSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? NuviColors.primary.withValues(alpha: 0.08)
              : NuviColors.surface,
          borderRadius: BorderRadius.circular(NuviRadii.card / 2),
          border: Border.all(
            color: isSelected ? NuviColors.primary : NuviColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  method.title,
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NuviColors.primary,
                  ),
                ),
                Text(
                  '\$${method.price.toStringAsFixed(2)}',
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NuviColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              method.estimatedDays,
              style: NuviTypography.textTheme.labelSmall?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
