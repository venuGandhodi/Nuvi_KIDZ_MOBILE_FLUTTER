import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/services.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_decorations.dart';
import '../../../core/theme/nuvi_motion.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_badge.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_icon_button.dart';
import '../../../core/widgets/nuvi_icons.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../../core/widgets/nuvi_price.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../../core/widgets/nuvi_section_header.dart';
import '../../../core/widgets/nuvi_size_pill.dart';
import '../../../core/widgets/nuvi_toast.dart';
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

  final GlobalKey _similarKey = GlobalKey();

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _scrollToSimilar() {
    final target = _similarKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: NuviMotion.of(context, const Duration(milliseconds: 450)),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isSizeSoldOut(ProductDetailState state, String size) {
    final variants = state.product?.variants;
    if (variants == null) return false;
    final colorName = state.selectedColor?.name;
    final matching = variants.where(
      (v) =>
          v.size == size &&
          (colorName == null || v.color == null || v.color == colorName),
    );
    return matching.isNotEmpty && matching.every((v) => !v.availableForSale);
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final state = ref.watch(productControllerProvider);
    final notifier = ref.read(productControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);
    final product = state.product;

    ref.listen<ProductDetailState>(productControllerProvider, (prev, next) {
      if (next.addedToCartSuccess && !(prev?.addedToCartSuccess ?? false)) {
        NuviToast.show(
          context,
          message: 'Added to bag',
          actionLabel: 'View bag',
          onAction: () => context.go('/cart'),
        );
      }
    });

    if (state.isLoading || product == null) {
      return Scaffold(
        backgroundColor: NuviColors.cream,
        appBar: NuviTopBar(
          title: const SizedBox.shrink(),
          showBackButton: true,
          cartItemCount: cartState.totalItemCount,
          onCartTap: () => context.go('/cart'),
        ),
        body: state.isLoading
            ? const Center(child: NuviLoadingIndicator())
            : NuviEmptyState(
                title: 'Product not found',
                message: state.errorMessage ?? 'Product not found.',
                actionLabel: 'Back to shop',
                onAction: () => context.go('/home'),
              ),
      );
    }

    final images =
        product.images ??
        (product.imageUrl != null ? [product.imageUrl!] : const <String>[]);
    final priceStr = product.salePrice ?? product.price;
    final onSale = product.compareAtPrice != null && product.salePrice != null;
    final shownPrice = onSale
        ? product.salePrice!
        : (state.selectedVariant?.formattedPrice ?? priceStr);
    final info = NuviPriceInfo.from(
      price: shownPrice,
      compareAtPrice: onSale ? product.compareAtPrice : null,
    );
    final isFav = ref
        .watch(wishlistControllerProvider)
        .isWishlisted(product.id);
    final badge = product.badgeText;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: NuviColors.cream,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: NuviSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductImageCarousel(
                images: images,
                currentIndex: state.selectedImageIndex,
                onPageChanged: (idx) => notifier.selectImage(idx),
                onBack: _back,
                ratingLabel: product.reviewCount > 0
                    ? '${product.rating.toStringAsFixed(1)} (${product.reviewCount})'
                    : null,
                onSimilar: state.relatedProducts.isNotEmpty
                    ? _scrollToSimilar
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NuviSpacing.gutter,
                  NuviSpacing.s20,
                  NuviSpacing.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null) ...[
                      NuviBadge.fromText(badge),
                      const SizedBox(height: NuviSpacing.sm),
                    ],
                    Text(product.title, style: x.pdpTitle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        NuviStars(rating: product.rating, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: x.nunito(13, weight: FontWeight.w800),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount} reviews)',
                          style: x.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: NuviSpacing.s12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(info.current, style: x.priceLarge),
                              if (info.compareAt != null)
                                Text(
                                  info.compareAt!,
                                  style: x.compareAt.copyWith(fontSize: 15),
                                ),
                              if (info.percentOff != null)
                                NuviBadge(
                                  label: '${info.percentOff}% OFF',
                                  kind: NuviBadgeKind.sale,
                                  compact: true,
                                ),
                            ],
                          ),
                        ),
                        NuviIconButton(
                          icon: isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? NuviColors.sale : NuviColors.ink,
                          background: NuviColors.card,
                          semanticLabel: isFav
                              ? 'Remove from wishlist'
                              : 'Save to wishlist',
                          onPressed: () {
                            ref
                                .read(wishlistControllerProvider.notifier)
                                .toggleWishlist(product);
                          },
                        ),
                      ],
                    ),
                    Text(
                      'Inclusive of all taxes',
                      style: x.nunito(12, color: NuviColors.inkMuted),
                    ),
                    const SizedBox(height: NuviSpacing.md),
                    const ProductCouponCarousel(),
                    const SizedBox(height: NuviSpacing.s20),
                    if (product.availableColors != null &&
                        product.availableColors!.isNotEmpty) ...[
                      ProductColorSelector(
                        colors: product.availableColors!,
                        selectedColor: state.selectedColor,
                        onColorSelected: (c) => notifier.selectColor(c),
                      ),
                      const SizedBox(height: NuviSpacing.s12),
                    ],
                    if (product.availableSizes != null &&
                        product.availableSizes!.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Size',
                              style: x.baloo(
                                15,
                                weight: FontWeight.w700,
                                color: NuviColors.pdpInk,
                              ),
                            ),
                          ),
                          NuviPressable(
                            onTap: () {
                              // Size guide dialog
                            },
                            child: SizedBox(
                              height: 44,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.straighten_rounded,
                                    size: 17,
                                    color: NuviColors.ink,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Size Guide',
                                    style: x
                                        .nunito(13, weight: FontWeight.w800)
                                        .copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        children: product.availableSizes!.map((size) {
                          return NuviSizePill(
                            label: size,
                            selected: state.selectedSize == size,
                            soldOut: _isSizeSoldOut(state, size),
                            onTap: () => notifier.selectSize(size),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: NuviSpacing.md),
                    ],
                    const ProductPromisesRow(),
                    const SizedBox(height: NuviSpacing.md),
                    const ProductDeliveryInfoSection(),
                    const SizedBox(height: NuviSpacing.md),
                    ProductAccordionSection(
                      description: product.description,
                      fabricAndCare: product.fabricAndCare,
                    ),
                    if (product.reviews != null &&
                        product.reviews!.isNotEmpty) ...[
                      const SizedBox(height: NuviSpacing.lg),
                      ProductReviewsSummary(
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        reviews: product.reviews!,
                      ),
                    ],
                  ],
                ),
              ),
              if (state.relatedProducts.isNotEmpty) ...[
                const SizedBox(height: NuviSpacing.xl),
                Padding(
                  key: _similarKey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: NuviSpacing.gutter,
                  ),
                  child: const NuviSectionHeader(
                    eyebrow: 'You may also like',
                    title: 'Similar styles',
                  ),
                ),
                const SizedBox(height: NuviSpacing.s12),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(
                      NuviSpacing.gutter,
                      4,
                      NuviSpacing.gutter,
                      12,
                    ),
                    itemCount: state.relatedProducts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: NuviSpacing.gridGap),
                    itemBuilder: (context, index) {
                      final rel = state.relatedProducts[index];
                      final isRelFav = ref
                          .watch(wishlistControllerProvider)
                          .isWishlisted(rel.id);
                      return SizedBox(
                        width: 168,
                        child: NuviProductCard(
                          title: rel.title,
                          price: rel.price,
                          salePrice: rel.salePrice,
                          compareAtPrice: rel.compareAtPrice,
                          rating: rel.rating,
                          badgeText: rel.badgeText,
                          imageUrl: rel.imageUrl,
                          isFavorite: isRelFav,
                          tile: NuviTile.values[index % NuviTile.values.length],
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
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: NuviSpacing.gutter,
            right: NuviSpacing.gutter,
            top: NuviSpacing.s12,
            bottom: MediaQuery.of(context).padding.bottom + NuviSpacing.s12,
          ),
          decoration: const BoxDecoration(
            color: NuviColors.white,
            boxShadow: NuviShadows.bottomBar,
          ),
          child: NuviButton(
            text: !state.isSelectedVariantAvailable
                ? 'Out of Stock'
                : state.addedToCartSuccess
                ? 'Added to Cart'
                : 'Add to Cart - ${state.selectedVariant?.formattedPrice ?? priceStr}',
            type: NuviButtonType.leaf,
            isLoading: state.isAddingToCart,
            icon: state.addedToCartSuccess
                ? const Icon(Icons.check_circle_rounded)
                : NuviIcons.bag(color: NuviColors.cream, size: 19),
            onPressed: !state.isSelectedVariantAvailable
                ? () {}
                : () {
                    notifier.addToCart();
                  },
          ),
        ),
      ),
    );
  }
}
