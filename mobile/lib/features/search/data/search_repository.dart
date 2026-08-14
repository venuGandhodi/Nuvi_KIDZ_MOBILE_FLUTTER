import '../../home/domain/product.dart';
import '../../shopify/data/shopify_product_mapper.dart';
import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/page_info.dart';
import '../domain/search_filter_state.dart';

class SearchResult {
  final List<Product> products;
  final PageInfo pageInfo;

  const SearchResult({required this.products, required this.pageInfo});
}

abstract class SearchRepository {
  Future<SearchResult> search({
    required SearchFilterState filterState,
    int first = 20,
    String? after,
  });
}

class ShopifySearchRepository implements SearchRepository {
  final ShopifyStorefrontClient client;

  ShopifySearchRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  @override
  Future<SearchResult> search({
    required SearchFilterState filterState,
    int first = 20,
    String? after,
  }) async {
    final queryString = filterState.toShopifyQueryString();
    final sortOption = filterState.sortOption;

    final variables = <String, dynamic>{
      'first': first,
      if (after != null && after.isNotEmpty) 'after': after,
      if (queryString.isNotEmpty) 'query': queryString,
      'sortKey': sortOption.shopifySortKey,
      'reverse': sortOption.shopifyReverse,
    };

    try {
      final data = await client.query(
        query: ShopifyQueries.searchProducts,
        variables: variables,
      );

      final productsData = data['products'];
      if (productsData != null) {
        final edges = productsData['edges'] as List<dynamic>? ?? [];
        final products = <Product>[];

        for (final edge in edges) {
          if (edge is Map<String, dynamic> && edge['node'] != null) {
            final node = edge['node'] as Map<String, dynamic>;
            final product = ShopifyProductMapper.mapToProduct(node);

            // Client-side refinement for attributes not strictly indexed by Shopify text search (e.g. precise price bounds, size)
            if (_matchesClientFilters(product, filterState)) {
              products.add(product);
            }
          }
        }

        final pageInfo = PageInfo.fromJson(
          productsData['pageInfo'] as Map<String, dynamic>?,
        );

        return SearchResult(products: products, pageInfo: pageInfo);
      }

      return const SearchResult(
        products: [],
        pageInfo: PageInfo(hasNextPage: false),
      );
    } catch (e) {
      // Re-throw formatted exception so controller can display friendly error state
      throw Exception('Failed to search products from Shopify: $e');
    }
  }

  bool _matchesClientFilters(Product product, SearchFilterState filterState) {
    // Check Size filter if specified
    if (filterState.size != null && filterState.size!.isNotEmpty) {
      final hasSize =
          product.availableSizes?.any(
            (s) => s.toLowerCase() == filterState.size!.toLowerCase(),
          ) ??
          false;
      if (!hasSize) return false;
    }

    // Check Price range if specified
    final price = _extractPriceNumber(product.salePrice ?? product.price);
    if (filterState.minPrice != null && price < filterState.minPrice!) {
      return false;
    }
    if (filterState.maxPrice != null && price > filterState.maxPrice!) {
      return false;
    }

    return true;
  }

  double _extractPriceNumber(String priceStr) {
    final clean = priceStr
        .replaceAll('₹', '')
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(clean) ?? 0.0;
  }
}
