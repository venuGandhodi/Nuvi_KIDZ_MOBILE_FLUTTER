import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/shopify_customer.dart';

class AddressCard extends StatelessWidget {
  final ShopifyAddress address;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.isDefault,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NuviColors.surface,
        borderRadius: BorderRadius.circular(NuviRadii.card),
        border: Border.all(
          color: isDefault ? NuviColors.secondary : NuviColors.border,
          width: isDefault ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(NuviSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Name and Default Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Address',
                style: NuviTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NuviColors.primary,
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NuviSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: NuviColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: NuviTypography.textTheme.labelSmall?.copyWith(
                      color: NuviColors.secondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: NuviSpacing.sm),

          // Formatted address lines
          Text(
            address.formattedAddress,
            style: NuviTypography.textTheme.bodyMedium?.copyWith(
              color: NuviColors.onSurface.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          if (address.phone != null && address.phone!.isNotEmpty) ...[
            const SizedBox(height: NuviSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: NuviColors.primary,
                ),
                const SizedBox(width: NuviSpacing.xs),
                Text(
                  address.phone!,
                  style: NuviTypography.textTheme.bodySmall?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: NuviSpacing.md),
          const Divider(height: 1, color: NuviColors.border),
          const SizedBox(height: NuviSpacing.sm),

          // Action Buttons: Set as Default, Edit, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isDefault && onSetDefault != null)
                TextButton(
                  onPressed: onSetDefault,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'SET AS DEFAULT',
                    style: NuviTypography.textTheme.labelMedium?.copyWith(
                      color: NuviColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('EDIT'),
                    style: TextButton.styleFrom(
                      foregroundColor: NuviColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: NuviSpacing.sm,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('DELETE'),
                    style: TextButton.styleFrom(
                      foregroundColor: NuviColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: NuviSpacing.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
