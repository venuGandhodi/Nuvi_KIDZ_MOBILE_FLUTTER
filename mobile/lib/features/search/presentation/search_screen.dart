import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import 'search_controller.dart';
import 'widgets/search_filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  static const List<String> _quickSuggestions = [
    'Rompers',
    'Dresses',
    'Cardigans',
    'Overalls',
    'New Arrivals',
    'Cotton',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchControllerProvider.notifier).loadMore();
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    ref.read(searchControllerProvider.notifier).searchImmediately(suggestion);
  }

  void _openFilters() {
    final state = ref.read(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);

    SearchFilterBottomSheet.show(
      context,
      initialFilter: state.selectedFilters,
      onApply: (newFilters) {
        notifier.applyFilters(newFilters);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final searchNotifier = ref.read(searchControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: true,
        title: Text(
          'Search',
          style: NuviTypography.textTheme.headlineMedium?.copyWith(
            color: NuviColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.go('/cart'),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NuviSpacing.lg,
              vertical: NuviSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (val) => searchNotifier.search(val),
              onSubmitted: (val) => searchNotifier.searchImmediately(val),
              decoration: InputDecoration(
                hintText: 'Search products, colors, and styles',
                hintStyle: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(Icons.search, color: NuviColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: NuviColors.border),
                        onPressed: () {
                          _searchController.clear();
                          searchNotifier.clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: NuviColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: NuviSpacing.md,
                  vertical: NuviSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NuviRadii.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(child: _buildBody(context, searchState, searchNotifier)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchState state,
    NuviSearchController notifier,
  ) {
    // Initial State: Quick Suggestions
    if (state.isInitialState && state.products.isEmpty && !state.isLoading) {
      return _buildInitialState();
    }

    // Loading Initial State
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: NuviColors.primary),
      );
    }

    // Error State
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NuviSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: NuviColors.accent,
              ),
              const SizedBox(height: NuviSpacing.md),
              Text(
                state.errorMessage!,
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.lg),
              NuviButton(
                text: 'Try Again',
                type: NuviButtonType.primary,
                onPressed: () => notifier.retry(),
              ),
            ],
          ),
        ),
      );
    }

    // Empty Results State
    if (state.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NuviSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_outlined,
                size: 64,
                color: NuviColors.border,
              ),
              const SizedBox(height: NuviSpacing.md),
              Text(
                'No products found',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.xs),
              Text(
                'We couldn\'t find anything matching "${state.query}". Try a different keyword or browse categories.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.xl),
              NuviButton(
                text: 'Clear Search',
                type: NuviButtonType.primary,
                onPressed: () {
                  _searchController.clear();
                  notifier.clearSearch();
                },
              ),
            ],
          ),
        ),
      );
    }

    // Results State
    return Column(
      children: [
        // Results count and filter/sort actions
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NuviSpacing.lg,
            vertical: NuviSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.products.length} ${state.products.length == 1 ? 'style' : 'styles'} found',
                style: NuviTypography.textTheme.labelMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.tune,
                  size: 16,
                  color: NuviColors.primary,
                ),
                label: Text(
                  state.selectedFilters.activeFilterCount > 0
                      ? 'Filters (${state.selectedFilters.activeFilterCount})'
                      : 'Filters & Sort',
                  style: NuviTypography.textTheme.labelSmall?.copyWith(
                    color: NuviColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NuviColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                ),
                onPressed: _openFilters,
              ),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.xs),

        // Product Grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: NuviSpacing.lg,
              vertical: NuviSpacing.sm,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: NuviSpacing.md,
              mainAxisSpacing: NuviSpacing.md,
              childAspectRatio: 0.65,
            ),
            itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(NuviSpacing.md),
                    child: CircularProgressIndicator(
                      color: NuviColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final product = state.products[index];
              final wishlistState = ref.watch(wishlistControllerProvider);
              final isFav = wishlistState.isWishlisted(product.id);
              return NuviProductCard(
                title: product.title,
                price: product.price,
                salePrice: product.salePrice,
                rating: product.rating,
                badgeText: product.badgeText,
                imageUrl: product.imageUrl,
                colorSwatches: product.colorSwatches,
                isFavorite: isFav,
                onFavoriteToggle: () {
                  ref
                      .read(wishlistControllerProvider.notifier)
                      .toggleWishlist(product);
                },
                onTap: () => context.push('/product/${product.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(NuviSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Suggestions',
            style: NuviTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: NuviSpacing.sm),
          Wrap(
            spacing: NuviSpacing.xs,
            runSpacing: NuviSpacing.xs,
            children: _quickSuggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                backgroundColor: NuviColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NuviRadii.pill),
                  side: const BorderSide(color: NuviColors.border),
                ),
                labelStyle: NuviTypography.textTheme.labelMedium?.copyWith(
                  color: NuviColors.primary,
                ),
                onPressed: () => _onSuggestionTap(suggestion),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
