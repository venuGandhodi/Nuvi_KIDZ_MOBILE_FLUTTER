import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../order/domain/shopify_order.dart';

class OrderCard extends StatelessWidget {
  final ShopifyOrder order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatPrice(ShopifyOrderMoney money) {
    final formatted = money.amount.toStringAsFixed(
      money.amount.truncateToDouble() == money.amount ? 0 : 2,
    );
    return money.currencyCode == 'INR'
        ? '₹$formatted'
        : '${money.currencyCode} $formatted';
  }

  Color _statusColor(String? status) {
    if (status == null) return NuviColors.onSurface.withValues(alpha: 0.6);
    final upper = status.toUpperCase();
    if (upper == 'PAID' || upper == 'FULFILLED') {
      return NuviColors.success;
    }
    if (upper == 'PENDING' || upper == 'UNFULFILLED') {
      return NuviColors.secondary;
    }
    if (upper == 'REFUNDED' || upper == 'VOIDED') {
      return NuviColors.error;
    }
    return NuviColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = order.lineItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NuviRadii.card),
      child: Container(
        padding: const EdgeInsets.all(NuviSpacing.md),
        decoration: BoxDecoration(
          color: NuviColors.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(NuviRadii.card),
          border: Border.all(color: NuviColors.border.withValues(alpha: 0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order Name & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.name.isNotEmpty
                      ? order.name
                      : 'Order #${order.orderNumber ?? ""}',
                  style: NuviTypography.textTheme.headlineMedium?.copyWith(
                    color: NuviColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatPrice(order.currentTotalPrice),
                  style: NuviTypography.textTheme.headlineMedium?.copyWith(
                    color: NuviColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Date & Items Count
            Text(
              '${_formatDate(order.processedAt)} • $itemCount ${itemCount == 1 ? "item" : "items"}',
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: NuviSpacing.sm),

            const Divider(color: NuviColors.border),
            const SizedBox(height: NuviSpacing.xs),

            // Bottom Row: Status Badges & View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (order.financialStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            order.financialStatus,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                        ),
                        child: Text(
                          order.financialStatus!.toUpperCase(),
                          style: NuviTypography.textTheme.labelSmall?.copyWith(
                            color: _statusColor(order.financialStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: NuviSpacing.xs),
                    if (order.fulfillmentStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            order.fulfillmentStatus,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                        ),
                        child: Text(
                          order.fulfillmentStatus!.toUpperCase(),
                          style: NuviTypography.textTheme.labelSmall?.copyWith(
                            color: _statusColor(order.fulfillmentStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Details',
                      style: NuviTypography.textTheme.bodyMedium?.copyWith(
                        color: NuviColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: NuviColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
