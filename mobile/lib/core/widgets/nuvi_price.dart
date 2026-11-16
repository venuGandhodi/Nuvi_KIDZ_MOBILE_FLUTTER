import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_theme_ext.dart';

/// Price maths done in the view from the strings products already carry.
class NuviPriceInfo {
  final String current;
  final String? compareAt;
  final int? percentOff;

  const NuviPriceInfo(this.current, this.compareAt, this.percentOff);

  static double? amount(String? value) {
    if (value == null) return null;
    final digits = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits);
  }

  /// [price] is the regular price, [salePrice] the price paid when on sale,
  /// [compareAtPrice] the original price when the store sets one.
  factory NuviPriceInfo.from({
    required String price,
    String? salePrice,
    String? compareAtPrice,
  }) {
    final current = salePrice ?? price;
    final struck =
        compareAtPrice ??
        (salePrice != null && salePrice != price ? price : null);
    final now = amount(current);
    final was = amount(struck);
    if (struck == null || now == null || was == null || was <= now) {
      return NuviPriceInfo(current, null, null);
    }
    final pct = ((was - now) / was * 100).round();
    return NuviPriceInfo(current, struck, pct > 0 ? pct : null);
  }
}

/// Price bold, compare-at struck, "(x% Off)" in sale red.
class NuviPriceRow extends StatelessWidget {
  final NuviPriceInfo info;
  final double size;

  const NuviPriceRow({super.key, required this.info, this.size = 15.5});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        Text(info.current, style: x.baloo(size, weight: FontWeight.w700)),
        if (info.compareAt != null) Text(info.compareAt!, style: x.compareAt),
        if (info.percentOff != null)
          Text(
            '(${info.percentOff}% Off)',
            style: x.nunito(
              12,
              weight: FontWeight.w800,
              color: NuviColors.sale,
            ),
          ),
      ],
    );
  }
}
