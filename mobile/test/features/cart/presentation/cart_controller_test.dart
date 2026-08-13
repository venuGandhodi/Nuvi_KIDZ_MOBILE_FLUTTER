import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_repository.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/domain/shopify_cart.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/product/domain/product_variant.dart';

class FakeShopifyCartStorage extends ShopifyCartStorage {
  String? _cartId;

  @override
  Future<String?> getCartId() async => _cartId;

  @override
  Future<void> saveCartId(String cartId) async => _cartId = cartId;

  @override
  Future<void> clearCartId() async => _cartId = null;
}

class FakeShopifyCartRepository extends ShopifyCartRepository {
  ShopifyCart? currentCart;

  @override
  Future<ShopifyCart?> getCart(String cartId) async => currentCart;

  @override
  Future<ShopifyCart> createCart({
    required String variantId,
    required int quantity,
  }) async {
    currentCart = ShopifyCart(
      id: 'gid://shopify/Cart/fake_cart_1',
      totalQuantity: quantity,
      checkoutUrl: 'https://shopify.com/checkout/1',
      cost: ShopifyCartCost(
        subtotalAmount: ShopifyCartMoney(amount: 799.0 * quantity),
        totalAmount: ShopifyCartMoney(amount: 799.0 * quantity),
      ),
      lines: [
        ShopifyCartLine(
          id: 'gid://shopify/CartLine/line_1',
          quantity: quantity,
          merchandiseVariantId: variantId,
          title: '3-4Y',
          productTitle: 'Boys Dino T-Shirt',
          productHandle: 'boys-dino-tshirt',
          price: const ShopifyCartMoney(amount: 799.0),
          selectedOptions: const {'Size': '3-4Y'},
        ),
      ],
    );
    return currentCart!;
  }

  @override
  Future<ShopifyCart> addItem({
    required String cartId,
    required String variantId,
    required int quantity,
  }) async {
    final prevQty = currentCart?.totalQuantity ?? 0;
    final newQty = prevQty + quantity;
    currentCart = ShopifyCart(
      id: cartId,
      totalQuantity: newQty,
      checkoutUrl: 'https://shopify.com/checkout/1',
      cost: ShopifyCartCost(
        subtotalAmount: ShopifyCartMoney(amount: 799.0 * newQty),
        totalAmount: ShopifyCartMoney(amount: 799.0 * newQty),
      ),
      lines: [
        ShopifyCartLine(
          id: 'gid://shopify/CartLine/line_1',
          quantity: newQty,
          merchandiseVariantId: variantId,
          title: '3-4Y',
          productTitle: 'Boys Dino T-Shirt',
          productHandle: 'boys-dino-tshirt',
          price: const ShopifyCartMoney(amount: 799.0),
          selectedOptions: const {'Size': '3-4Y'},
        ),
      ],
    );
    return currentCart!;
  }

  @override
  Future<ShopifyCart> updateQuantity({
    required String cartId,
    required String lineId,
    required int quantity,
  }) async {
    currentCart = ShopifyCart(
      id: cartId,
      totalQuantity: quantity,
      checkoutUrl: 'https://shopify.com/checkout/1',
      cost: ShopifyCartCost(
        subtotalAmount: ShopifyCartMoney(amount: 799.0 * quantity),
        totalAmount: ShopifyCartMoney(amount: 799.0 * quantity),
      ),
      lines: [
        ShopifyCartLine(
          id: lineId,
          quantity: quantity,
          merchandiseVariantId: 'gid://shopify/ProductVariant/v1',
          title: '3-4Y',
          productTitle: 'Boys Dino T-Shirt',
          productHandle: 'boys-dino-tshirt',
          price: const ShopifyCartMoney(amount: 799.0),
          selectedOptions: const {'Size': '3-4Y'},
        ),
      ],
    );
    return currentCart!;
  }

  @override
  Future<ShopifyCart> removeItem({
    required String cartId,
    required String lineId,
  }) async {
    currentCart = const ShopifyCart(
      id: 'gid://shopify/Cart/fake_cart_1',
      totalQuantity: 0,
      checkoutUrl: 'https://shopify.com/checkout/1',
      cost: ShopifyCartCost(
        subtotalAmount: ShopifyCartMoney(amount: 0.0),
        totalAmount: ShopifyCartMoney(amount: 0.0),
      ),
      lines: [],
    );
    return currentCart!;
  }
}

void main() {
  late ProviderContainer container;
  late FakeShopifyCartRepository fakeRepo;
  late FakeShopifyCartStorage fakeStorage;

  final sampleProduct = const Product(
    id: 'boys-dino-tshirt',
    handle: 'boys-dino-tshirt',
    title: 'Boys Dino T-Shirt',
    price: '₹799',
    variants: [
      ProductVariant(
        id: 'gid://shopify/ProductVariant/v1',
        title: '3-4Y',
        priceAmount: 799.0,
        currencyCode: 'INR',
      ),
    ],
  );

  setUp(() {
    fakeRepo = FakeShopifyCartRepository();
    fakeStorage = FakeShopifyCartStorage();

    container = ProviderContainer(
      overrides: [
        shopifyCartRepositoryProvider.overrideWithValue(fakeRepo),
        shopifyCartStorageProvider.overrideWithValue(fakeStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartController Tests', () {
    test('initial state is empty after loadCart', () async {
      final controller = container.read(cartControllerProvider.notifier);
      await controller.loadCart();
      final state = container.read(cartControllerProvider);

      expect(state.isLoading, isFalse);
      expect(state.items, isEmpty);
      expect(state.totalItemCount, equals(0));
      expect(state.subtotal, equals(0.0));
      expect(state.grandTotal, equals(0.0));
    });

    test('addItem creates Shopify cart and updates state', () async {
      final controller = container.read(cartControllerProvider.notifier);
      await controller.loadCart();
      await controller.addItem(
        product: sampleProduct,
        shopifyVariantId: 'gid://shopify/ProductVariant/v1',
        selectedSize: '3-4Y',
        quantity: 2,
      );

      final state = container.read(cartControllerProvider);
      expect(state.cartId, equals('gid://shopify/Cart/fake_cart_1'));
      expect(state.items.length, equals(1));
      expect(state.totalItemCount, equals(2));
      expect(state.subtotal, equals(1598.0));
      expect(state.formattedSubtotal, equals('₹1598'));
      expect(state.checkoutUrl, equals('https://shopify.com/checkout/1'));
    });

    test('updateQuantity and removeItem update calculations', () async {
      final controller = container.read(cartControllerProvider.notifier);
      await controller.loadCart();
      await controller.addItem(
        product: sampleProduct,
        shopifyVariantId: 'gid://shopify/ProductVariant/v1',
        selectedSize: '3-4Y',
        quantity: 1,
      );

      var state = container.read(cartControllerProvider);
      final itemId = state.items.first.id;

      await controller.updateQuantity(itemId, 3);
      state = container.read(cartControllerProvider);
      expect(state.totalItemCount, equals(3));
      expect(state.subtotal, equals(2397.0));

      await controller.removeItem(itemId);
      state = container.read(cartControllerProvider);
      expect(state.items, isEmpty);
      expect(state.totalItemCount, equals(0));
      expect(state.subtotal, equals(0.0));
    });
  });
}
