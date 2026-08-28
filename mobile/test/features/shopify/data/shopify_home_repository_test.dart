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

  group('ShopifyHomeRepository getAgeFilters (Shopify Metaobject-driven)', () {
    Map<String, dynamic> ageCategoryNode({
      required String id,
      required String label,
      required String sortOrder,
      String active = 'true',
      bool includeImage = true,
      bool includeCollection = false,
    }) {
      return {
        'id': id,
        'handle': label,
        'fields': [
          {'key': 'active', 'value': active},
          {'key': 'age_label', 'value': label},
          if (includeImage)
            {
              'key': 'image',
              'value': 'gid://shopify/MediaImage/1',
              'reference': {
                'image': {'url': 'https://cdn.shopify.com/s/files/$id.png'},
              },
            },
          {'key': 'sort_order', 'value': sortOrder},
          if (includeCollection)
            {
              'key': 'collection',
              'value': 'gid://shopify/Collection/1',
              'reference': {'handle': '$label-clothing', 'title': label},
            },
        ],
      };
    }

    test(
      'returns all six Age Category entries when Shopify provides them',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'metaobjects': {
                  'nodes': [
                    ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '1'),
                    ageCategoryNode(id: 'g2', label: '3-6m', sortOrder: '2'),
                    ageCategoryNode(id: 'g3', label: '6-12m', sortOrder: '3'),
                    ageCategoryNode(id: 'g4', label: '1-2y', sortOrder: '4'),
                    ageCategoryNode(id: 'g5', label: '3-5y', sortOrder: '5'),
                    ageCategoryNode(id: 'g6', label: '6-8y', sortOrder: '6'),
                  ],
                },
              },
            }),
            200,
          );
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters.length, equals(6));
        expect(filters.map((f) => f.label), [
          '0-3m',
          '3-6m',
          '6-12m',
          '1-2y',
          '3-5y',
          '6-8y',
        ]);
      },
    );

    test(
      'orders entries ascending by Sort Order regardless of Shopify response order',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'metaobjects': {
                  'nodes': [
                    ageCategoryNode(id: 'g3', label: '6-12m', sortOrder: '3'),
                    ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '1'),
                    ageCategoryNode(id: 'g2', label: '3-6m', sortOrder: '2'),
                  ],
                },
              },
            }),
            200,
          );
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters.map((f) => f.label), ['0-3m', '3-6m', '6-12m']);
      },
    );

    test(
      'reflects an updated Sort Order in the UI order without any code change',
      () async {
        // 3-6m now sorts before 0-3m purely because Shopify changed the
        // stored Sort Order value — no hardcoded position exists in Flutter.
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'metaobjects': {
                  'nodes': [
                    ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '2'),
                    ageCategoryNode(id: 'g2', label: '3-6m', sortOrder: '1'),
                  ],
                },
              },
            }),
            200,
          );
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters.first.label, equals('3-6m'));
        expect(filters.last.label, equals('0-3m'));
      },
    );

    test('filters out entries where Active is false', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'metaobjects': {
                'nodes': [
                  ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '1'),
                  ageCategoryNode(
                    id: 'g2',
                    label: '3-6m',
                    sortOrder: '2',
                    active: 'false',
                  ),
                ],
              },
            },
          }),
          200,
        );
      });

      final repo = ShopifyHomeRepository(
        client: ShopifyStorefrontClient(
          domain: 'mock.myshopify.com',
          httpClient: mockClient,
        ),
      );

      final filters = await repo.getAgeFilters();
      expect(filters.length, equals(1));
      expect(filters.single.label, equals('0-3m'));
    });

    test('displays an entry once Active is true', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'metaobjects': {
                'nodes': [
                  ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '1'),
                ],
              },
            },
          }),
          200,
        );
      });

      final repo = ShopifyHomeRepository(
        client: ShopifyStorefrontClient(
          domain: 'mock.myshopify.com',
          httpClient: mockClient,
        ),
      );

      final filters = await repo.getAgeFilters();
      expect(filters.single.active, isTrue);
    });

    test(
      'handles a missing image on an entry without crashing or dropping it',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'metaobjects': {
                  'nodes': [
                    ageCategoryNode(
                      id: 'g1',
                      label: '0-3m',
                      sortOrder: '1',
                      includeImage: false,
                    ),
                  ],
                },
              },
            }),
            200,
          );
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters.single.label, equals('0-3m'));
        expect(filters.single.imageUrl, isNull);
      },
    );

    test(
      'handles a missing collection reference on one entry without failing the whole list',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'metaobjects': {
                  'nodes': [
                    ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '1'),
                    ageCategoryNode(
                      id: 'g2',
                      label: '3-6m',
                      sortOrder: '2',
                      includeCollection: true,
                    ),
                  ],
                },
              },
            }),
            200,
          );
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters.length, equals(2));
        expect(filters.first.collectionHandle, isNull);
        expect(filters.last.collectionHandle, equals('3-6m-clothing'));
      },
    );

    test(
      'returns an empty list (not hardcoded data) when Shopify returns zero entries',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'metaobjects': {'nodes': <dynamic>[]},
              },
            }),
            200,
          );
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters, isEmpty);
      },
    );

    test(
      'returns an empty list (not hardcoded data) when the Shopify request fails',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final repo = ShopifyHomeRepository(
          client: ShopifyStorefrontClient(
            domain: 'mock.myshopify.com',
            httpClient: mockClient,
          ),
        );

        final filters = await repo.getAgeFilters();
        expect(filters, isEmpty);
        // Explicitly not the old hardcoded fallback labels.
        expect(filters.any((f) => f.label == '0-3m'), isFalse);
      },
    );

    test('an entry beyond the original six automatically appears', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'metaobjects': {
                'nodes': [
                  ageCategoryNode(id: 'g1', label: '0-3m', sortOrder: '1'),
                  ageCategoryNode(id: 'g7', label: '8-10y', sortOrder: '7'),
                ],
              },
            },
          }),
          200,
        );
      });

      final repo = ShopifyHomeRepository(
        client: ShopifyStorefrontClient(
          domain: 'mock.myshopify.com',
          httpClient: mockClient,
        ),
      );

      final filters = await repo.getAgeFilters();
      expect(filters.any((f) => f.label == '8-10y'), isTrue);
    });
  });
}
