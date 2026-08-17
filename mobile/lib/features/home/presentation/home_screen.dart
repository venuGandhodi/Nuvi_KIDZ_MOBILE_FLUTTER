import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../category/domain/menu_category.dart';
import '../../category/presentation/category_menu_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import '../domain/category.dart';
import 'home_controller.dart';
import 'widgets/age_filter_section.dart';
import 'widgets/best_sellers_section.dart';
import 'widgets/category_circles_section.dart';
import 'widgets/hero_banner_section.dart';
import 'widgets/home_search_bar.dart';

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
      return const Center(
        child: CircularProgressIndicator(color: NuviColors.primary),
      );
    }

    if (homeState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              homeState.errorMessage!,
              style: NuviTypography.textTheme.bodyMedium,
            ),
            const SizedBox(height: NuviSpacing.md),
            NuviButton(
              text: 'Retry',
              onPressed: () => homeNotifier.loadHomeData(),
            ),
          ],
        ),
      );
    }

    return Material(
      color: NuviColors.surface,
      child: RefreshIndicator(
        color: NuviColors.primary,
        onRefresh: () async {
          await homeNotifier.loadHomeData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: NuviSpacing.sm,
            bottom: NuviSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSearchBar(onTap: () => context.push('/search')),
              const SizedBox(height: NuviSpacing.lg),
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
              ),
              const SizedBox(height: NuviSpacing.xl),
              AgeFilterSection(
                filters: homeState.ageFilters,
                selectedFilterId: homeState.selectedAgeFilterId,
                onFilterSelected: (id) => homeNotifier.selectAgeFilter(id),
              ),
              const SizedBox(height: NuviSpacing.xl),
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
            ],
          ),
        ),
      ),
    );
  }
}
