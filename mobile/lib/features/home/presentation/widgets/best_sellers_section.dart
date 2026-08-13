import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_product_card.dart';
import '../../domain/product.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Bestsellers',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  'View All',
                  style: NuviTypography.textTheme.labelLarge?.copyWith(
                    color: NuviColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NuviSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: NuviSpacing.md,
              mainAxisSpacing: NuviSpacing.md,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFav = favoriteProductIds.contains(product.id);
              return NuviProductCard(
                title: product.title,
                price: product.price,
                salePrice: product.salePrice,
                rating: product.rating,
                isFavorite: isFav,
                badgeText: product.badgeText,
                imageUrl: product.imageUrl,
                onFavoriteToggle: () => onToggleFavorite?.call(product.id),
                onTap: () => onProductTap?.call(product),
              );
            },
          ),
        ],
      ),
    );
  }
}
