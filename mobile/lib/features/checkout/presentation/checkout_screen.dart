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
import 'checkout_controller.dart';
import 'widgets/delivery_details_form.dart';
import 'widgets/payment_method_selector.dart';
import 'widgets/shipping_method_selector.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutControllerProvider);
    final checkoutNotifier = ref.read(checkoutControllerProvider.notifier);
    final cartState = ref.watch(cartControllerProvider);

    final shippingPrice = checkoutState.selectedDeliveryMethod.price;
    final grandTotal =
        cartState.subtotal + shippingPrice + cartState.estimatedTax;

    return Scaffold(
      backgroundColor: NuviColors.surface,
      appBar: NuviTopBar(
        showBackButton: true,
        onBackTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/cart');
          }
        },
        cartItemCount: cartState.totalItemCount,
        onCartTap: () => context.go('/cart'),
      ),
      body: SingleChildScrollView(
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
            // Checkout Heading
            Text(
              'Checkout',
              style: NuviTypography.textTheme.displayMedium?.copyWith(
                color: NuviColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Almost there! Let's get these tiny styles ready.",
              style: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: NuviSpacing.lg),

            // Error Message Alert
            if (checkoutState.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NuviSpacing.md),
                decoration: BoxDecoration(
                  color: NuviColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(NuviRadii.card / 2),
                  border: Border.all(color: NuviColors.error),
                ),
                child: Text(
                  checkoutState.errorMessage!,
                  style: NuviTypography.textTheme.bodyMedium?.copyWith(
                    color: NuviColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: NuviSpacing.lg),
            ],

            // Delivery Details Form
            DeliveryDetailsForm(
              address: checkoutState.shippingAddress,
              onChanged: (newAddress) =>
                  checkoutNotifier.updateAddress(newAddress),
            ),
            const SizedBox(height: NuviSpacing.lg),

            // Shipping Method Selector
            ShippingMethodSelector(
              selectedMethod: checkoutState.selectedDeliveryMethod,
              onMethodSelected: (method) =>
                  checkoutNotifier.setDeliveryMethod(method),
            ),
            const SizedBox(height: NuviSpacing.lg),

            // Payment Method Selector
            PaymentMethodSelector(
              selectedMethod: checkoutState.selectedPaymentMethod,
              onMethodSelected: (method) =>
                  checkoutNotifier.setPaymentMethod(method),
              onCardNumberChanged: (val) =>
                  checkoutNotifier.updateCardNumber(val),
              onExpiryDateChanged: (val) =>
                  checkoutNotifier.updateExpiryDate(val),
              onCvcChanged: (val) => checkoutNotifier.updateCvc(val),
              onUpiIdChanged: (val) => checkoutNotifier.updateUpiId(val),
            ),
            const SizedBox(height: NuviSpacing.xl),

            // Summary Breakdown
            Container(
              padding: const EdgeInsets.all(NuviSpacing.lg),
              decoration: BoxDecoration(
                color: NuviColors.surfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(NuviRadii.card),
                border: Border.all(
                  color: NuviColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: NuviTypography.textTheme.headlineMedium?.copyWith(
                      color: NuviColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.md),
                  _buildSummaryRow(
                    'Subtotal',
                    '\$${cartState.subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: NuviSpacing.xs),
                  _buildSummaryRow(
                    'Shipping (${checkoutState.selectedDeliveryMethod.title})',
                    '\$${shippingPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: NuviSpacing.xs),
                  _buildSummaryRow(
                    'Estimated Tax',
                    '\$${cartState.estimatedTax.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: NuviSpacing.md),
                  const Divider(color: NuviColors.border),
                  const SizedBox(height: NuviSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: NuviTypography.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: NuviColors.primary,
                        ),
                      ),
                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: NuviTypography.textTheme.headlineMedium
                            ?.copyWith(
                              color: NuviColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NuviSpacing.lg),

                  // Place Order CTA Button
                  NuviButton(
                    text: 'Place Order',
                    type: NuviButtonType.primary,
                    isLoading: checkoutState.isSubmitting,
                    onPressed: () async {
                      final success = await checkoutNotifier.submitOrder();
                      if (success && context.mounted) {
                        context.go('/order-confirmation');
                      }
                    },
                  ),
                  const SizedBox(height: NuviSpacing.md),

                  // Security Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: NuviColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure Encrypted Checkout',
                        style: NuviTypography.textTheme.labelSmall?.copyWith(
                          color: NuviColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: NuviTypography.textTheme.bodyMedium?.copyWith(
            color: NuviColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: NuviTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: NuviColors.primary,
          ),
        ),
      ],
    );
  }
}
