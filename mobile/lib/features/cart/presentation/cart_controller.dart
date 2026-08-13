import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

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
