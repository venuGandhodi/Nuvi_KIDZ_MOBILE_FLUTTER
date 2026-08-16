import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'category_controller.dart';
import '../domain/category_filter.dart';
import 'widgets/category_filter_sheet.dart';
import 'widgets/category_sort_sheet.dart';

class CategoryListingScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryListingScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryListingScreen> createState() =>
      _CategoryListingScreenState();
}

class _CategoryListingScreenState extends ConsumerState<CategoryListingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(categoryControllerProvider.notifier)
          .loadCategory(widget.categoryId);
    });
  }

  @override
  void didUpdateWidget(covariant CategoryListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      ref
          .read(categoryControllerProvider.notifier)
          .loadCategory(widget.categoryId);
    }
  }

  void _openFilterSheet() {
    final controller = ref.read(categoryControllerProvider.notifier);
    final currentFilter = ref.read(categoryControllerProvider).filterState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFilterSheet(
        initialFilterState: currentFilter,
        onApply: (newFilter) {
          controller.applyFilter(newFilter);
        },
      ),
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
    final state = ref.watch(categoryControllerProvider);
    final notifier = ref.read(categoryControllerProvider.notifier);
    final title = state.categoryDetail?.title ?? 'Toddler Collection';

    return Material(
      color: NuviColors.surface,
      child: Column(
        children: [
          // Sub-header for Category Title + Filter & Sort buttons
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NuviSpacing.md,
              vertical: NuviSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: NuviColors.surface.withValues(alpha: 0.95),
              border: Border(
                bottom: BorderSide(
                  color: NuviColors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: NuviTypography.textTheme.headlineMedium?.copyWith(
                      color: NuviColors.primary,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.tune,
                      label: 'Filter',
                      isActive: !state.filterState.isEmpty,
                      onTap: _openFilterSheet,
                    ),
                    const SizedBox(width: NuviSpacing.xs),
                    _buildActionButton(
                      icon: Icons.swap_vert,
                      label: 'Sort',
                      isActive: state.sortOption != SortOption.featured,
                      onTap: _openSortSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Product Grid Area
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: NuviColors.primary),
                  )
                : state.errorMessage != null
                ? Center(
                    child: Text(
                      state.errorMessage!,
                      style: NuviTypography.textTheme.bodyMedium,
                    ),
                  )
                : _buildProductGrid(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? NuviColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          border: Border.all(
            color: isActive ? NuviColors.secondary : NuviColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? NuviColors.onSecondary : NuviColors.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: NuviTypography.textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: isActive ? NuviColors.onSecondary : NuviColors.onSurface,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    CategoryState state,
    CategoryController notifier,
  ) {
    final bottomPadding =
        kBottomNavigationBarHeight +
        MediaQuery.of(context).padding.bottom +
        32.0;

    if (state.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NuviSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: NuviColors.border),
              const SizedBox(height: NuviSpacing.md),
              Text(
                'No products match your filter criteria.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.md),
              TextButton(
                onPressed: () => notifier.resetFilters(),
                child: Text(
                  'Reset Filters',
                  style: NuviTypography.textTheme.labelLarge?.copyWith(
                    color: NuviColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(
        left: NuviSpacing.md,
        right: NuviSpacing.md,
        top: NuviSpacing.md,
        bottom: bottomPadding,
      ),
      itemCount: state.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: NuviSpacing.md,
        mainAxisSpacing: NuviSpacing.md,
      ),
      itemBuilder: (context, index) {
        final product = state.products[index];
        final wishlistState = ref.watch(wishlistControllerProvider);
        final isFav = wishlistState.isWishlisted(product.id);
        return NuviProductCard(
          title: product.title,
          price: product.price,
          salePrice: product.salePrice,
          rating: product.rating,
          isFavorite: isFav,
          badgeText: product.badgeText,
          imageUrl: product.imageUrl,
          colorSwatches: product.colorSwatches,
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
    );
  }
}
