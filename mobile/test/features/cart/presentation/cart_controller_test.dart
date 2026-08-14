import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_repository.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/domain/shopify_cart.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/checkout/data/shopify_checkout_service.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_repository.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/product/domain/product_variant.dart';

class FakeCustomerRepoForCart extends ShopifyCustomerRepository {
  int loadCustomerCount = 0;
  bool shouldFail = false;

  @override
  Future<CustomerSyncResult> getCustomerProfile() async {
    loadCustomerCount++;
    if (shouldFail) {
      throw Exception('Simulated network error');
    }
    return const CustomerSyncResult(status: CustomerSyncStatus.notLinked);
  }
}

class FakeShopifyCheckoutService extends ShopifyCheckoutService {
  String? lastPreloadedUrl;
  String? lastPresentedUrl;
  bool presentSuccess = true;
  ValueChanged<String>? onCompletedCallback;
  VoidCallback? onCancelledCallback;
  ValueChanged<String>? onFailedCallback;

  @override
  void setEventHandlers({
    ValueChanged<String>? onCompleted,
    VoidCallback? onCancelled,
    ValueChanged<String>? onFailed,
  }) {
    onCompletedCallback = onCompleted;
    onCancelledCallback = onCancelled;
    onFailedCallback = onFailed;
  }

  @override
  Future<void> preloadCheckout(String? checkoutUrl) async {
    lastPreloadedUrl = checkoutUrl;
  }

  @override
  Future<bool> presentCheckout(String? checkoutUrl) async {
    lastPresentedUrl = checkoutUrl;
    return presentSuccess;
  }
}

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
    String? buyerEmail,
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

  @override
  Future<ShopifyCart> updateBuyerIdentity({
    required String cartId,
    required String email,
  }) async {
    final prev = currentCart;
    currentCart = ShopifyCart(
      id: cartId,
      totalQuantity: prev?.totalQuantity ?? 0,
      checkoutUrl: 'https://shopify.com/checkout/1?email=$email',
      cost:
          prev?.cost ??
          const ShopifyCartCost(
            subtotalAmount: ShopifyCartMoney(amount: 0.0),
            totalAmount: ShopifyCartMoney(amount: 0.0),
          ),
      lines: prev?.lines ?? const [],
    );
    return currentCart!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late FakeShopifyCartRepository fakeRepo;
  late FakeShopifyCartStorage fakeStorage;
  late FakeShopifyCheckoutService fakeCheckoutService;
  late FakeCustomerRepoForCart fakeCustomerRepo;

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
    fakeCheckoutService = FakeShopifyCheckoutService();
    fakeCustomerRepo = FakeCustomerRepoForCart();

    container = ProviderContainer(
      overrides: [
        shopifyCartRepositoryProvider.overrideWithValue(fakeRepo),
        shopifyCartStorageProvider.overrideWithValue(fakeStorage),
        shopifyCheckoutServiceProvider.overrideWithValue(fakeCheckoutService),
        shopifyCustomerRepositoryProvider.overrideWithValue(fakeCustomerRepo),
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

    test(
      'updateBuyerIdentity updates cart state with latest checkoutUrl',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 1,
        );

        final success = await controller.updateBuyerIdentity(
          'user@example.com',
        );
        expect(success, isTrue);

        final state = container.read(cartControllerProvider);
        expect(state.checkoutUrl, contains('email=user@example.com'));
      },
    );

    test(
      'prepareCheckoutUrl returns latest checkoutUrl with buyer identity when email present',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 1,
        );

        final checkoutUrl = await controller.prepareCheckoutUrl(
          userEmail: 'newuser@gmail.com',
        );

        expect(checkoutUrl, contains('email=newuser@gmail.com'));
      },
    );

    test(
      'prepareCheckoutUrl falls back gracefully when email is null or unauthenticated',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 1,
        );

        final checkoutUrl = await controller.prepareCheckoutUrl(
          userEmail: null,
        );
        expect(checkoutUrl, equals('https://shopify.com/checkout/1'));
      },
    );

    test(
      'preloadCheckout calls checkout service preload with current checkoutUrl',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 1,
        );

        await controller.preloadCheckout();
        expect(
          fakeCheckoutService.lastPreloadedUrl,
          equals('https://shopify.com/checkout/1'),
        );
      },
    );

    test(
      'launchInAppCheckout presents checkout and registers callbacks',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 1,
        );

        final success = await controller.launchInAppCheckout(
          userEmail: 'user@example.com',
        );
        expect(success, isTrue);
        expect(
          fakeCheckoutService.lastPresentedUrl,
          contains('email=user@example.com'),
        );

        final state = container.read(cartControllerProvider);
        expect(state.checkoutStatus, equals(CheckoutStatus.inCheckout));
      },
    );

    test(
      'onCheckoutCompleted clears cart and sets completed status and orderId',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 2,
        );

        await controller.launchInAppCheckout();

        // Trigger completion callback
        await controller.onCheckoutCompleted('gid://shopify/Order/1001');

        // Allow microtask for background customer refresh to run
        await Future.delayed(Duration.zero);

        final state = container.read(cartControllerProvider);
        expect(state.items, isEmpty);
        expect(state.totalItemCount, equals(0));
        expect(state.checkoutStatus, equals(CheckoutStatus.completed));
        expect(state.lastCompletedOrderId, equals('gid://shopify/Order/1001'));
        expect(await fakeStorage.getCartId(), isNull);
        expect(fakeCustomerRepo.loadCustomerCount, greaterThanOrEqualTo(1));
      },
    );

    test(
      'onCheckoutCompleted remains completed even if background customer refresh fails',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 2,
        );

        fakeCustomerRepo.shouldFail = true;

        await controller.onCheckoutCompleted('gid://shopify/Order/1002');
        await Future.delayed(Duration.zero);

        final state = container.read(cartControllerProvider);
        expect(state.items, isEmpty);
        expect(state.totalItemCount, equals(0));
        expect(state.checkoutStatus, equals(CheckoutStatus.completed));
        expect(state.lastCompletedOrderId, equals('gid://shopify/Order/1002'));
        expect(await fakeStorage.getCartId(), isNull);
      },
    );

    test(
      'onCheckoutCancelled preserves cart items and sets cancelled status',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 2,
        );

        await controller.launchInAppCheckout();

        // Trigger cancellation callback
        fakeCheckoutService.onCancelledCallback?.call();

        final state = container.read(cartControllerProvider);
        expect(state.items.length, 1);
        expect(state.totalItemCount, equals(2));
        expect(state.checkoutStatus, equals(CheckoutStatus.cancelled));
        expect(await fakeStorage.getCartId(), isNotNull);
      },
    );

    test(
      'onCheckoutFailed preserves cart items and sets error message',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 2,
        );

        await controller.launchInAppCheckout();

        // Trigger failure callback
        fakeCheckoutService.onFailedCallback?.call('Card was declined.');

        final state = container.read(cartControllerProvider);
        expect(state.items.length, 1);
        expect(state.totalItemCount, equals(2));
        expect(state.checkoutStatus, equals(CheckoutStatus.failed));
        expect(state.errorMessage, equals('Card was declined.'));
      },
    );

    test(
      'launchInAppCheckout ignores duplicate taps when already checking out',
      () async {
        final controller = container.read(cartControllerProvider.notifier);
        await controller.loadCart();
        await controller.addItem(
          product: sampleProduct,
          shopifyVariantId: 'gid://shopify/ProductVariant/v1',
          selectedSize: '3-4Y',
          quantity: 1,
        );

        // First tap
        final first = await controller.launchInAppCheckout();
        expect(first, isTrue);

        // Second tap while inCheckout
        final second = await controller.launchInAppCheckout();
        expect(second, isFalse);
      },
    );
  });
}
