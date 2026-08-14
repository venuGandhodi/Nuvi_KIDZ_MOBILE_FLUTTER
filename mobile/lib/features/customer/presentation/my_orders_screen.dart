import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';
import 'customer_controller.dart';
import 'widgets/order_card.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerState = ref.watch(customerControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final orders = customerState.orders;

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/account');
          }
        },
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.push('/cart'),
      ),
      body: customerState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NuviColors.primary),
            )
          : RefreshIndicator(
              color: NuviColors.primary,
              onRefresh: () =>
                  ref.read(customerControllerProvider.notifier).loadCustomer(),
              child: orders.isEmpty
                  ? _buildEmptyOrdersState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(NuviSpacing.md),
                      itemCount: orders.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: NuviSpacing.md),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: NuviSpacing.xs,
                              top: NuviSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  color: NuviColors.secondary,
                                  size: 24,
                                ),
                                const SizedBox(width: NuviSpacing.xs),
                                Text(
                                  'Order History',
                                  style: NuviTypography.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: NuviColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }

                        final order = orders[index - 1];
                        final targetParam = order.name.isNotEmpty
                            ? order.name.replaceAll('#', '')
                            : order.id;

                        return OrderCard(
                          order: order,
                          onTap: () => context.push('/orders/$targetParam'),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyOrdersState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
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
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: NuviColors.primary,
                  ),
                ),
                const SizedBox(height: NuviSpacing.lg),
                Text(
                  'No orders yet',
                  style: NuviTypography.textTheme.headlineMedium?.copyWith(
                    color: NuviColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: NuviSpacing.xs),
                Text(
                  'When you place orders through Shopify, they will appear here.',
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
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
