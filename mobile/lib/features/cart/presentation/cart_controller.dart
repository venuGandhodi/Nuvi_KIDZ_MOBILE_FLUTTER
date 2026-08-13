import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';
import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return MockCartRepository();
});

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold<double>(0.0, (sum, item) => sum + item.lineTotal);

  double get shippingCost => items.isEmpty ? 0.0 : 5.0;

  double get estimatedTax => items.isEmpty ? 0.0 : (subtotal * 0.08);

  double get grandTotal => subtotal + shippingCost + estimatedTax;

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    // Initial fetch from repository
    Future.microtask(() => loadCart());
    return const CartState(isLoading: true);
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(cartRepositoryProvider);
      final items = await repo.getCartItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load cart.',
      );
    }
  }

  Future<void> addItem({
    required Product product,
    ProductColor? selectedColor,
    String? selectedSize,
    int quantity = 1,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      final repo = ref.read(cartRepositoryProvider);
      double rawPrice = 0.0;
      final priceClean = (product.salePrice ?? product.price)
          .replaceAll('\$', '')
          .replaceAll(',', '')
          .trim();
      rawPrice = double.tryParse(priceClean) ?? 0.0;

      final newItem = CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
        quantity: quantity,
        unitPrice: rawPrice,
      );

      final updatedItems = await repo.addItem(newItem);
      state = state.copyWith(items: updatedItems, isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to add item to cart.',
      );
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      final repo = ref.read(cartRepositoryProvider);
      final updatedItems = await repo.updateQuantity(cartItemId, quantity);
      state = state.copyWith(items: updatedItems, isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update quantity.',
      );
    }
  }

  Future<void> removeItem(String cartItemId) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      final repo = ref.read(cartRepositoryProvider);
      final updatedItems = await repo.removeItem(cartItemId);
      state = state.copyWith(items: updatedItems, isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to remove item.',
      );
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      final repo = ref.read(cartRepositoryProvider);
      final updatedItems = await repo.clearCart();
      state = state.copyWith(items: updatedItems, isUpdating: false);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to clear cart.',
      );
    }
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(() {
  return CartController();
});
