import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
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

  (Color, Color) _statusColors(NuviThemeX x, String status) {
    final upper = status.toUpperCase();
    if (upper == 'FULFILLED' || upper == 'PAID') {
      return (x.sageSoft, NuviColors.leafDark);
    }
    if (upper == 'REFUNDED' || upper == 'VOIDED') {
      return (NuviColors.saleSoft, NuviColors.sale);
    }
    return (x.goldSoft, NuviColors.amber);
  }

  Widget _pill(NuviThemeX x, String status) {
    final (bg, fg) = _statusColors(x, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
      ),
      child: Text(
        status.toUpperCase(),
        style: x.nunito(11, weight: FontWeight.w800, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final itemCount = order.lineItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final thumbs = order.lineItems.take(4).toList();
    final extra = order.lineItems.length - thumbs.length;

    return NuviPressable(
      onTap: onTap,
      pressedScale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(NuviSpacing.md),
        decoration: BoxDecoration(
          color: NuviColors.orderCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NuviColors.orderBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.name, style: x.h3),
                      const SizedBox(height: 2),
                      Text(_formatDate(order.processedAt), style: x.small),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    if (order.financialStatus != null)
                      _pill(x, order.financialStatus!),
                    if (order.fulfillmentStatus != null)
                      _pill(x, order.fulfillmentStatus!),
                  ],
                ),
              ],
            ),
            if (thumbs.isNotEmpty) ...[
              const SizedBox(height: NuviSpacing.s12),
              Row(
                children: [
                  for (final line in thumbs)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipOval(
                        child: NuviImage(
                          url: line.imageUrl,
                          width: 46,
                          height: 46,
                          tile: NuviTile.peach,
                        ),
                      ),
                    ),
                  if (extra > 0)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: x.sageSoft,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+$extra',
                        style: x.baloo(14, weight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: NuviSpacing.s12),
            Row(
              children: [
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: x.small,
                ),
                const Spacer(),
                Text('Total ', style: x.small),
                Text(_formatPrice(order.currentTotalPrice), style: x.price),
              ],
            ),
            const SizedBox(height: NuviSpacing.s12),
            NuviButton(
              text: 'View Order',
              type: NuviButtonType.dark,
              height: 42,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
