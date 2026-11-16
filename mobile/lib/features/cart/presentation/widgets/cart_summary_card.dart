import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';

/// Order summary card in the bag palette; checkout lives in the pinned
/// footer.
class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String currencyCode;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.currencyCode = 'INR',
  });

  String _format(double val) {
    final formatted = val.toStringAsFixed(
      val.truncateToDouble() == val ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      decoration: BoxDecoration(
        color: NuviBagColors.card,
        borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
        border: Border.all(color: NuviBagColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (x.isFestive)
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [x.gold, x.peach, x.lavender]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(NuviSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Summary', style: x.bagSerif(20, weight: FontWeight.w600)),
                const SizedBox(height: NuviSpacing.md),
                _row(x, 'Subtotal', _format(subtotal)),
                _row(
                  x,
                  'Shipping',
                  shipping > 0 ? _format(shipping) : 'Calculated at checkout',
                ),
                _row(
                  x,
                  'Estimated Tax',
                  tax > 0 ? _format(tax) : 'Calculated at checkout',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: NuviSpacing.s12),
                  child: NuviDashedLine(color: NuviBagColors.line),
                ),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: x.nunito(
                        15,
                        weight: FontWeight.w800,
                        color: NuviBagColors.ink,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _format(total),
                      style: x.bagSerif(19, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: NuviSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: NuviBagColors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secure Encrypted Checkout',
                      style: x.nunito(
                        12,
                        weight: FontWeight.w700,
                        color: NuviBagColors.muted,
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

  Widget _row(NuviThemeX x, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: x.nunito(14, color: NuviBagColors.muted)),
          const Spacer(),
          Text(
            value,
            style: x.nunito(
              14,
              weight: FontWeight.w700,
              color: NuviBagColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
