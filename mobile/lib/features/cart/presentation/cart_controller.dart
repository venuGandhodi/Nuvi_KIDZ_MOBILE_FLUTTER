import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/nuvi_logger.dart';
import '../../checkout/data/shopify_checkout_service.dart';
import '../../customer/presentation/customer_controller.dart';
import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';
import '../data/cart_repository.dart';
import '../data/shopify_cart_repository.dart';
import '../data/shopify_cart_storage.dart';
import '../domain/cart_item.dart';
import '../domain/shopify_cart.dart';

final shopifyCartStorageProvider = Provider<ShopifyCartStorage>((ref) {
  return ShopifyCartStorage();
});

final shopifyCartRepositoryProvider = Provider<ShopifyCartRepository>((ref) {
  return ShopifyCartRepository();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return MockCartRepository();
});

class CartState {
  final List<CartItem> items;
  final String? cartId;
  final String? checkoutUrl;
  final int totalQuantity;
  final double subtotalAmount;
  final double totalAmount;
  final double taxAmount;
  final String currencyCode;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final CheckoutStatus checkoutStatus;
  final String? lastCompletedOrderId;

  const CartState({
    this.items = const [],
    this.cartId,
    this.checkoutUrl,
    this.totalQuantity = 0,
    this.subtotalAmount = 0.0,
    this.totalAmount = 0.0,
    this.taxAmount = 0.0,
    this.currencyCode = 'INR',
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.checkoutStatus = CheckoutStatus.idle,
    this.lastCompletedOrderId,
  });

  bool get isCheckingOut =>
      checkoutStatus == CheckoutStatus.preparing ||
      checkoutStatus == CheckoutStatus.presenting ||
      checkoutStatus == CheckoutStatus.inCheckout;

  int get totalItemCount => totalQuantity > 0
      ? totalQuantity
      : items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal => subtotalAmount > 0
      ? subtotalAmount
      : items.fold<double>(0.0, (sum, item) => sum + item.lineTotal);

  double get shippingCost => 0.0;

  double get estimatedTax => taxAmount;

  double get grandTotal => totalAmount > 0 ? totalAmount : subtotal;

  String get formattedSubtotal {
    final formatted = subtotal.toStringAsFixed(
      subtotal.truncateToDouble() == subtotal ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  String get formattedTotal {
    final formatted = grandTotal.toStringAsFixed(
      grandTotal.truncateToDouble() == grandTotal ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  CartState copyWith({
    List<CartItem>? items,
    String? cartId,
    String? checkoutUrl,
    int? totalQuantity,
    double? subtotalAmount,
    double? totalAmount,
    double? taxAmount,
    String? currencyCode,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    CheckoutStatus? checkoutStatus,
    String? lastCompletedOrderId,
  }) {
    return CartState(
      items: items ?? this.items,
      cartId: cartId ?? this.cartId,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      checkoutStatus: checkoutStatus ?? this.checkoutStatus,
      lastCompletedOrderId: lastCompletedOrderId ?? this.lastCompletedOrderId,
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    Future.microtask(() => loadCart());
    return const CartState(isLoading: true);
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final storage = ref.read(shopifyCartStorageProvider);
      final repo = ref.read(shopifyCartRepositoryProvider);

      final cartId = await storage.getCartId();
      if (cartId == null || cartId.isEmpty) {
        state = const CartState(isLoading: false);
        return;
      }

      final cart = await repo.getCart(cartId);
      if (cart != null) {
        _applyShopifyCart(cart);
      } else {
        await storage.clearCartId();
        state = const CartState(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load your bag. Please check your connection.',
      );
    }
  }

  Future<void> refreshCart() async {
    try {
      final storage = ref.read(shopifyCartStorageProvider);
      final repo = ref.read(shopifyCartRepositoryProvider);

      final cartId = await storage.getCartId();
      if (cartId == null || cartId.isEmpty) {
        state = const CartState(isLoading: false);
        return;
      }

      final cart = await repo.getCart(cartId);
      if (cart != null) {
        _applyShopifyCart(cart);
      } else {
        await storage.clearCartId();
        state = const CartState(isLoading: false);
      }
    } catch (_) {
      // Quiet background refresh failure: keep existing state
    }
  }

  Future<void> addItem({
    required Product product,
    ProductColor? selectedColor,
    String? selectedSize,
    int quantity = 1,
    double? unitPrice,
    String? shopifyVariantId,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      final storage = ref.read(shopifyCartStorageProvider);
      final repo = ref.read(shopifyCartRepositoryProvider);

      final variantId =
          shopifyVariantId ??
          (product.variants != null && product.variants!.isNotEmpty
              ? product.variants!.first.id
              : null);

      if (variantId == null || variantId.isEmpty) {
        // Fallback for tests if no Shopify variant ID exists
        final mockRepo = ref.read(cartRepositoryProvider);
        double rawPrice = unitPrice ?? 0.0;
        if (unitPrice == null) {
          final priceClean = (product.salePrice ?? product.price)
              .replaceAll('₹', '')
              .replaceAll('\$', '')
              .replaceAll(',', '')
              .trim();
          rawPrice = double.tryParse(priceClean) ?? 0.0;
        }

        final newItem = CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          shopifyVariantId: shopifyVariantId,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          quantity: quantity,
          unitPrice: rawPrice,
        );

        final updatedItems = await mockRepo.addItem(newItem);
        state = state.copyWith(items: updatedItems, isUpdating: false);
        return;
      }

      ShopifyCart updatedCart;
      if (state.cartId == null || state.cartId!.isEmpty) {
        updatedCart = await repo.createCart(
          variantId: variantId,
          quantity: quantity,
        );
        await storage.saveCartId(updatedCart.id);
      } else {
        updatedCart = await repo.addItem(
          cartId: state.cartId!,
          variantId: variantId,
          quantity: quantity,
        );
      }

      _applyShopifyCart(updatedCart);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e is ShopifyCartException
            ? e.message
            : 'Unable to add item to bag. Please try again.',
      );
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      if (state.cartId == null || state.cartId!.isEmpty) {
        // Mock fallback for test environment
        final mockRepo = ref.read(cartRepositoryProvider);
        final updated = await mockRepo.updateQuantity(cartItemId, quantity);
        state = state.copyWith(items: updated, isUpdating: false);
        return;
      }

      final repo = ref.read(shopifyCartRepositoryProvider);
      final updatedCart = await repo.updateQuantity(
        cartId: state.cartId!,
        lineId: cartItemId,
        quantity: quantity,
      );

      _applyShopifyCart(updatedCart);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e is ShopifyCartException
            ? e.message
            : 'Unable to update quantity. Please try again.',
      );
    }
  }

  Future<void> removeItem(String cartItemId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      if (state.cartId == null || state.cartId!.isEmpty) {
        // Mock fallback for test environment
        final mockRepo = ref.read(cartRepositoryProvider);
        final updated = await mockRepo.removeItem(cartItemId);
        state = state.copyWith(items: updated, isUpdating: false);
        return;
      }

      final repo = ref.read(shopifyCartRepositoryProvider);
      final updatedCart = await repo.removeItem(
        cartId: state.cartId!,
        lineId: cartItemId,
      );

      _applyShopifyCart(updatedCart);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e is ShopifyCartException
            ? e.message
            : 'Unable to remove item from bag. Please try again.',
      );
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      final storage = ref.read(shopifyCartStorageProvider);
      await storage.clearCartId();
      state = const CartState();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to clear bag.',
      );
    }
  }

  /// Updates buyer identity email on the active Shopify cart if available.
  Future<bool> updateBuyerIdentity(String email) async {
    final cartId = state.cartId;
    if (cartId == null || cartId.isEmpty) {
      return false;
    }

    try {
      nuviLog('NUVI-CHECKOUT', 'Updating Shopify cart buyer identity');
      final repo = ref.read(shopifyCartRepositoryProvider);
      final updatedCart = await repo.updateBuyerIdentity(
        cartId: cartId,
        email: email.trim(),
      );
      _applyShopifyCart(updatedCart);
      nuviLog('NUVI-CHECKOUT', 'Buyer identity update SUCCESS');
      return true;
    } catch (e) {
      nuviLog('NUVI-CHECKOUT', 'Buyer identity update FAILED: $e');
      return false;
    }
  }

  /// Prepares checkout by updating buyer identity with authenticated email (if present)
  /// and returning the latest checkoutUrl.
  Future<String?> prepareCheckoutUrl({String? userEmail}) async {
    if (userEmail != null &&
        userEmail.trim().isNotEmpty &&
        state.cartId != null) {
      await updateBuyerIdentity(userEmail.trim());
    }
    return state.checkoutUrl;
  }

  /// Preloads the checkout sheet in the background if checkoutUrl is available.
  Future<void> preloadCheckout() async {
    final checkoutUrl = state.checkoutUrl;
    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      final checkoutService = ref.read(shopifyCheckoutServiceProvider);
      await checkoutService.preloadCheckout(checkoutUrl);
    }
  }

  /// Initiates in-app Shopify Checkout Kit presentation.
  Future<bool> launchInAppCheckout({String? userEmail}) async {
    if (state.isCheckingOut) {
      nuviLog(
        'NUVI-CHECKOUT',
        'Checkout presentation ignored: already checking out',
      );
      return false;
    }

    if (state.items.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Your cart is empty. Add items before checking out.',
      );
      return false;
    }

    nuviLog('NUVI-CHECKOUT', 'Checkout START');
    state = state.copyWith(
      checkoutStatus: CheckoutStatus.preparing,
      errorMessage: null,
    );

    try {
      final checkoutUrl = await prepareCheckoutUrl(userEmail: userEmail);
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        state = state.copyWith(
          checkoutStatus: CheckoutStatus.failed,
          errorMessage:
              'Unable to initialize checkout. Please refresh your bag.',
        );
        return false;
      }

      nuviLog('NUVI-CHECKOUT', 'Checkout URL ready');
      state = state.copyWith(checkoutStatus: CheckoutStatus.presenting);

      final checkoutService = ref.read(shopifyCheckoutServiceProvider);

      // Register lifecycle event hooks
      checkoutService.setEventHandlers(
        onCompleted: (orderId) => onCheckoutCompleted(orderId),
        onCancelled: () => onCheckoutCancelled(),
        onFailed: (message) => onCheckoutFailed(message),
      );

      final presented = await checkoutService.presentCheckout(checkoutUrl);
      if (presented) {
        state = state.copyWith(checkoutStatus: CheckoutStatus.inCheckout);
      } else {
        state = state.copyWith(
          checkoutStatus: CheckoutStatus.failed,
          errorMessage: 'Could not open in-app checkout.',
        );
      }
      return presented;
    } catch (e) {
      nuviLog('NUVI-CHECKOUT', 'Checkout presentation FAILED: $e');
      state = state.copyWith(
        checkoutStatus: CheckoutStatus.failed,
        errorMessage: 'Unable to start checkout: $e',
      );
      return false;
    }
  }

  /// Invoked when Shopify Checkout Kit reports successful order placement.
  Future<void> onCheckoutCompleted(String orderId) async {
    nuviLog(
      'NUVI-CHECKOUT',
      'Checkout COMPLETED. Clearing cart for order $orderId',
    );
    await clearCart();
    state = state.copyWith(
      checkoutStatus: CheckoutStatus.completed,
      lastCompletedOrderId: orderId,
    );

    // Trigger non-blocking background customer order refresh
    _refreshCustomerOrdersInBackground();
  }

  void _refreshCustomerOrdersInBackground() {
    Future.microtask(() async {
      try {
        nuviLog('NUVI-CHECKOUT', 'Order refresh started');
        await ref.read(customerControllerProvider.notifier).loadCustomer();
        nuviLog('NUVI-CHECKOUT', 'Order refresh completed');
      } catch (e) {
        nuviLog('NUVI-CHECKOUT', 'Order refresh failed: $e');
        // Checkout remains successful; background sync failure is isolated.
      }
    });
  }

  /// Invoked when the user dismisses or cancels the in-app Checkout Sheet.
  void onCheckoutCancelled() {
    nuviLog('NUVI-CHECKOUT', 'Checkout CANCELLED. Preserving cart state.');
    state = state.copyWith(
      checkoutStatus: CheckoutStatus.cancelled,
      errorMessage: null,
    );
  }

  /// Invoked when Checkout Kit encounters a fatal error.
  void onCheckoutFailed(String message) {
    nuviLog(
      'NUVI-CHECKOUT',
      'Checkout FAILED: $message. Preserving cart state.',
    );
    state = state.copyWith(
      checkoutStatus: CheckoutStatus.failed,
      errorMessage: message,
    );
  }

  void _applyShopifyCart(ShopifyCart cart) {
    final items = cart.lines.map((line) => line.toCartItem()).toList();

    state = state.copyWith(
      items: items,
      cartId: cart.id,
      checkoutUrl: cart.checkoutUrl,
      totalQuantity: cart.totalQuantity,
      subtotalAmount: cart.cost.subtotalAmount.amount,
      totalAmount: cart.cost.totalAmount.amount,
      taxAmount: cart.cost.totalTaxAmount?.amount ?? 0.0,
      currencyCode: cart.cost.totalAmount.currencyCode,
      isLoading: false,
      isUpdating: false,
      errorMessage: null,
    );
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(() {
  return CartController();
});
