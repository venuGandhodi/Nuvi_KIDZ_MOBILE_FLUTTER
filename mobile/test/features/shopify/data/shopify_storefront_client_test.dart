import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';

void main() {
  group('ShopifyStorefrontClient Tests', () {
    test(
      'query returns data when HTTP status is 200 and data exists',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'products': {
                  'edges': [
                    {
                      'node': {
                        'id': 'gid://shopify/Product/1',
                        'title': 'Test Item',
                      },
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
          apiVersion: '2026-04',
          storefrontAccessToken: 'mock-token',
          httpClient: mockClient,
        );

        final data = await client.query(query: 'query { products }');
        expect(data['products'], isNotNull);
      },
    );

    test('query throws ShopifyClientException on HTTP non-200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );

      expect(
        () => client.query(query: 'query { products }'),
        throwsA(isA<ShopifyClientException>()),
      );
    });

    test('query throws ShopifyClientException on GraphQL error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'errors': [
              {'message': 'Invalid query field'},
            ],
          }),
          200,
        );
      });

      final client = ShopifyStorefrontClient(
        domain: 'mock.myshopify.com',
        httpClient: mockClient,
      );

      expect(
        () => client.query(query: 'query { products }'),
        throwsA(isA<ShopifyClientException>()),
      );
    });
  });
}
