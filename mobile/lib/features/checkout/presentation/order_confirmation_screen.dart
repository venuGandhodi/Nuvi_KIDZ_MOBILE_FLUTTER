import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_typography.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_top_bar.dart';
import '../../cart/presentation/cart_controller.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String? orderId;

  const OrderConfirmationScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);

    final rawOrderId = orderId ?? cartState.lastCompletedOrderId;
    final displayOrderId = rawOrderId != null && rawOrderId.isNotEmpty
        ? rawOrderId.replaceFirst('gid://shopify/Order/', '')
        : 'Confirmed';

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: false,
        showCart: false,
        onBackTap: () => context.go('/home'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NuviSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkmark Circle Icon
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: NuviColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: NuviColors.secondary,
                ),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // Title & Subtitle
              Text(
                'Order Confirmed!',
                style: NuviTypography.textTheme.displayMedium?.copyWith(
                  color: NuviColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: NuviSpacing.xs),
              Text(
                'Thank you for shopping with Nuvi Kidz!',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  color: NuviColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NuviSpacing.xl),

              // Order Confirmation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NuviSpacing.lg),
                decoration: BoxDecoration(
                  color: NuviColors.surfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(NuviRadii.card),
                  border: Border.all(
                    color: NuviColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order #$displayOrderId',
                      style: NuviTypography.textTheme.headlineMedium?.copyWith(
                        color: NuviColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: NuviSpacing.sm),
                    Text(
                      'Your order details and tracking status are available in My Orders.',
                      style: NuviTypography.textTheme.bodyMedium?.copyWith(
                        color: NuviColors.onSurface.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NuviSpacing.xxl),

              // View Orders Button
              SizedBox(
                width: double.infinity,
                child: NuviButton(
                  text: 'VIEW MY ORDERS',
                  type: NuviButtonType.primary,
                  onPressed: () => context.go('/orders'),
                ),
              ),
              const SizedBox(height: NuviSpacing.md),

              // Continue Shopping Button
              SizedBox(
                width: double.infinity,
                child: NuviButton(
                  text: 'CONTINUE SHOPPING',
                  type: NuviButtonType.secondary,
                  onPressed: () => context.go('/home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
