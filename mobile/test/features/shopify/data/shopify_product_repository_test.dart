import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuvi_kidz/features/product/data/shopify_product_repository.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';

void main() {
  group('ShopifyProductRepository Tests', () {
    test('getProductById retrieves product by handle from Shopify', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'product': {
                'id': 'gid://shopify/Product/101',
                'title': 'Boys Dino T-Shirt',
                'handle': 'boys-dino-tshirt',
                'descriptionHtml': '<p>Dino graphic tee</p>',
                'images': {'edges': []},
                'variants': {
                  'edges': [
                    {
                      'node': {
                        'id': 'gid://shopify/ProductVariant/501',
                        'title': '2-3Y',
                        'availableForSale': true,
                        'price': {'amount': '599.0', 'currencyCode': 'INR'},
                      },
                    },
                  ],
                },
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
      final repo = ShopifyProductRepository(client: client);

      final product = await repo.getProductById('boys-dino-tshirt');

      expect(product, isNotNull);
      expect(product!.title, equals('Boys Dino T-Shirt'));
      expect(product.price, equals('₹599'));
    });
  });
}
