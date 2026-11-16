import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_coupon_ticket.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../domain/coupon.dart';
import '../coupon_controller.dart';

/// "Best price" card for the first active coupon; "+ n more offers" (and the
/// card itself) open an offers sheet of coupon tickets with copy.
class ProductCouponCarousel extends ConsumerWidget {
  const ProductCouponCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(activeCouponsProvider);
    return couponsAsync.when(
      data: (coupons) {
        if (coupons.isEmpty) return const SizedBox.shrink();
        return _BestPriceCard(coupons: coupons);
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _BestPriceCard extends StatelessWidget {
  final List<Coupon> coupons;

  const _BestPriceCard({required this.coupons});

  void _openOffers(BuildContext context) {
    showNuviSheet<void>(
      context,
      builder: (sheetContext) => NuviSheet(
        title: 'Offers for you',
        child: Column(
          children: [
            for (final coupon in coupons) ...[
              NuviCouponTicket(
                title: coupon.description,
                code: coupon.code,
                condition: 'Use code ${coupon.code} at checkout',
              ),
              const SizedBox(height: NuviSpacing.s12),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final best = coupons.first;
    final more = coupons.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NuviPressable(
          onTap: () => _openOffers(context),
          semanticLabel: 'Best price offer: ${best.description}',
          pressedScale: 0.99,
          child: Container(
            decoration: BoxDecoration(
              color: NuviColors.card,
              borderRadius: BorderRadius.circular(NuviRadii.card),
              border: Border.all(
                color: x.gold.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 30,
                    color: x.gold,
                    alignment: Alignment.center,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'Best price',
                        style: x.baloo(
                          11.5,
                          weight: FontWeight.w700,
                          color: x.onGold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            best.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: x.baloo(15, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text('Use code ${best.code}', style: x.small),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: NuviColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (more > 0)
          NuviTextAction(
            text: '+ $more more ${more == 1 ? 'offer' : 'offers'}',
            color: x.goldText,
            onTap: () => _openOffers(context),
          ),
      ],
    );
  }
}
