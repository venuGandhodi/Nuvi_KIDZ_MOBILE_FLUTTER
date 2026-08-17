import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_pill_selector.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'product_controller.dart';
import 'widgets/product_accordion_section.dart';
import 'widgets/product_color_selector.dart';
import 'widgets/product_coupon_carousel.dart';
import 'widgets/product_delivery_info_section.dart';
import 'widgets/product_image_carousel.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(productControllerProvider.notifier)
          .loadProduct(widget.productId);
    });
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      ref
          .read(productControllerProvider.notifier)
          .loadProduct(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productControllerProvider);
    final notifier = ref.read(productControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);
    final product = state.product;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: NuviColors.surface,
        appBar: NuviTopBar(
          title: const SizedBox.shrink(),
          showBackButton: true,
          cartItemCount: cartState.totalItemCount,
          onCartTap: () => context.go('/cart'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: NuviColors.primary),
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: NuviColors.surface,
        appBar: NuviTopBar(
          title: const SizedBox.shrink(),
          showBackButton: true,
          cartItemCount: cartState.totalItemCount,
          onCartTap: () => context.go('/cart'),
        ),
        body: Center(
          child: Text(
            state.errorMessage ?? 'Product not found.',
            style: NuviTypography.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final images =
        product.images ??
        (product.imageUrl != null ? [product.imageUrl!] : const []);
    final priceStr = product.salePrice ?? product.price;

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        title: const SizedBox.shrink(),
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.go('/cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: NuviSpacing.md,
                right: NuviSpacing.md,
                top: NuviSpacing.sm,
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    48.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery Carousel
                  ProductImageCarousel(
                    images: images,
                    currentIndex: state.selectedImageIndex,
                    onPageChanged: (idx) => notifier.selectImage(idx),
                  ),
                  const SizedBox(height: NuviSpacing.md),

                  // Title & Wishlist Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: NuviTypography.textTheme.displayMedium
                              ?.copyWith(
                                color: NuviColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final wishlistState = ref.watch(
                            wishlistControllerProvider,
                          );
                          final isFav = wishlistState.isWishlisted(product.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav
                                  ? NuviColors.secondary
                                  : NuviColors.onSurface.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              ref
                                  .read(wishlistControllerProvider.notifier)
                                  .toggleWishlist(product);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: NuviSpacing.xs),

                  // Price & Rating Row
                  Row(
                    children: [
                      if (product.compareAtPrice != null &&
                          product.salePrice != null) ...[
                        Text(
                          product.salePrice!,
                          style: NuviTypography.textTheme.headlineMedium
                              ?.copyWith(
                                color: NuviColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.compareAtPrice!,
                          style: NuviTypography.textTheme.bodyMedium?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ] else ...[
                        Text(
                          state.selectedVariant?.formattedPrice ?? priceStr,
                          style: NuviTypography.textTheme.headlineMedium
                              ?.copyWith(
                                color: NuviColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                              ),
                        ),
                      ],
                      const SizedBox(width: NuviSpacing.md),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: NuviColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: NuviTypography.textTheme.labelLarge?.copyWith(
                          color: NuviColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: NuviTypography.textTheme.bodySmall?.copyWith(
                          color: NuviColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NuviSpacing.sm),

                  // Subtitle Summary
                  if (product.description != null)
                    Text(
                      product.description!,
                      style: NuviTypography.textTheme.bodyMedium?.copyWith(
                        color: NuviColors.onSurface.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: NuviSpacing.md),

                  // Color Selector
                  if (product.availableColors != null &&
                      product.availableColors!.isNotEmpty) ...[
                    ProductColorSelector(
                      colors: product.availableColors!,
                      selectedColor: state.selectedColor,
                      onColorSelected: (c) => notifier.selectColor(c),
                      dense: true,
                    ),
                    const SizedBox(height: NuviSpacing.sm),
                  ],

                  // Size Selector
                  if (product.availableSizes != null &&
                      product.availableSizes!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Size',
                          style: NuviTypography.textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            color: NuviColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Size guide dialog
                          },
                          child: Text(
                            'Size Guide',
                            style: NuviTypography.textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 12,
                                  color: NuviColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NuviSpacing.xs),
                    Wrap(
                      spacing: NuviSpacing.xs,
                      runSpacing: NuviSpacing.xs,
                      children: product.availableSizes!.map((size) {
                        final isSelected = state.selectedSize == size;
                        return NuviPillSelector(
                          label: size,
                          isSelected: isSelected,
                          dense: true,
                          onTap: () => notifier.selectSize(size),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: NuviSpacing.md),
                  ],

                  // Accordion Section
                  ProductAccordionSection(
                    description: product.description,
                    fabricAndCare: product.fabricAndCare,
                    reviews: product.reviews,
                  ),
                  const SizedBox(height: NuviSpacing.md),

                  // Pincode & Delivery Info
                  const ProductDeliveryInfoSection(),
                  const SizedBox(height: NuviSpacing.md),

                  // Coupon Carousel
                  const ProductCouponCarousel(),
                  const SizedBox(height: NuviSpacing.lg),

                  // You May Also Like Horizontal Carousel
                  if (state.relatedProducts.isNotEmpty) ...[
                    Text(
                      'You May Also Like',
                      style: NuviTypography.textTheme.headlineMedium?.copyWith(
                        color: NuviColors.primary,
                      ),
                    ),
                    const SizedBox(height: NuviSpacing.md),
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.relatedProducts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: NuviSpacing.md),
                        itemBuilder: (context, index) {
                          final rel = state.relatedProducts[index];
                          final wishlistState = ref.watch(
                            wishlistControllerProvider,
                          );
                          final isRelFav = wishlistState.isWishlisted(rel.id);
                          return SizedBox(
                            width: 160,
                            child: NuviProductCard(
                              title: rel.title,
                              price: rel.price,
                              salePrice: rel.salePrice,
                              rating: rel.rating,
                              imageUrl: rel.imageUrl,
                              isFavorite: isRelFav,
                              onFavoriteToggle: () {
                                ref
                                    .read(wishlistControllerProvider.notifier)
                                    .toggleWishlist(rel);
                              },
                              onTap: () => context.push('/product/${rel.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Add to Cart CTA
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: NuviSpacing.lg,
          right: NuviSpacing.lg,
          top: NuviSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + NuviSpacing.md,
        ),
        decoration: BoxDecoration(
          color: NuviColors.surface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: NuviColors.border.withValues(alpha: 0.5)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NuviButton(
          text: !state.isSelectedVariantAvailable
              ? 'Out of Stock'
              : state.addedToCartSuccess
              ? 'Added to Cart'
              : 'Add to Cart - ${state.selectedVariant?.formattedPrice ?? priceStr}',
          type: NuviButtonType.primary,
          isLoading: state.isAddingToCart,
          icon: state.addedToCartSuccess
              ? Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: NuviColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: NuviColors.onSecondary,
                  ),
                )
              : null,
          onPressed: !state.isSelectedVariantAvailable
              ? () {}
              : () {
                  notifier.addToCart();
                },
        ),
      ),
    );
  }
}
