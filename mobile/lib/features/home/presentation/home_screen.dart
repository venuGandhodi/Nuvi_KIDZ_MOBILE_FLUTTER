import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../category/domain/menu_category.dart';
import '../../category/presentation/category_menu_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import '../domain/category.dart';
import '../data/home_sections_repository.dart';
import 'home_controller.dart';
import 'widgets/best_sellers_section.dart';
import 'widgets/category_circles_section.dart';
import 'widgets/hero_banner_section.dart';
import 'widgets/occasion_section.dart';
import 'widgets/styled_banner_section.dart';

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
    final occasions = ref.watch(occasionMenuProvider).value ?? const [];
    final styledBanner = ref.watch(styledBannerProvider).value;

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
      color: NuviColors.cream,
      child: RefreshIndicator(
        color: NuviColors.ink,
        backgroundColor: NuviColors.cream,
        onRefresh: () async {
          ref.invalidate(occasionMenuProvider);
          ref.invalidate(styledBannerProvider);
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
              if (occasions.isNotEmpty) ...[
                const SizedBox(height: NuviSpacing.xl),
                OccasionSection(
                  occasions: occasions,
                  onTap: (o) =>
                      context.push('/category/${o.collectionHandle ?? o.id}'),
                ),
              ],
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
              if (styledBanner != null) ...[
                const SizedBox(height: NuviSpacing.xl),
                StyledBannerSection(
                  banner: styledBanner,
                  onPressed: () => context.push(
                    '/category/${styledBanner.collectionHandle}',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
