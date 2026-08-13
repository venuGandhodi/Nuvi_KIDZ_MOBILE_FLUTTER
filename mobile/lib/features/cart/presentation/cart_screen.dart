import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_bottom_nav.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_row.dart';
import 'widgets/cart_summary_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final notifier = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        cartItemCount: cartState.totalItemCount,
        onCartTap: () {
          // Already on cart screen
        },
      ),
      body: cartState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NuviColors.primary),
            )
          : cartState.items.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: NuviSpacing.md,
                right: NuviSpacing.md,
                top: NuviSpacing.sm,
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Your Bag & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag,
                            color: NuviColors.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: NuviSpacing.xs),
                          Text(
                            'Your Bag',
                            style: NuviTypography.textTheme.headlineMedium
                                ?.copyWith(
                                  color: NuviColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NuviColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                        ),
                        child: Text(
                          '${cartState.totalItemCount} Items',
                          style: NuviTypography.textTheme.labelSmall?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NuviSpacing.md),

                  // Cart Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: NuviColors.border),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return CartItemRow(
                        item: item,
                        onQuantityChanged: (newQty) =>
                            notifier.updateQuantity(item.id, newQty),
                        onRemove: () => notifier.removeItem(item.id),
                      );
                    },
                  ),
                  const SizedBox(height: NuviSpacing.xl),

                  // Summary Card
                  CartSummaryCard(
                    subtotal: cartState.subtotal,
                    shipping: cartState.shippingCost,
                    tax: cartState.estimatedTax,
                    total: cartState.grandTotal,
                    currencyCode: cartState.currencyCode,
                    onCheckout: () async {
                      if (cartState.checkoutUrl != null &&
                          cartState.checkoutUrl!.isNotEmpty) {
                        final uri = Uri.tryParse(cartState.checkoutUrl!);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          return;
                        }
                      }
                      if (context.mounted) {
                        context.push('/checkout');
                      }
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NuviBottomNav(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/category/toddler');
              break;
            case 2:
              // Active Cart
              break;
            case 3:
              // Favorites / Wishlist placeholder
              break;
            case 4:
              // Profile placeholder
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.shopping_bag_outlined,
                size: 40,
                color: NuviColors.primary,
              ),
            ),
            const SizedBox(height: NuviSpacing.lg),
            Text(
              'Your bag is empty',
              style: NuviTypography.textTheme.headlineMedium?.copyWith(
                color: NuviColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: NuviSpacing.xs),
            Text(
              "Looks like you haven't added any tiny styles yet.",
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NuviSpacing.xl),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: NuviButton(
                text: 'START SHOPPING',
                type: NuviButtonType.primary,
                onPressed: () => context.go('/category/toddler'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
