import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_decor.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../category/domain/menu_category.dart';
import '../../category/presentation/category_menu_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import '../domain/category.dart';
import 'home_controller.dart';
import 'widgets/age_filter_section.dart';
import 'widgets/best_sellers_section.dart';
import 'widgets/category_circles_section.dart';
import 'widgets/hero_banner_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryMenuControllerProvider.notifier).loadMenu();
    });
  }

  void _onMenuCategoryTap(MenuCategory category) {
    context.push('/category/${category.collectionHandle ?? category.id}');
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final homeNotifier = ref.read(homeControllerProvider.notifier);
    final menuCategories = ref.watch(categoryMenuControllerProvider).categories;

    if (homeState.isLoading) {
      return const Center(child: NuviLoadingIndicator());
    }

    if (homeState.errorMessage != null) {
      return NuviEmptyState(
        title: 'We couldn\u2019t load the shop',
        message: homeState.errorMessage,
        actionLabel: 'Retry',
        onAction: () => homeNotifier.loadHomeData(),
      );
    }

    return Material(
      color: NuviColors.surface,
      child: RefreshIndicator(
        color: NuviColors.ink,
        backgroundColor: NuviColors.cream,
        onRefresh: () async {
          await homeNotifier.loadHomeData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: NuviSpacing.md,
            bottom: NuviSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryCirclesSection(
                categories: menuCategories
                    .map(
                      (m) => Category(
                        id: m.id,
                        name: m.title,
                        imageUrl: m.imageUrl,
                        handle: m.collectionHandle,
                      ),
                    )
                    .toList(),
                selectedCategoryId: homeState.selectedCategoryId,
                onCategorySelected: (id) {
                  homeNotifier.selectCategory(id);
                  final category = menuCategories.firstWhere(
                    (m) => m.id == id,
                    orElse: () => const MenuCategory(id: '', title: ''),
                  );
                  if (category.id.isNotEmpty) {
                    _onMenuCategoryTap(category);
                  }
                },
              ),
              const SizedBox(height: NuviSpacing.xl),
              HeroBannerSection(
                hero: homeState.hero,
                onShopCollectionPressed: () {
                  final handle =
                      homeState.hero?.collectionHandle.isNotEmpty == true
                      ? homeState.hero!.collectionHandle
                      : 'new-arrivals';
                  context.push('/category/$handle');
                },
                onSecondaryPressed: () {
                  context.push('/category/most-selling-items');
                },
              ),
              // Age categories are entirely Shopify-driven (Metaobject type
              // "age_category"); when Shopify returns none (fetch failure or
              // zero active entries), the section is hidden rather than
              // showing stale/hardcoded placeholder data.
              if (homeState.ageFilters.isNotEmpty) ...[
                const SizedBox(height: NuviSpacing.xxl),
                AgeFilterSection(
                  filters: homeState.ageFilters,
                  selectedFilterId: homeState.selectedAgeFilterId,
                  onFilterSelected: (id) {
                    homeNotifier.selectAgeFilter(id);
                    final matches = homeState.ageFilters.where(
                      (f) => f.id == id,
                    );
                    if (matches.isNotEmpty) {
                      final handle = matches.first.collectionHandle;
                      if (handle != null && handle.isNotEmpty) {
                        context.push('/category/$handle');
                      }
                    }
                  },
                ),
              ],
              const SizedBox(height: NuviSpacing.xxl),
              BestSellersSection(
                products: homeState.bestSellers,
                favoriteProductIds: ref
                    .watch(wishlistControllerProvider)
                    .wishlistProductIds,
                onToggleFavorite: (id) {
                  final matches = homeState.bestSellers.where(
                    (p) => p.id == id,
                  );
                  if (matches.isNotEmpty) {
                    ref
                        .read(wishlistControllerProvider.notifier)
                        .toggleWishlist(matches.first);
                  }
                },
                onProductTap: (product) {
                  context.push('/product/${product.id}');
                },
                onViewAllTap: () {
                  context.push('/category/most-selling-items');
                },
              ),
              const SizedBox(height: NuviSpacing.xl),
              const _BrandSignOff(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Closing brand note: mascot, tagline and "Made with tiny smiles".
class _BrandSignOff extends StatelessWidget {
  const _BrandSignOff();

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: BoxDecoration(
        color: x.peachSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NuviSparkle(size: 12, color: x.gold),
              const SizedBox(width: 8),
              Text('Tiny styles, big smiles', style: x.h3),
              const SizedBox(width: 8),
              NuviSparkle(size: 12, color: x.gold),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Made with tiny smiles \u2661',
            style: x.small,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NuviSpacing.sm),
          const NuviMascot(size: 92),
          const NuviHills(height: 36),
        ],
      ),
    );
  }
}
