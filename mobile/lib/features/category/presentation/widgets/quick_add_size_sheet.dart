import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../../core/widgets/nuvi_size_pill.dart';
import '../../../home/domain/product.dart';
import '../../../product/domain/product_variant.dart';

/// Sizes of a product in Shopify order, each with the variant to add (the
/// first one in stock) or null when every variant of that size is sold out.
List<(String, ProductVariant?)> quickAddSizes(Product product) {
  final variants = product.variants ?? const <ProductVariant>[];
  final sizes = <String>[
    ...?product.availableSizes,
    for (final v in variants) ?v.size,
  ];
  final seen = <String>{};
  return [
    for (final size in sizes)
      if (size.trim().isNotEmpty && seen.add(size))
        (size, _firstInStock(variants, size)),
  ];
}

ProductVariant? _firstInStock(List<ProductVariant> variants, String size) {
  final ofSize = variants.where((v) => v.size == size).toList();
  if (ofSize.isEmpty) {
    // No variant data (e.g. offline sample data): treat as available.
    return const ProductVariant(id: '', title: '', priceAmount: 0);
  }
  for (final v in ofSize) {
    if (v.availableForSale) return v;
  }
  return null;
}

/// Bottom sheet opened from a product card's "+" button: tapping a size
/// adds that size to the bag straight away.
class QuickAddSizeSheet extends StatelessWidget {
  final Product product;
  final void Function(String size, ProductVariant variant) onPick;

  const QuickAddSizeSheet({
    super.key,
    required this.product,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final sizes = quickAddSizes(product);
    return NuviSheet(
      title: 'Select size',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: x.nunito(14, color: NuviColors.inkMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (size, variant) in sizes)
                NuviSizePill(
                  label: size,
                  soldOut: variant == null,
                  onTap: variant == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          onPick(size, variant);
                        },
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
