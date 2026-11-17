import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_motion.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_price.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/product.dart';

/// Product rail: mascot + title + "View All →", then frameless tiles with a
/// heart, a "% OFF" pill on the photo, title and price.
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
    final x = context.nuvi;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: NuviSpacing.gutter, right: 8),
          child: Row(
            children: [
              const NuviMascot(size: 36),
              const SizedBox(width: 8),
              Expanded(child: Text('Bestsellers', style: x.h2)),
              NuviTextAction(
                text: 'View All',
                onTap: onViewAllTap,
                color: NuviColors.ink,
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: NuviColors.ink,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.sm),
        SizedBox(
          height: 214 + 30 * (scale - 1),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: NuviSpacing.gridGap),
            itemBuilder: (context, index) {
              final product = products[index];
              return _RailTile(
                product: product,
                tile: NuviTile.values[index % NuviTile.values.length],
                isFavorite: favoriteProductIds.contains(product.id),
                onFavorite: () => onToggleFavorite?.call(product.id),
                onTap: () => onProductTap?.call(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RailTile extends StatelessWidget {
  final Product product;
  final NuviTile tile;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _RailTile({
    required this.product,
    required this.tile,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final info = NuviPriceInfo.from(
      price: product.price,
      salePrice: product.salePrice,
      compareAtPrice: product.compareAtPrice,
    );
    return NuviPressable(
      onTap: onTap,
      semanticLabel: product.title,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: NuviGradients.tile(tile),
                  borderRadius: BorderRadius.circular(NuviRadii.card),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NuviImage(url: product.imageUrl, tile: tile),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _Heart(
                        isFavorite: isFavorite,
                        title: product.title,
                        onTap: onFavorite,
                      ),
                    ),
                    if (info.percentOff != null)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NuviColors.white,
                            borderRadius: BorderRadius.circular(NuviRadii.pill),
                          ),
                          child: Text(
                            '${info.percentOff}% OFF',
                            style: x.nunito(
                              11.5,
                              weight: FontWeight.w800,
                              color: NuviColors.sale,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: x.nunito(14, weight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(info.current, style: x.baloo(15, weight: FontWeight.w700)),
                if (info.compareAt != null)
                  Text(info.compareAt!, style: x.compareAt),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Heart extends StatelessWidget {
  final bool isFavorite;
  final String title;
  final VoidCallback onTap;

  const _Heart({
    required this.isFavorite,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NuviPressable(
      onTap: onTap,
      semanticLabel: isFavorite
          ? 'Remove $title from wishlist'
          : 'Save $title to wishlist',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedContainer(
            duration: NuviMotion.of(context, NuviMotion.fast),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: NuviColors.white,
              shape: BoxShape.circle,
              boxShadow: NuviShadows.floating,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isFavorite ? NuviColors.sale : NuviColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
