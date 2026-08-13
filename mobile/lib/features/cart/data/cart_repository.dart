import '../domain/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<List<CartItem>> addItem(CartItem item);
  Future<List<CartItem>> updateQuantity(String cartItemId, int quantity);
  Future<List<CartItem>> removeItem(String cartItemId);
  Future<List<CartItem>> clearCart();
}

class MockCartRepository implements CartRepository {
  final List<CartItem> _items = [];

  MockCartRepository({List<CartItem>? initialItems}) {
    if (initialItems != null) {
      _items.addAll(initialItems);
    }
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    await Future.delayed(const Duration(milliseconds: 20));
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> addItem(CartItem item) async {
    await Future.delayed(const Duration(milliseconds: 20));
    final existingIndex = _items.indexWhere(
      (existing) =>
          existing.product.id == item.product.id &&
          existing.selectedColor?.id == item.selectedColor?.id &&
          existing.selectedSize == item.selectedSize,
    );

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> updateQuantity(String cartItemId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 20));
    if (quantity <= 0) {
      _items.removeWhere((item) => item.id == cartItemId);
    } else {
      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> removeItem(String cartItemId) async {
    await Future.delayed(const Duration(milliseconds: 20));
    _items.removeWhere((item) => item.id == cartItemId);
    return List.unmodifiable(_items);
  }

  @override
  Future<List<CartItem>> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 20));
    _items.clear();
    return List.unmodifiable(_items);
  }
}
