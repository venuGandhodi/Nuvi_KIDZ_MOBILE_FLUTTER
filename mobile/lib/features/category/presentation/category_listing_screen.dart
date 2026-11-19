import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_decorations.dart';
import '../../../core/theme/nuvi_motion.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_icon_button.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../../core/widgets/nuvi_section_header.dart';
import '../../../core/widgets/nuvi_skeleton.dart';
import '../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../core/widgets/nuvi_toast.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../home/domain/product.dart';
import '../../product/domain/product_variant.dart';
import '../../product/presentation/widgets/product_delivery_info_section.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'category_controller.dart';
import 'category_menu_controller.dart';
import '../domain/category_filter.dart';
import '../domain/collection_filter.dart';
import '../domain/menu_category.dart';
import 'widgets/collection_filter_bar.dart';
import 'widgets/quick_add_size_sheet.dart';
import 'widgets/category_sort_sheet.dart';

class CategoryListingScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final bool flat;

  const CategoryListingScreen({
    super.key,
    required this.categoryId,
    this.flat = false,
  });

  @override
  ConsumerState<CategoryListingScreen> createState() =>
      _CategoryListingScreenState();
}

class _CategoryListingScreenState extends ConsumerState<CategoryListingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _syncForCategoryId(widget.categoryId));
  }

  void _syncForCategoryId(String categoryId) {
    if (widget.flat) {
      ref.read(categoryControllerProvider.notifier).loadCategory(categoryId);
      return;
    }

    final menuNotifier = ref.read(categoryMenuControllerProvider.notifier);
    if (ref.read(categoryMenuControllerProvider).categories.isEmpty) {
      menuNotifier.loadMenu().then((_) {
        if (mounted) _selectForCategoryId(categoryId);
      });
    } else {
      _selectForCategoryId(categoryId);
    }
  }

  void _selectForCategoryId(String categoryId) {
    final categories = ref.read(categoryMenuControllerProvider).categories;
    MenuCategory? match;
    for (final category in categories) {
      if (category.id == categoryId ||
          category.collectionHandle == categoryId) {
        match = category;
        break;
      }
    }

    if (match != null) {
      ref
          .read(categoryMenuControllerProvider.notifier)
          .selectCategory(match.id);
    }

    if (match == null || match.items.isEmpty) {
      ref
          .read(categoryControllerProvider.notifier)
          .loadCategory(match?.collectionHandle ?? categoryId);
    }
  }

  void _onRailCategoryTap(MenuCategory category) {
    ref
        .read(categoryMenuControllerProvider.notifier)
        .selectCategory(category.id);
    if (category.items.isEmpty) {
      ref
          .read(categoryControllerProvider.notifier)
          .loadCategory(category.collectionHandle ?? category.id);
    }
  }

  void _onSubItemTap(MenuCategory subItem) {
    context.push(
      '/category/${subItem.collectionHandle ?? subItem.id}',
      extra: true,
    );
  }

  @override
  void didUpdateWidget(covariant CategoryListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _syncForCategoryId(widget.categoryId);
    }
  }

  /// Whether the extra filter cards (shown by the Filter button) are open.
  bool _filtersOpen = false;

  void _openFilterKind(CollectionFilterKind kind) {
    if (kind.isPincodeCheck) {
      _openPincodeChecker();
      return;
    }
    final state = ref.read(categoryControllerProvider);
    final controller = ref.read(categoryControllerProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollectionFilterSheet(
        kind: kind,
        values: state.valuesFor(kind),
        selectedIds: state.selectedIdsFor(kind),
        onApply: (values) => controller.setFilterValues(kind, values),
      ),
    );
  }

  /// Delivery Time: the same pincode checker as the product page.
  void _openPincodeChecker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const NuviSheet(
          title: 'Check delivery time',
          child: ProductDeliveryInfoSection(),
        ),
      ),
    );
  }

  /// "+" on a card: pick a size, then add it to the bag.
  void _quickAdd(Product product) {
    final sizes = quickAddSizes(product);
    if (sizes.isEmpty) {
      ProductVariant? variant;
      for (final v in product.variants ?? const <ProductVariant>[]) {
        if (v.availableForSale) {
          variant = v;
          break;
        }
      }
      _addToBag(product, null, variant);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSizeSheet(
        product: product,
        onPick: (size, variant) => _addToBag(product, size, variant),
      ),
    );
  }

  Future<void> _addToBag(
    Product product,
    String? size,
    ProductVariant? variant,
  ) async {
    final cart = ref.read(cartControllerProvider.notifier);
    final color = product.availableColors?.where(
      (c) => c.name == variant?.color,
    );
    await cart.addItem(
      product: product,
      selectedSize: size,
      selectedColor: color == null || color.isEmpty ? null : color.first,
      shopifyVariantId: variant == null || variant.id.isEmpty
          ? null
          : variant.id,
      unitPrice: variant == null || variant.priceAmount == 0
          ? null
          : variant.priceAmount,
    );
    if (!mounted) return;
    final error = ref.read(cartControllerProvider).errorMessage;
    NuviToast.show(
      context,
      message: error ?? 'Added to bag${size == null ? '' : ' · $size'}',
      success: error == null,
      actionLabel: error == null ? 'View bag' : null,
      onAction: error == null ? () => context.go('/cart') : null,
    );
  }

  void _openSortSheet() {
    final controller = ref.read(categoryControllerProvider.notifier);
    final currentSort = ref.read(categoryControllerProvider).sortOption;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySortSheet(
        currentSort: currentSort,
        onSelectSort: (newSort) {
          controller.applySort(newSort);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flat) {
      return Material(
        color: NuviColors.cream,
        child: _buildProductPane(context, title: null, flat: true),
      );
    }

    final menuState = ref.watch(categoryMenuControllerProvider);
    final selected = menuState.selected;
    final hasChildren = selected != null && selected.items.isNotEmpty;

    return Material(
      color: NuviColors.cream,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryRail(menuState),
          Expanded(
            child: hasChildren
                ? _buildSubItemPane(selected)
                : _buildProductPane(
                    context,
                    title: selected?.title,
                    flat: false,
                  ),
          ),
        ],
      ),
    );
  }

  // ── Left rail ──────────────────────────────────────────────────────────
  Widget _buildCategoryRail(CategoryMenuState menuState) {
    if (menuState.categories.isEmpty) {
      return const SizedBox(width: 88);
    }
    final x = context.nuvi;
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: x.sageSoft,
        border: const Border(right: BorderSide(color: NuviColors.line)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: NuviSpacing.sm),
        itemCount: menuState.categories.length,
        itemBuilder: (context, index) {
          final category = menuState.categories[index];
          final isSelected = category.id == menuState.selectedCategoryId;
          final highlighted = category.title.toLowerCase().contains('sale');
          return NuviPressable(
            onTap: () => _onRailCategoryTap(category),
            semanticLabel: category.title,
            child: Semantics(
              selected: isSelected,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: NuviMotion.of(context, NuviMotion.fast),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: highlighted
                            ? x.goldSoft
                            : isSelected
                            ? NuviColors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isSelected ? NuviShadows.floating : null,
                        border: highlighted
                            ? Border.all(color: x.gold, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: NuviGradients.tile(
                                NuviGradients.forLabel(category.title, index),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: NuviImage(
                              url: category.imageUrl,
                              tile: NuviGradients.forLabel(
                                category.title,
                                index,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: isSelected
                                ? x.baloo(12.5, weight: FontWeight.w700)
                                : x.nunito(
                                    11.5,
                                    weight: FontWeight.w700,
                                    color: NuviColors.inkMuted,
                                    height: 1.2,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        left: 0,
                        top: 18,
                        bottom: 18,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: x.gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sub-category explorer ──────────────────────────────────────────────
  Widget _buildSubItemPane(MenuCategory selected) {
    final x = context.nuvi;
    final tiles = <MenuCategory>[
      if (selected.collectionHandle != null)
        MenuCategory(
          id: selected.id,
          title: 'All ${selected.title}',
          imageUrl: selected.imageUrl,
          collectionHandle: selected.collectionHandle,
        ),
      ...selected.items,
    ];
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NuviEyebrow('Shop by category', lines: false),
                const SizedBox(height: 4),
                Text(selected.title, style: x.h2),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
          sliver: SliverGrid.builder(
            itemCount: tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final item = tiles[index];
              final tile = NuviGradients.forLabel(item.title, index);
              return NuviPressable(
                onTap: () => _onSubItemTap(item),
                semanticLabel: item.title,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: NuviGradients.tile(tile),
                          borderRadius: BorderRadius.circular(NuviRadii.image),
                          boxShadow: NuviShadows.productCard,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: NuviImage(url: item.imageUrl, tile: tile),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: x.nunito(12, weight: FontWeight.w700, height: 1.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Collection (products) ──────────────────────────────────────────────
  Widget _buildProductPane(
    BuildContext context, {
    required String? title,
    required bool flat,
  }) {
    final state = ref.watch(categoryControllerProvider);
    final notifier = ref.read(categoryControllerProvider.notifier);
    final headerTitle = title ?? state.categoryDetail?.title ?? 'Products';
    final activeKinds = {for (final f in state.selectedFilters) f.kind};

    // Full-page loader only on first load; refiltering keeps the toolbar.
    if (state.isLoading && state.categoryDetail == null) {
      return Column(
        children: [
          if (flat) _buildBackBar(headerTitle, null),
          const Expanded(child: Center(child: NuviLoadingIndicator())),
        ],
      );
    }

    if (state.errorMessage != null) {
      return Column(
        children: [
          if (flat) _buildBackBar(headerTitle, null),
          Expanded(
            child: NuviEmptyState(
              title: 'Hmm, that didn’t load',
              message: state.errorMessage,
            ),
          ),
        ],
      );
    }

    final bottomPadding =
        kBottomNavigationBarHeight +
        MediaQuery.of(context).padding.bottom +
        32.0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: flat
              ? _buildBackBar(headerTitle, null)
              : _buildBanner(headerTitle, state),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _ToolbarDelegate(
            height: 56,
            child: CollectionFilterBar(
              activeKinds: activeKinds,
              sortActive: state.sortOption != SortOption.featured,
              optionsOpen: _filtersOpen,
              onOpenKind: _openFilterKind,
              onOpenSort: _openSortSheet,
              onToggleOptions: () =>
                  setState(() => _filtersOpen = !_filtersOpen),
            ),
          ),
        ),
        if (_filtersOpen)
          SliverToBoxAdapter(
            child: CollectionFilterOptions(
              kinds: state.filterKinds,
              activeKinds: activeKinds,
              onOpenKind: _openFilterKind,
            ),
          ),
        SliverToBoxAdapter(
          child: CollectionFilterSummary(
            productCount: state.products.length,
            selected: state.selectedFilters,
            onRemove: notifier.removeFilter,
            onClearAll: notifier.clearFilters,
          ),
        ),
        if (state.isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: NuviLoadingIndicator()),
          )
        else if (state.products.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: NuviEmptyState(
              title: state.selectedFilters.isEmpty
                  ? 'No products in this category yet.'
                  : 'No little styles found here yet',
              message: state.selectedFilters.isEmpty
                  ? null
                  : 'Try another filter.',
              actionLabel: state.selectedFilters.isEmpty
                  ? null
                  : 'Reset Filters',
              onAction: notifier.clearFilters,
              mascotSize: 96,
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
            sliver: SliverGrid.builder(
              itemCount: state.products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.56,
                crossAxisSpacing: NuviSpacing.gridGap,
                mainAxisSpacing: NuviSpacing.gridGap,
              ),
              itemBuilder: (context, index) {
                final product = state.products[index];
                final isFav = ref
                    .watch(wishlistControllerProvider)
                    .isWishlisted(product.id);
                return NuviProductCard(
                  title: product.title,
                  price: product.price,
                  salePrice: product.salePrice,
                  compareAtPrice: product.compareAtPrice,
                  rating: product.rating,
                  isFavorite: isFav,
                  badgeText: product.badgeText,
                  imageUrl: product.imageUrl,
                  colorSwatches:
                      product.colorSwatches ??
                      product.availableColors?.map((c) => c.color).toList(),
                  discountPill: true,
                  onQuickAdd: () => _quickAdd(product),
                  tile: NuviTile.values[index % NuviTile.values.length],
                  onFavoriteToggle: () {
                    ref
                        .read(wishlistControllerProvider.notifier)
                        .toggleWishlist(product);
                  },
                  onTap: () {
                    context.push('/product/${product.id}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBackBar(String title, int? count) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          NuviIconButton(
            icon: Icons.chevron_left_rounded,
            iconSize: 26,
            semanticLabel: 'Back',
            onPressed: () => context.pop(),
          ),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: x.h3,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text('· $count products', style: x.small),
          ],
        ],
      ),
    );
  }

  Widget _buildBanner(String title, CategoryState state) {
    final x = context.nuvi;
    final detail = state.categoryDetail;
    final description = detail?.description;
    return ClipPath(
      clipper: const NuviWaveClipper(depth: 10, waves: 3),
      child: Container(
        decoration: BoxDecoration(
          gradient: NuviGradients.tile(NuviTile.lavender),
        ),
        child: Stack(
          children: [
            if (detail?.imageUrl != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.22,
                  child: NuviImage(
                    url: detail!.imageUrl,
                    tile: NuviTile.lavender,
                  ),
                ),
              ),
            Positioned(
              top: 18,
              right: 22,
              child: NuviSparkle(size: 18, color: x.gold),
            ),
            Positioned(
              top: 52,
              right: 52,
              child: NuviSparkle(size: 10, color: x.peach),
            ),
            Positioned(
              bottom: 26,
              right: 18,
              child: NuviLeaf(size: 24, color: x.sage, angle: -0.4),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 56, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home  ›  Collections',
                    style: x.nunito(
                      11.5,
                      weight: FontWeight.w700,
                      color: NuviColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(title, style: x.h1),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: x.nunito(13.5, color: NuviColors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _ToolbarDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: overlapsContent || shrinkOffset > 0
            ? NuviShadows.header
            : null,
      ),
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _ToolbarDelegate oldDelegate) => true;
}
