import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_decorations.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../../core/widgets/nuvi_button.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_toast.dart';
import '../../checkout/data/shopify_checkout_service.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_row.dart';
import 'widgets/cart_summary_card.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartControllerProvider.notifier).preloadCheckout();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-sync cart when app resumes
      ref.read(cartControllerProvider.notifier).refreshCart();
    }
  }

  Future<void> _startCheckout(
    CartState cartState,
    CartController notifier,
  ) async {
    if (cartState.items.isEmpty || cartState.isCheckingOut) {
      return;
    }

    String? userEmail;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        userEmail = user.email;
        nuviLog('NUVI-CHECKOUT', 'Supabase session present=true');
        nuviLog('NUVI-CHECKOUT', 'Buyer email available=true');
      } else {
        nuviLog('NUVI-CHECKOUT', 'Supabase session present=false');
      }
    } catch (_) {
      nuviLog('NUVI-CHECKOUT', 'Supabase instance not initialized/available');
    }

    await notifier.launchInAppCheckout(userEmail: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CartState>(cartControllerProvider, (previous, next) {
      if (next.checkoutStatus == CheckoutStatus.completed) {
        context.go('/order-confirmation', extra: next.lastCompletedOrderId);
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        NuviToast.show(context, message: next.errorMessage!, success: false);
      }
    });

    final x = context.nuvi;
    final cartState = ref.watch(cartControllerProvider);
    final notifier = ref.read(cartControllerProvider.notifier);

    if (cartState.isLoading) {
      return const Material(
        color: NuviColors.cream,
        child: Center(child: NuviLoadingIndicator()),
      );
    }

    if (cartState.items.isEmpty) {
      return Material(
        color: NuviColors.cream,
        child: NuviEmptyState(
          title: 'Your bag is empty',
          message:
              'Your bag is feeling light — looks like you haven\'t added any tiny styles yet.',
          actionLabel: 'START SHOPPING',
          onAction: () => context.go('/category/toddler'),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: NuviBagColors.background),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  NuviSpacing.gutter,
                  NuviSpacing.sm,
                  NuviSpacing.gutter,
                  NuviSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'NUVI KIDZ',
                      style: x
                          .nunito(
                            11,
                            weight: FontWeight.w800,
                            color: NuviBagColors.muted,
                          )
                          .copyWith(letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('Your Bag', style: x.bagHeadingStyle),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: NuviBagColors.card,
                            borderRadius: BorderRadius.circular(NuviRadii.pill),
                            border: Border.all(color: NuviBagColors.line),
                          ),
                          child: Text(
                            '${cartState.totalItemCount} Items',
                            style: x.nunito(
                              12.5,
                              weight: FontWeight.w800,
                              color: NuviBagColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NuviSpacing.md),
                    for (final item in cartState.items) ...[
                      CartItemRow(
                        item: item,
                        onQuantityChanged: (newQty) =>
                            notifier.updateQuantity(item.id, newQty),
                        onRemove: () => notifier.removeItem(item.id),
                      ),
                      const SizedBox(height: NuviSpacing.s12),
                    ],
                    const SizedBox(height: NuviSpacing.sm),
                    CartSummaryCard(
                      subtotal: cartState.subtotal,
                      shipping: cartState.shippingCost,
                      tax: cartState.estimatedTax,
                      total: cartState.grandTotal,
                      currencyCode: cartState.currencyCode,
                    ),
                  ],
                ),
              ),
            ),
            _CheckoutFooter(
              total: cartState.formattedTotal,
              isBusy: cartState.isCheckingOut,
              onCheckout: () => _startCheckout(cartState, notifier),
              onContinue: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  final String total;
  final bool isBusy;
  final VoidCallback onCheckout;
  final VoidCallback onContinue;

  const _CheckoutFooter({
    required this.total,
    required this.isBusy,
    required this.onCheckout,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      padding: EdgeInsets.fromLTRB(
        NuviSpacing.gutter,
        NuviSpacing.s12,
        NuviSpacing.gutter,
        MediaQuery.paddingOf(context).bottom + NuviSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: NuviBagColors.card,
        border: Border(top: BorderSide(color: NuviBagColors.line)),
        boxShadow: NuviShadows.bottomBar,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Total',
                style: x.nunito(
                  14,
                  weight: FontWeight.w700,
                  color: NuviBagColors.muted,
                ),
              ),
              const Spacer(),
              Text(total, style: x.bagSerif(22, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: NuviSpacing.s12),
          NuviButton(
            text: 'CHECKOUT',
            type: NuviButtonType.bag,
            isLoading: isBusy,
            icon: const Icon(Icons.lock_outline_rounded),
            trailingIcon: const Icon(Icons.arrow_forward_rounded),
            onPressed: onCheckout,
          ),
          NuviTextAction(
            text: 'Continue Shopping',
            color: NuviBagColors.olive,
            onTap: onContinue,
          ),
        ],
      ),
    );
  }
}
