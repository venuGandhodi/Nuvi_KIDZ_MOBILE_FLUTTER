import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_product_card.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';
import 'wishlist_controller.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wishlistControllerProvider.notifier).loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistControllerProvider);
    final wishlistNotifier = ref.read(wishlistControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        title: Text(
          'Wishlist',
          style: NuviTypography.textTheme.headlineMedium?.copyWith(
            color: NuviColors.primary,
          ),
        ),
        showBackButton: Navigator.of(context).canPop(),
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: _buildBody(context, wishlistState, wishlistNotifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WishlistState state,
    WishlistController notifier,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: NuviColors.primary),
      );
    }

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
                style: NuviTypography.textTheme.headlineSmall?.copyWith(
                  color: NuviColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.lg),
              NuviButton(
                text: 'Try Again',
                type: NuviButtonType.primary,
                onPressed: () => notifier.loadWishlist(),
              ),
            ],
          ),
        ),
      );
    }

    if (state.wishlistProducts.isEmpty) {
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
                  color: NuviColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: NuviColors.border,
                ),
              ),
              const SizedBox(height: NuviSpacing.lg),
              Text(
                'Your Wishlist is Empty',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Text(
                'Save your favorite tiny styles by tapping the heart icon while exploring.',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.xxl),
              NuviButton(
                text: 'Explore Products',
                type: NuviButtonType.primary,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NuviSpacing.lg,
            vertical: NuviSpacing.sm,
          ),
          child: Text(
            '${state.wishlistProducts.length} ${state.wishlistProducts.length == 1 ? 'saved style' : 'saved styles'}',
            style: NuviTypography.textTheme.labelMedium?.copyWith(
              color: NuviColors.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
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
            itemCount: state.wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = state.wishlistProducts[index];
              return NuviProductCard(
                title: product.title,
                price: product.price,
                salePrice: product.salePrice,
                rating: product.rating,
                badgeText: product.badgeText,
                imageUrl: product.imageUrl,
                colorSwatches: product.colorSwatches,
                isFavorite: true,
                onFavoriteToggle: () => notifier.toggleWishlist(product),
                onTap: () => context.push('/product/${product.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
