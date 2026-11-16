import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_section_header.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_product_card.dart';
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

    return Material(
      color: NuviColors.cream,
      child: _buildBody(context, wishlistState, wishlistNotifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WishlistState state,
    WishlistController notifier,
  ) {
    final x = context.nuvi;
    if (state.isLoading) {
      return const Center(child: NuviLoadingIndicator());
    }

    if (state.errorMessage != null) {
      return NuviEmptyState(
        title: state.errorMessage!,
        actionLabel: 'Try Again',
        onAction: () => notifier.loadWishlist(),
      );
    }

    if (state.wishlistProducts.isEmpty) {
      return NuviEmptyState(
        title: 'Your Wishlist is Empty',
        message:
            'Save your favorite tiny styles by tapping the heart icon while exploring.',
        actionLabel: 'Explore Products',
        onAction: () => context.go('/home'),
      );
    }

    final count = state.wishlistProducts.length;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            NuviSpacing.gutter,
            NuviSpacing.sm,
            NuviSpacing.gutter,
            NuviSpacing.s12,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NuviEyebrow('Saved for later', lines: false),
                const SizedBox(height: 4),
                Text('Wishlist', style: x.h1),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'saved style' : 'saved styles'}',
                  style: x.nunito(
                    13,
                    weight: FontWeight.w700,
                    color: NuviColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            NuviSpacing.gutter,
            0,
            NuviSpacing.gutter,
            NuviSpacing.xl,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: NuviSpacing.gridGap,
              mainAxisSpacing: NuviSpacing.gridGap,
              childAspectRatio: 0.56,
            ),
            itemCount: count,
            itemBuilder: (context, index) {
              final product = state.wishlistProducts[index];
              return NuviProductCard(
                title: product.title,
                price: product.price,
                salePrice: product.salePrice,
                compareAtPrice: product.compareAtPrice,
                rating: product.rating,
                badgeText: product.badgeText,
                imageUrl: product.imageUrl,
                colorSwatches: product.colorSwatches,
                isFavorite: true,
                tile: NuviTile.values[index % NuviTile.values.length],
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
