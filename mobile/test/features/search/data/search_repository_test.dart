import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/search/data/search_repository.dart';
import 'package:nuvi_kidz/features/search/domain/search_filter_state.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';

class MockShopifyStorefrontClient implements ShopifyStorefrontClient {
  Map<String, dynamic>? responseToReturn;
  bool shouldThrow = false;
  String? lastQuery;
  Map<String, dynamic>? lastVariables;

  @override
  Future<Map<String, dynamic>> query({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    lastQuery = query;
    lastVariables = variables;
    if (shouldThrow) {
      throw Exception('Network connection failed');
    }
    return responseToReturn ?? {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockShopifyStorefrontClient mockClient;
  late ShopifySearchRepository repository;

  setUp(() {
    mockClient = MockShopifyStorefrontClient();
    repository = ShopifySearchRepository(client: mockClient);
  });

  group('ShopifySearchRepository Tests', () {
    test('1. Successful search returns mapped products and pageInfo', () async {
      mockClient.responseToReturn = {
        'products': {
          'pageInfo': {'hasNextPage': true, 'endCursor': 'cursor_123'},
          'edges': [
            {
              'cursor': 'cursor_1',
              'node': {
                'id': 'gid://shopify/Product/101',
                'title': 'Organic Cotton Dream Romper',
                'handle': 'dream-romper',
                'descriptionHtml': '<p>Soft organic cotton</p>',
                'images': {
                  'edges': [
                    {
                      'node': {
                        'url': 'https://example.com/romper.jpg',
                        'altText': 'Romper image',
                      },
                    },
                  ],
                },
                'variants': {
                  'edges': [
                    {
                      'node': {
                        'id': 'gid://shopify/ProductVariant/201',
                        'title': '0-6M / Sage',
                        'availableForSale': true,
                        'price': {'amount': '799.00', 'currencyCode': 'INR'},
                        'compareAtPrice': {
                          'amount': '999.00',
                          'currencyCode': 'INR',
                        },
                        'selectedOptions': [
                          {'name': 'Size', 'value': '0-6M'},
                          {'name': 'Color', 'value': 'Sage'},
                        ],
                      },
                    },
                  ],
                },
              },
            },
          ],
        },
      };

      final result = await repository.search(
        filterState: const SearchFilterState(query: 'romper'),
      );

      expect(result.products.length, 1);
      expect(result.products.first.title, 'Organic Cotton Dream Romper');
      expect(result.products.first.price, '₹799');
      expect(result.products.first.salePrice, '₹799');
      expect(result.products.first.compareAtPrice, '₹999');
      expect(result.pageInfo.hasNextPage, isTrue);
      expect(result.pageInfo.endCursor, 'cursor_123');
      expect(mockClient.lastVariables?['query'], 'romper');
      expect(mockClient.lastVariables?['sortKey'], 'RELEVANCE');
      expect(mockClient.lastVariables?['reverse'], isFalse);
    });

    test(
      '2. Empty search results return empty list and hasNextPage false',
      () async {
        mockClient.responseToReturn = {
          'products': {
            'pageInfo': {'hasNextPage': false, 'endCursor': null},
            'edges': [],
          },
        };

        final result = await repository.search(
          filterState: const SearchFilterState(query: 'nonexistent'),
        );

        expect(result.products, isEmpty);
        expect(result.pageInfo.hasNextPage, isFalse);
        expect(result.pageInfo.endCursor, isNull);
      },
    );

    test('3. Storefront API network exception is wrapped and thrown', () async {
      mockClient.shouldThrow = true;

      expect(
        () => repository.search(
          filterState: const SearchFilterState(query: 'romper'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      '4. Sort options and pagination cursor are correctly passed in variables',
      () async {
        mockClient.responseToReturn = {
          'products': {
            'pageInfo': {'hasNextPage': false, 'endCursor': null},
            'edges': [],
          },
        };

        await repository.search(
          filterState: const SearchFilterState(
            query: 'dress',
            sortOption: SearchSortOption.priceHighLow,
          ),
          first: 10,
          after: 'cursor_page_1',
        );

        expect(mockClient.lastVariables?['first'], 10);
        expect(mockClient.lastVariables?['after'], 'cursor_page_1');
        expect(mockClient.lastVariables?['sortKey'], 'PRICE');
        expect(mockClient.lastVariables?['reverse'], isTrue);
        expect(mockClient.lastVariables?['query'], 'dress');
      },
    );

    test(
      '5. Filter state correctly builds query string with inStock and category',
      () async {
        mockClient.responseToReturn = {
          'products': {
            'pageInfo': {'hasNextPage': false, 'endCursor': null},
            'edges': [],
          },
        };

        await repository.search(
          filterState: const SearchFilterState(
            query: 'cardigan',
            category: 'Knitwear',
            color: 'Sage',
            inStockOnly: true,
          ),
        );

        final queryString = mockClient.lastVariables?['query'] as String;
        expect(queryString, contains('cardigan'));
        expect(queryString, contains('product_type:Knitwear'));
        expect(queryString, contains('tag:Sage'));
        expect(queryString, contains('available_for_sale:true'));
      },
    );
  });
}
