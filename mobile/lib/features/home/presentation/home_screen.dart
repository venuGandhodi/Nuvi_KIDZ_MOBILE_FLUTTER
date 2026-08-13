import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_bottom_nav.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/cart_controller.dart';
import 'home_controller.dart';
import 'widgets/age_filter_section.dart';
import 'widgets/best_sellers_section.dart';
import 'widgets/category_circles_section.dart';
import 'widgets/hero_banner_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeNotifier = ref.read(homeControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        title: Image.asset(
          'assets/images/brand/nuvi_kidz_logo.png',
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Text(
            'Nuvi Kidz',
            style: NuviTypography.textTheme.headlineMedium?.copyWith(
              color: NuviColors.primary,
            ),
          ),
        ),
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: homeState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NuviColors.primary),
            )
          : homeState.errorMessage != null
          ? Center(
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
            )
          : _buildTabContent(context, ref, homeState, homeNotifier),
      bottomNavigationBar: NuviBottomNav(
        currentIndex: homeState.currentBottomNavIndex,
        onTap: (index) {
          homeNotifier.setBottomNavIndex(index);
        },
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    WidgetRef ref,
    HomeState homeState,
    HomeController homeNotifier,
  ) {
    switch (homeState.currentBottomNavIndex) {
      case 0:
        final bottomPadding =
            kBottomNavigationBarHeight +
            MediaQuery.of(context).padding.bottom +
            32.0;
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroBannerSection(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAFpju392Q1xn2AJbOH6i84veMzV8CIixbhDvSfev46-u4_JZayJQIFnXhrHEVwvacS8R3Yqz5xKPu96JKK13KMhQKxFxLkLnJXz9NyUwcIZ4wn0co3f1eqH4Qpm3q-U4Ugpoqku-8t-1F7pb_aL95IXewiYYQ8_64qWmtarZhwe1gnvFEtqcpH2u82uIp_phTTft_zPdY8hPZjpq2y0BYUg1FsGCMEoLThIKZ_Q5E5vMJdLVJRJbMjsQ',
                onShopCollectionPressed: () {
                  context.push('/category/toddler');
                },
              ),
              const SizedBox(height: NuviSpacing.xl),
              CategoryCirclesSection(
                categories: homeState.categories,
                selectedCategoryId: homeState.selectedCategoryId,
                onCategorySelected: (id) {
                  homeNotifier.selectCategory(id);
                  context.push('/category/$id');
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
                favoriteProductIds: homeState.favoriteProductIds,
                onToggleFavorite: (id) => homeNotifier.toggleFavorite(id),
                onProductTap: (product) {
                  context.push('/product/${product.id}');
                },
                onViewAllTap: () {
                  context.push('/category/toddler');
                },
              ),
            ],
          ),
        );
      case 1:
        return _buildPlaceholderTab(
          context,
          title: 'Shop',
          icon: Icons.shopping_bag_outlined,
          message: 'Explore all categories and items.',
        );
      case 2:
        return _buildPlaceholderTab(
          context,
          title: 'Search',
          icon: Icons.search,
          message: 'Search for products, colors, and styles.',
        );
      case 3:
        return _buildPlaceholderTab(
          context,
          title: 'Wishlist',
          icon: Icons.favorite_outline,
          message:
              'Items you favorite will appear here.\n(${homeState.favoriteProductIds.length} items saved)',
        );
      case 4:
        return _buildAccountTab(context, ref);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlaceholderTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NuviSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: NuviColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: NuviSpacing.md),
            Text(
              title,
              style: NuviTypography.textTheme.headlineMedium?.copyWith(
                color: NuviColors.primary,
              ),
            ),
            const SizedBox(height: NuviSpacing.sm),
            Text(
              message,
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NuviSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: NuviColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: NuviColors.onSecondary,
              ),
            ),
            const SizedBox(height: NuviSpacing.lg),
            Text(
              'Account',
              style: NuviTypography.textTheme.headlineMedium?.copyWith(
                color: NuviColors.primary,
              ),
            ),
            const SizedBox(height: NuviSpacing.sm),
            Text(
              'Manage your profile, orders, and preferences.',
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NuviSpacing.xxl),
            NuviButton(
              text: 'Sign Out',
              type: NuviButtonType.secondary,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
