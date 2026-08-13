import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuvi_kidz/features/home/data/shopify_home_repository.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';

void main() {
  group('ShopifyHomeRepository Tests', () {
    test('getHero retrieves metaobject hero when available', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'metaobjects': {
                'nodes': [
                  {
                    'id': 'gid://shopify/Metaobject/1',
                    'fields': [
                      {'key': 'title', 'value': 'Custom Hero Title'},
                      {'key': 'description', 'value': 'Custom Description'},
                      {
                        'key': 'collection_handle',
                        'value': 'most-selling-items',
                      },
                    ],
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
      final repo = ShopifyHomeRepository(client: client);

      final hero = await repo.getHero();
      expect(hero, isNotNull);
      expect(hero!.title, equals('Custom Hero Title'));
      expect(hero.collectionHandle, equals('most-selling-items'));
    });

    test('getCategories retrieves Shopify collections with images', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'collections': {
                'edges': [
                  {
                    'node': {
                      'id': 'gid://shopify/Collection/10',
                      'title': 'Girls Clothing',
                      'handle': 'girls-clothing',
                      'image': {
                        'url': 'https://cdn.shopify.com/girls.jpg',
                        'altText': 'Girls',
                      },
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
        httpClient: mockClient,
      );
      final repo = ShopifyHomeRepository(client: client);

      final categories = await repo.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.first.name, equals('Girls Clothing'));
      expect(categories.first.handle, equals('girls-clothing'));
      expect(
        categories.first.imageUrl,
        equals('https://cdn.shopify.com/girls.jpg'),
      );
    });

    test('getBestSellers queries most-selling-items collection', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'collection': {
                'id': 'gid://shopify/Collection/20',
                'title': 'Most Selling Items',
                'products': {
                  'edges': [
                    {
                      'node': {
                        'id': 'gid://shopify/Product/99',
                        'title': 'Best Seller Romper',
                        'handle': 'best-seller-romper',
                        'images': {'edges': []},
                        'variants': {
                          'edges': [
                            {
                              'node': {
                                'id': 'gid://shopify/ProductVariant/1',
                                'title': 'Default Title',
                                'availableForSale': true,
                                'price': {
                                  'amount': '999.0',
                                  'currencyCode': 'INR',
                                },
                              },
                            },
                          ],
                        },
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
      final repo = ShopifyHomeRepository(client: client);

      final products = await repo.getBestSellers();
      expect(products, isNotEmpty);
      expect(products.first.title, equals('Best Seller Romper'));
      expect(products.first.price, equals('₹999'));
    });
  });
}
