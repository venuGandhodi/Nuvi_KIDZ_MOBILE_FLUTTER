import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/widgets/nuvi_product_card.dart';
import '../../../../core/widgets/nuvi_section_header.dart';
import '../../domain/product.dart';

/// "Top picks by customers": a horizontal rail of product cards, each
/// carrying a Bestseller pill unless the product has its own badge.
class BestSellersSection extends StatelessWidget {
  final List<Product> products;
  final Set<String> favoriteProductIds;
  final ValueChanged<String>? onToggleFavorite;
  final ValueChanged<Product>? onProductTap;
  final VoidCallback? onViewAllTap;

  const BestSellersSection({
    super.key,
    required this.products,
    this.favoriteProductIds = const {},
    this.onToggleFavorite,
    this.onProductTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
          child: NuviSectionHeader(
            eyebrow: 'Top picks by customers',
            title: 'Bestsellers',
            actionLabel: 'View all',
            onAction: onViewAllTap,
          ),
        ),
        const SizedBox(height: NuviSpacing.s12),
        SizedBox(
          height: 318 + 40 * (scale - 1),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.gutter,
              4,
              NuviSpacing.gutter,
              14,
            ),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: NuviSpacing.gridGap),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 176,
                child: NuviProductCard(
                  title: product.title,
                  price: product.price,
                  salePrice: product.salePrice,
                  compareAtPrice: product.compareAtPrice,
                  rating: product.rating,
                  isFavorite: favoriteProductIds.contains(product.id),
                  badgeText: product.badgeText ?? 'Bestseller',
                  imageUrl: product.imageUrl,
                  tile: NuviTile.values[index % NuviTile.values.length],
                  onFavoriteToggle: () => onToggleFavorite?.call(product.id),
                  onTap: () => onProductTap?.call(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
