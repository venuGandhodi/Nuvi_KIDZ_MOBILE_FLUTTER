import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_repository.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';

void main() {
  group('ShopifyCartRepository Tests', () {
    final sampleCartJson = {
      'id': 'gid://shopify/Cart/c1_12345',
      'totalQuantity': 2,
      'checkoutUrl': 'https://muu1gj-t6.myshopify.com/checkouts/cn/test-cart',
      'cost': {
        'subtotalAmount': {'amount': '1598.0', 'currencyCode': 'INR'},
        'totalAmount': {'amount': '1598.0', 'currencyCode': 'INR'},
        'totalTaxAmount': {'amount': '0.0', 'currencyCode': 'INR'},
      },
      'lines': {
        'nodes': [
          {
            'id': 'gid://shopify/CartLine/line_1',
            'quantity': 2,
            'merchandise': {
              'id': 'gid://shopify/ProductVariant/v_101',
              'title': '3-4Y / Red',
              'price': {'amount': '799.0', 'currencyCode': 'INR'},
              'product': {
                'id': 'gid://shopify/Product/p_101',
                'title': 'Boys Dino T-Shirt',
                'handle': 'boys-dino-tshirt',
                'images': {
                  'nodes': [
                    {'url': 'https://cdn.shopify.com/dino.jpg'},
                  ],
                },
              },
              'selectedOptions': [
                {'name': 'Size', 'value': '3-4Y'},
                {'name': 'Color', 'value': 'Red'},
              ],
            },
          },
        ],
      },
    };

    test('createCart creates a new Shopify cart successfully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'cartCreate': {'cart': sampleCartJson, 'userErrors': []},
            },
          }),
          200,
        );
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );
      final repo = ShopifyCartRepository(client: client);

      final cart = await repo.createCart(
        variantId: 'gid://shopify/ProductVariant/v_101',
        quantity: 2,
      );

      expect(cart.id, equals('gid://shopify/Cart/c1_12345'));
      expect(cart.totalQuantity, equals(2));
      expect(cart.cost.subtotalAmount.amount, equals(1598.0));
      expect(cart.lines.length, equals(1));
      expect(cart.lines.first.productTitle, equals('Boys Dino T-Shirt'));
      expect(cart.lines.first.selectedSize, equals('3-4Y'));
      expect(cart.lines.first.selectedColorName, equals('Red'));
      expect(cart.checkoutUrl, contains('checkouts'));
    });

    test(
      'createCart throws ShopifyCartException when userErrors returned',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'cartCreate': {
                  'cart': null,
                  'userErrors': [
                    {
                      'field': ['merchandiseId'],
                      'message': 'Variant not found',
                    },
                  ],
                },
              },
            }),
            200,
          );
        });

        final client = ShopifyStorefrontClient(
          domain: 'mock.myshopify.com',
          httpClient: mockClient,
        );
        final repo = ShopifyCartRepository(client: client);

        expect(
          () => repo.createCart(variantId: 'invalid_id', quantity: 1),
          throwsA(isA<ShopifyCartException>()),
        );
      },
    );

    test('getCart returns cart when found', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {'cart': sampleCartJson},
          }),
          200,
        );
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );
      final repo = ShopifyCartRepository(client: client);

      final cart = await repo.getCart('gid://shopify/Cart/c1_12345');
      expect(cart, isNotNull);
      expect(cart!.id, equals('gid://shopify/Cart/c1_12345'));
      expect(cart.cost.totalAmount.formatted, equals('₹1598'));
    });

    test('getCart returns null when cart does not exist', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {'cart': null},
          }),
          200,
        );
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );
      final repo = ShopifyCartRepository(client: client);

      final cart = await repo.getCart('non_existent_cart');
      expect(cart, isNull);
    });

    test('addItem calls cartLinesAdd and returns updated cart', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'cartLinesAdd': {'cart': sampleCartJson, 'userErrors': []},
            },
          }),
          200,
        );
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );
      final repo = ShopifyCartRepository(client: client);

      final cart = await repo.addItem(
        cartId: 'gid://shopify/Cart/c1_12345',
        variantId: 'gid://shopify/ProductVariant/v_101',
        quantity: 2,
      );

      expect(cart.lines.length, equals(1));
    });

    test(
      'updateQuantity calls cartLinesUpdate and returns updated cart',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'cartLinesUpdate': {'cart': sampleCartJson, 'userErrors': []},
              },
            }),
            200,
          );
        });

        final client = ShopifyStorefrontClient(
          domain: 'mock.myshopify.com',
          httpClient: mockClient,
        );
        final repo = ShopifyCartRepository(client: client);

        final cart = await repo.updateQuantity(
          cartId: 'gid://shopify/Cart/c1_12345',
          lineId: 'gid://shopify/CartLine/line_1',
          quantity: 3,
        );

        expect(cart.id, equals('gid://shopify/Cart/c1_12345'));
      },
    );

    test('removeItem calls cartLinesRemove and returns updated cart', () async {
      final emptyCartJson = {
        'id': 'gid://shopify/Cart/c1_12345',
        'totalQuantity': 0,
        'checkoutUrl': 'https://muu1gj-t6.myshopify.com/checkouts/cn/test-cart',
        'cost': {
          'subtotalAmount': {'amount': '0.0', 'currencyCode': 'INR'},
          'totalAmount': {'amount': '0.0', 'currencyCode': 'INR'},
        },
        'lines': {'nodes': []},
      };

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'cartLinesRemove': {'cart': emptyCartJson, 'userErrors': []},
            },
          }),
          200,
        );
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );
      final repo = ShopifyCartRepository(client: client);

      final cart = await repo.removeItem(
        cartId: 'gid://shopify/Cart/c1_12345',
        lineId: 'gid://shopify/CartLine/line_1',
      );

      expect(cart.totalQuantity, equals(0));
      expect(cart.lines, isEmpty);
    });
  });
}
