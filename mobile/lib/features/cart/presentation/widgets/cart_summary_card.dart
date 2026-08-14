import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';

class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String currencyCode;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.currencyCode = 'INR',
    required this.onCheckout,
  });

  String _format(double val) {
    final formatted = val.toStringAsFixed(
      val.truncateToDouble() == val ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NuviSpacing.lg),
      decoration: BoxDecoration(
        color: NuviColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(NuviRadii.card),
        border: Border.all(color: NuviColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: NuviTypography.textTheme.headlineMedium?.copyWith(
              color: NuviColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: NuviSpacing.md),

          // Subtotal
          _buildSummaryRow(label: 'Subtotal', value: _format(subtotal)),
          const SizedBox(height: NuviSpacing.xs),

          // Shipping
          _buildSummaryRow(
            label: 'Shipping',
            value: shipping > 0 ? _format(shipping) : 'Calculated at checkout',
          ),
          const SizedBox(height: NuviSpacing.xs),

          // Estimated Tax
          _buildSummaryRow(
            label: 'Estimated Tax',
            value: tax > 0 ? _format(tax) : 'Calculated at checkout',
          ),
          const SizedBox(height: NuviSpacing.md),

          const Divider(color: NuviColors.border),
          const SizedBox(height: NuviSpacing.md),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: NuviTypography.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NuviColors.primary,
                ),
              ),
              Text(
                _format(total),
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: NuviSpacing.lg),

          // Checkout CTA Button
          NuviButton(
            text: 'CHECKOUT',
            type: NuviButtonType.primary,
            onPressed: onCheckout,
          ),
          const SizedBox(height: NuviSpacing.md),

          // Security Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: NuviColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Secure Encrypted Checkout',
                style: NuviTypography.textTheme.labelSmall?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: NuviTypography.textTheme.bodyMedium?.copyWith(
            color: NuviColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: NuviTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: NuviColors.primary,
          ),
        ),
      ],
    );
  }
}
