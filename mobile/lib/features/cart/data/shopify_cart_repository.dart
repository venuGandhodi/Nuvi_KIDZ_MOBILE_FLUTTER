import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/shopify_cart.dart';

class ShopifyCartException implements Exception {
  final String message;
  final List<dynamic>? userErrors;

  ShopifyCartException(this.message, {this.userErrors});

  @override
  String toString() => 'ShopifyCartException: $message';
}

class ShopifyCartRepository {
  final ShopifyStorefrontClient client;

  ShopifyCartRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  Future<ShopifyCart?> getCart(String cartId) async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getCart,
        variables: {'id': cartId},
      );

      final cartJson = data['cart'] as Map<String, dynamic>?;
      if (cartJson != null) {
        return ShopifyCart.fromJson(cartJson);
      }
      return null;
    } catch (e) {
      if (e is ShopifyClientException) {
        // If cart is invalid/expired on Shopify, return null so client resets
        return null;
      }
      rethrow;
    }
  }

  Future<ShopifyCart> createCart({
    required String variantId,
    required int quantity,
  }) async {
    final input = {
      'lines': [
        {'merchandiseId': variantId, 'quantity': quantity},
      ],
    };

    final data = await client.query(
      query: ShopifyQueries.cartCreate,
      variables: {'input': input},
    );

    final payload = data['cartCreate'] as Map<String, dynamic>?;
    _checkUserErrors(payload, 'Failed to create cart');

    final cartJson = payload?['cart'] as Map<String, dynamic>?;
    if (cartJson == null) {
      throw ShopifyCartException(
        'Shopify did not return a cart on cartCreate.',
      );
    }

    return ShopifyCart.fromJson(cartJson);
  }

  Future<ShopifyCart> addItem({
    required String cartId,
    required String variantId,
    required int quantity,
  }) async {
    final lines = [
      {'merchandiseId': variantId, 'quantity': quantity},
    ];

    final data = await client.query(
      query: ShopifyQueries.cartLinesAdd,
      variables: {'cartId': cartId, 'lines': lines},
    );

    final payload = data['cartLinesAdd'] as Map<String, dynamic>?;
    _checkUserErrors(payload, 'Failed to add item to bag');

    final cartJson = payload?['cart'] as Map<String, dynamic>?;
    if (cartJson == null) {
      throw ShopifyCartException(
        'Shopify did not return an updated cart on cartLinesAdd.',
      );
    }

    return ShopifyCart.fromJson(cartJson);
  }

  Future<ShopifyCart> updateQuantity({
    required String cartId,
    required String lineId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return removeItem(cartId: cartId, lineId: lineId);
    }

    final lines = [
      {'id': lineId, 'quantity': quantity},
    ];

    final data = await client.query(
      query: ShopifyQueries.cartLinesUpdate,
      variables: {'cartId': cartId, 'lines': lines},
    );

    final payload = data['cartLinesUpdate'] as Map<String, dynamic>?;
    _checkUserErrors(payload, 'Failed to update item quantity');

    final cartJson = payload?['cart'] as Map<String, dynamic>?;
    if (cartJson == null) {
      throw ShopifyCartException(
        'Shopify did not return an updated cart on cartLinesUpdate.',
      );
    }

    return ShopifyCart.fromJson(cartJson);
  }

  Future<ShopifyCart> removeItem({
    required String cartId,
    required String lineId,
  }) async {
    final data = await client.query(
      query: ShopifyQueries.cartLinesRemove,
      variables: {
        'cartId': cartId,
        'lineIds': [lineId],
      },
    );

    final payload = data['cartLinesRemove'] as Map<String, dynamic>?;
    _checkUserErrors(payload, 'Failed to remove item from bag');

    final cartJson = payload?['cart'] as Map<String, dynamic>?;
    if (cartJson == null) {
      throw ShopifyCartException(
        'Shopify did not return an updated cart on cartLinesRemove.',
      );
    }

    return ShopifyCart.fromJson(cartJson);
  }

  Future<ShopifyCart?> refreshCart(String cartId) async {
    return getCart(cartId);
  }

  void _checkUserErrors(Map<String, dynamic>? payload, String fallbackMessage) {
    if (payload == null) return;
    if (payload['userErrors'] != null) {
      final userErrors = payload['userErrors'] as List<dynamic>;
      if (userErrors.isNotEmpty) {
        final first = userErrors.first as Map<String, dynamic>;
        final msg = first['message'] as String? ?? fallbackMessage;
        throw ShopifyCartException(msg, userErrors: userErrors);
      }
    }
  }
}
