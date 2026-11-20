import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_decorations.dart';
import '../../../core/theme/nuvi_motion.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_badge.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_icons.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../../core/widgets/nuvi_price.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../../core/widgets/nuvi_section_header.dart';
import '../../../core/widgets/nuvi_size_pill.dart';
import '../../../core/widgets/nuvi_toast.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../home/domain/product.dart';
import '../../onboarding/presentation/onboarding_assets.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../../support/data/support_repository.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'product_controller.dart';
import 'widgets/product_accordion_section.dart';
import 'widgets/product_color_selector.dart';
import 'widgets/product_coupon_carousel.dart';
import 'widgets/product_delivery_info_section.dart';
import 'widgets/product_gallery.dart';
import 'widgets/size_guide_sheet.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

enum _InfoTab { details, description, shipping }

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final GlobalKey _shareKey = GlobalKey();
  _InfoTab _tab = _InfoTab.details;

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

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
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

  /// The product's public page, or one built from the store domain.
  String _shareUrl(Product p) {
    final url = p.onlineStoreUrl;
    if (url != null && url.isNotEmpty) return url;
    final handle = p.handle ?? p.id;
    return 'https://${ShopifyStorefrontClient().domain}/products/$handle';
  }

  Future<void> _share(Product p) async {
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: '${p.title} on NUVI KIDZ\n${_shareUrl(p)}',
        subject: p.title,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _addToBag() async {
    final ok = await ref.read(productControllerProvider.notifier).addToCart();
    if (!mounted) return;
    final error =
        ref.read(cartControllerProvider).errorMessage ??
        (ok ? null : ref.read(productControllerProvider).errorMessage);
    NuviToast.show(
      context,
      message: error ?? 'Added to bag',
      success: error == null,
    );
  }

  Future<void> _buyNow(bool inBag) async {
    if (!inBag) {
      final ok = await ref.read(productControllerProvider.notifier).addToCart();
      if (!mounted) return;
      final error = ref.read(cartControllerProvider).errorMessage;
      if (!ok || error != null) {
        NuviToast.show(
          context,
          message:
              error ??
              ref.read(productControllerProvider).errorMessage ??
              'Unable to add item to bag.',
          success: false,
        );
        return;
      }
    }
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final product = state.product;
    final x = context.nuvi;

    final header = _Header(
      onBack: _back,
      cartCount: cartState.totalItemCount,
      isFavorite:
          product != null &&
          ref.watch(wishlistControllerProvider).isWishlisted(product.id),
      onFavorite: product == null
          ? null
          : () => ref
                .read(wishlistControllerProvider.notifier)
                .toggleWishlist(product),
    );

    if (state.isLoading || product == null) {
      return Scaffold(
        backgroundColor: NuviColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              header,
              Expanded(
                child: state.isLoading
                    ? const Center(child: NuviLoadingIndicator())
                    : NuviEmptyState(
                        title: 'Product not found',
                        message: state.errorMessage ?? 'Product not found.',
                        actionLabel: 'Back to shop',
                        onAction: () => context.go('/home'),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    final notifier = ref.read(productControllerProvider.notifier);
    final images =
        product.images ??
        (product.imageUrl != null ? [product.imageUrl!] : const <String>[]);
    final onSale = product.compareAtPrice != null && product.salePrice != null;
    final variantPrice = state.selectedVariant?.formattedPrice;
    final variantCompare = state.selectedVariant?.formattedCompareAtPrice;
    final info = NuviPriceInfo.from(
      price: variantPrice ?? product.salePrice ?? product.price,
      compareAtPrice:
          variantCompare ?? (onSale ? product.compareAtPrice : null),
    );
    final isFav = ref
        .watch(wishlistControllerProvider)
        .isWishlisted(product.id);
    final inBag = state.isInBag(cartState.items);
    final available = state.isSelectedVariantAvailable;
    final sizes = product.availableSizes ?? const <String>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: NuviColors.cream,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    NuviSpacing.gutter,
                    4,
                    NuviSpacing.gutter,
                    NuviSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KeyedSubtree(
                        key: _shareKey,
                        child: ProductGallery(
                          images: images,
                          currentIndex: state.selectedImageIndex,
                          onPageChanged: notifier.selectImage,
                          isFavorite: isFav,
                          onToggleFavorite: () => ref
                              .read(wishlistControllerProvider.notifier)
                              .toggleWishlist(product),
                          onShare: () => _share(product),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TitleBlock(product: product),
                      const SizedBox(height: 12),
                      _PriceCard(info: info),
                      const SizedBox(height: 10),
                      const ProductCouponCarousel(),
                      const SizedBox(height: 14),
                      if (product.availableColors != null &&
                          product.availableColors!.isNotEmpty) ...[
                        ProductColorSelector(
                          colors: product.availableColors!,
                          selectedColor: state.selectedColor,
                          onColorSelected: notifier.selectColor,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (sizes.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Size',
                                style: x.baloo(
                                  16,
                                  weight: FontWeight.w700,
                                  color: NuviColors.pdpInk,
                                ),
                              ),
                            ),
                            NuviPressable(
                              onTap: () => showSizeGuideSheet(
                                context,
                                sizes: sizes,
                                selectedSize: state.selectedSize,
                                onSelectSize: notifier.selectSize,
                              ),
                              semanticLabel: 'Size Guide',
                              child: SizedBox(
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.straighten_rounded,
                                      size: 18,
                                      color: x.leaf,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Size Guide',
                                      style: x
                                          .nunito(
                                            14,
                                            weight: FontWeight.w800,
                                            color: NuviColors.leafDark,
                                          )
                                          .copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final size in sizes)
                              NuviSizePill(
                                label: size,
                                selected: state.selectedSize == size,
                                soldOut: _isSizeSoldOut(state, size),
                                onTap: () => notifier.selectSize(size),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      _QuantityRow(
                        quantity: state.quantity,
                        available: available,
                        onChanged: notifier.setQuantity,
                      ),
                      const SizedBox(height: NuviSpacing.lg),
                      _InfoTabs(
                        tab: _tab,
                        onTab: (t) => setState(() => _tab = t),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: NuviMotion.of(context, NuviMotion.fast),
                        child: KeyedSubtree(
                          key: ValueKey(_tab),
                          child: _InfoTabBody(tab: _tab, product: product),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const ProductDeliveryInfoSection(),
                      const SizedBox(height: 14),
                      const ProductPromisesRow(),
                      if (product.reviews != null &&
                          product.reviews!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _Card(
                          child: ProductReviewsSummary(
                            rating: product.rating,
                            reviewCount: product.reviewCount,
                            reviews: product.reviews!,
                          ),
                        ),
                      ],
                      if (state.relatedProducts.isNotEmpty) ...[
                        const SizedBox(height: NuviSpacing.xl),
                        const NuviSectionHeader(
                          eyebrow: 'You may also like',
                          title: 'Similar styles',
                        ),
                        const SizedBox(height: NuviSpacing.s12),
                        SizedBox(
                          height: 300,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: state.relatedProducts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: NuviSpacing.gridGap),
                            itemBuilder: (context, index) {
                              final rel = state.relatedProducts[index];
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
                                  isFavorite: ref
                                      .watch(wishlistControllerProvider)
                                      .isWishlisted(rel.id),
                                  tile: NuviTile
                                      .values[index % NuviTile.values.length],
                                  onFavoriteToggle: () => ref
                                      .read(wishlistControllerProvider.notifier)
                                      .toggleWishlist(rel),
                                  onTap: () =>
                                      context.push('/product/${rel.id}'),
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
        ),
        bottomNavigationBar: _BottomBar(
          isFavorite: isFav,
          onFavorite: () => ref
              .read(wishlistControllerProvider.notifier)
              .toggleWishlist(product),
          available: available,
          inBag: inBag,
          busy: state.isAddingToCart,
          onAddToBag: _addToBag,
          onGoToBag: () => context.go('/cart'),
          onBuyNow: () => _buyNow(inBag),
        ),
      ),
    );
  }
}

/// Back · logo · wishlist · bag (with count).
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final int cartCount;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const _Header({
    required this.onBack,
    required this.cartCount,
    required this.isFavorite,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                kNuviLogoAsset,
                height: 46,
                semanticLabel: 'NUVI KIDZ',
              ),
            ),
          ),
          IconButton(
            tooltip: isFavorite ? 'Remove from wishlist' : 'Save to wishlist',
            onPressed: onFavorite,
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: NuviColors.sale,
              size: 26,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Bag, $cartCount items',
              onPressed: () => context.go('/cart'),
              icon: Badge(
                isLabelVisible: cartCount > 0,
                backgroundColor: x.gold,
                textColor: x.onGold,
                label: Text('$cartCount'),
                child: NuviIcons.bag(color: NuviColors.ink, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: NuviColors.white,
      borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
    ),
    child: child,
  );
}

/// Title, one-line summary, rating and badge.
class _TitleBlock extends StatelessWidget {
  final Product product;

  const _TitleBlock({required this.product});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final summary = product.description?.split(RegExp(r'(?<=[.!?])\s')).first;
    final badge = product.badgeText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title, style: x.pdpTitle),
        if (summary != null && summary.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            summary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: x.nunito(14, color: NuviColors.inkMuted),
          ),
        ],
        if (product.reviewCount > 0 || badge != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (product.reviewCount > 0) ...[
                Icon(Icons.star_rounded, size: 20, color: x.gold),
                const SizedBox(width: 3),
                Text(
                  '${product.rating.toStringAsFixed(1)} '
                  '(${product.reviewCount} reviews)',
                  style: x.nunito(14, weight: FontWeight.w600),
                ),
              ],
              if (product.reviewCount > 0 && badge != null)
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: NuviColors.line,
                ),
              if (badge != null) NuviBadge.fromText(badge, compact: true),
            ],
          ),
        ],
      ],
    );
  }
}

/// MRP (struck) · Price · % OFF.
class _PriceCard extends StatelessWidget {
  final NuviPriceInfo info;

  const _PriceCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final muted = x.nunito(14, color: NuviColors.inkMuted);
    return _Card(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: [
          if (info.compareAt != null) ...[
            Text('MRP', style: muted),
            Text(info.compareAt!, style: x.compareAt.copyWith(fontSize: 15)),
            Container(width: 1, height: 18, color: NuviColors.line),
            Text('Price', style: muted),
          ],
          Text(info.current, style: x.priceLarge),
          if (info.percentOff != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: NuviColors.saleSoft,
                borderRadius: BorderRadius.circular(NuviRadii.pill),
              ),
              child: Text(
                '${info.percentOff}% OFF',
                style: x.nunito(
                  13,
                  weight: FontWeight.w800,
                  color: NuviColors.sale,
                ),
              ),
            ),
          Text(
            'Inclusive of all taxes',
            style: x.nunito(12, color: NuviColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final int quantity;
  final bool available;
  final ValueChanged<int> onChanged;

  const _QuantityRow({
    required this.quantity,
    required this.available,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    Widget step(IconData icon, String label, VoidCallback? onTap) =>
        NuviPressable(
          onTap: onTap,
          semanticLabel: label,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NuviColors.orderBorder),
              color: NuviColors.white,
            ),
            child: Icon(
              icon,
              size: 18,
              color: onTap == null ? NuviColors.inkFaint : NuviColors.ink,
            ),
          ),
        );
    return Row(
      children: [
        Text(
          'Quantity',
          style: x.baloo(16, weight: FontWeight.w700, color: NuviColors.pdpInk),
        ),
        const SizedBox(width: 14),
        step(
          Icons.remove_rounded,
          'Decrease quantity',
          quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: x.nunito(16, weight: FontWeight.w800),
          ),
        ),
        step(
          Icons.add_rounded,
          'Increase quantity',
          quantity < 10 ? () => onChanged(quantity + 1) : null,
        ),
        const Spacer(),
        Icon(
          available ? Icons.check_rounded : Icons.close_rounded,
          size: 18,
          color: available ? x.leaf : NuviColors.sale,
        ),
        const SizedBox(width: 4),
        Text(
          available ? 'In Stock' : 'Out of Stock',
          style: x.nunito(
            14,
            weight: FontWeight.w700,
            color: available ? NuviColors.leafDark : NuviColors.sale,
          ),
        ),
      ],
    );
  }
}

/// Details · Description · Shipping & Return.
class _InfoTabs extends StatelessWidget {
  final _InfoTab tab;
  final ValueChanged<_InfoTab> onTab;

  const _InfoTabs({required this.tab, required this.onTab});

  static const _tabs = [
    (_InfoTab.details, Icons.grid_view_rounded, 'Details'),
    (_InfoTab.description, Icons.description_outlined, 'Description'),
    (_InfoTab.shipping, Icons.local_shipping_outlined, 'Shipping & Return'),
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: NuviColors.white,
        borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
      ),
      child: Row(
        children: [
          for (final (t, icon, label) in _tabs)
            Expanded(
              flex: t == _InfoTab.shipping ? 13 : 10,
              child: NuviPressable(
                onTap: () => onTab(t),
                semanticLabel: label,
                child: AnimatedContainer(
                  duration: NuviMotion.of(context, NuviMotion.fast),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: t == tab ? x.leaf : Colors.transparent,
                    borderRadius: BorderRadius.circular(NuviRadii.card),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: t == tab ? NuviColors.cream : NuviColors.ink,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: x.nunito(
                            13,
                            weight: FontWeight.w700,
                            color: t == tab ? NuviColors.cream : NuviColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoTabBody extends ConsumerWidget {
  final _InfoTab tab;
  final Product product;

  const _InfoTabBody({required this.tab, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final x = context.nuvi;
    final text = x.nunito(14.5, color: NuviColors.ink, height: 1.55);
    switch (tab) {
      case _InfoTab.details:
        return _Card(
          child: ProductAccordionSection(
            description: product.description,
            fabricAndCare: product.fabricAndCare,
          ),
        );
      case _InfoTab.description:
        return _Card(
          child: Text(
            product.description?.isNotEmpty == true
                ? product.description!
                : 'Description coming soon.',
            style: text,
          ),
        );
      case _InfoTab.shipping:
        final content = ref.watch(supportContentProvider);
        return _Card(
          child: content.when(
            loading: () => const Center(child: NuviLoadingIndicator()),
            error: (_, _) => Text(
              'We couldn’t load shipping & return details. Please try again.',
              style: text,
            ),
            data: (c) {
              final parts = [?c.shippingPolicy, ?c.refundPolicy];
              if (parts.isEmpty) {
                return Text(
                  'Shipping & return details will appear here soon.',
                  style: text,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, p) in parts.indexed) ...[
                    if (i > 0) const SizedBox(height: 14),
                    Text(p.title, style: x.h3),
                    const SizedBox(height: 4),
                    Text(p.body, style: text),
                  ],
                ],
              );
            },
          ),
        );
    }
  }
}

/// Wishlist · Add to Bag / Go to Bag · Buy Now.
class _BottomBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavorite;
  final bool available;
  final bool inBag;
  final bool busy;
  final VoidCallback onAddToBag;
  final VoidCallback onGoToBag;
  final VoidCallback onBuyNow;

  const _BottomBar({
    required this.isFavorite,
    required this.onFavorite,
    required this.available,
    required this.inBag,
    required this.busy,
    required this.onAddToBag,
    required this.onGoToBag,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        NuviSpacing.gutter,
        12,
        NuviSpacing.gutter,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: NuviColors.cream,
        boxShadow: NuviShadows.bottomBar,
      ),
      child: Row(
        children: [
          NuviPressable(
            onTap: onFavorite,
            semanticLabel: isFavorite
                ? 'Remove from wishlist'
                : 'Save to wishlist',
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: NuviColors.white,
                borderRadius: BorderRadius.circular(NuviRadii.card),
                border: Border.all(color: NuviColors.orderBorder),
              ),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: NuviColors.sale,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 11,
            child: !available
                ? const NuviButton(
                    text: 'Out of Stock',
                    type: NuviButtonType.leaf,
                    height: 52,
                    onPressed: null,
                  )
                : inBag
                ? NuviButton(
                    text: 'Go to Bag',
                    type: NuviButtonType.leaf,
                    height: 52,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: onGoToBag,
                  )
                : NuviButton(
                    text: 'Add to Bag',
                    type: NuviButtonType.leaf,
                    height: 52,
                    isLoading: busy,
                    icon: NuviIcons.bag(color: NuviColors.cream, size: 19),
                    onPressed: onAddToBag,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 9,
            child: NuviButton(
              text: 'Buy Now',
              type: NuviButtonType.outline,
              height: 52,
              onPressed: available && !busy ? onBuyNow : null,
            ),
          ),
        ],
      ),
    );
  }
}
