import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_chip.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_icons.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_pressable.dart';
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
    final x = context.nuvi;
    final searchState = ref.watch(searchControllerProvider);
    final searchNotifier = ref.read(searchControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: NuviColors.cream,
      appBar: NuviTopBar(
        showBackButton: true,
        title: const Text('Search'),
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.go('/cart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.gutter,
              NuviSpacing.xs,
              NuviSpacing.gutter,
              NuviSpacing.s12,
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (val) => searchNotifier.search(val),
              onSubmitted: (val) => searchNotifier.searchImmediately(val),
              style: x.body,
              decoration: InputDecoration(
                hintText: 'Search products, colors, and styles',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: NuviIcons.search(color: NuviColors.ink, size: 20),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 42),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(
                          Icons.clear,
                          color: NuviColors.inkMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          searchNotifier.clearSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
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
    final x = context.nuvi;
    if (state.isInitialState && state.products.isEmpty && !state.isLoading) {
      return _buildInitialState();
    }

    if (state.isLoading) {
      return const Center(child: NuviLoadingIndicator());
    }

    if (state.errorMessage != null) {
      return NuviEmptyState(
        title: 'Something went wrong',
        message: state.errorMessage,
        actionLabel: 'Try Again',
        onAction: () => notifier.retry(),
      );
    }

    if (state.products.isEmpty) {
      return NuviEmptyState(
        title: 'No products found',
        message:
            'We couldn\'t find anything matching "${state.query}". Try a different keyword or browse categories.',
        actionLabel: 'Clear Search',
        onAction: () {
          _searchController.clear();
          notifier.clearSearch();
        },
      );
    }

    final filterCount = state.selectedFilters.activeFilterCount;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${state.products.length} ${state.products.length == 1 ? 'style' : 'styles'} found',
                  style: x.nunito(
                    13,
                    weight: FontWeight.w700,
                    color: NuviColors.inkMuted,
                  ),
                ),
              ),
              NuviPressable(
                onTap: _openFilters,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: filterCount > 0 ? x.goldSoft : NuviColors.card,
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                    border: Border.all(
                      color: filterCount > 0 ? x.gold : NuviColors.line,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 17,
                        color: NuviColors.ink,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filterCount > 0
                            ? 'Filters ($filterCount)'
                            : 'Filters & Sort',
                        style: x.baloo(14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: NuviSpacing.sm),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.gutter,
              NuviSpacing.xs,
              NuviSpacing.gutter,
              NuviSpacing.xl,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: NuviSpacing.gridGap,
              mainAxisSpacing: NuviSpacing.gridGap,
              childAspectRatio: 0.56,
            ),
            itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Center(child: NuviLoadingIndicator());
              }

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
                badgeText: product.badgeText,
                imageUrl: product.imageUrl,
                colorSwatches: product.colorSwatches,
                isFavorite: isFav,
                tile: NuviTile.values[index % NuviTile.values.length],
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
    final x = context.nuvi;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        NuviSpacing.gutter,
        NuviSpacing.sm,
        NuviSpacing.gutter,
        NuviSpacing.xl,
      ),
      children: [
        Text('Quick Suggestions', style: x.h3),
        const SizedBox(height: NuviSpacing.sm),
        Wrap(
          spacing: NuviSpacing.sm,
          children: _quickSuggestions.map((suggestion) {
            return NuviChip(
              label: suggestion,
              icon: Icons.north_west_rounded,
              onTap: () => _onSuggestionTap(suggestion),
            );
          }).toList(),
        ),
        const SizedBox(height: NuviSpacing.xl),
        const Center(
          child: Opacity(opacity: 0.9, child: NuviMascot(size: 120)),
        ),
        const SizedBox(height: NuviSpacing.sm),
        Text(
          'Find the perfect little outfit',
          textAlign: TextAlign.center,
          style: x.bodyMuted,
        ),
      ],
    );
  }
}
