import '../../shopify/data/shopify_product_mapper.dart';
import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/age_filter.dart';
import '../domain/category.dart';
import '../domain/home_hero.dart';
import '../domain/product.dart';
import 'home_repository.dart';

class ShopifyHomeRepository implements HomeRepository {
  final ShopifyStorefrontClient client;
  final MockHomeRepository _fallbackRepo = MockHomeRepository();

  ShopifyHomeRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  @override
  Future<HomeHero?> getHero() async {
    try {
      final data = await client.query(query: ShopifyQueries.getHomeHero);

      if (data['metaobjects'] != null && data['metaobjects']['nodes'] != null) {
        final nodes = data['metaobjects']['nodes'] as List<dynamic>;
        if (nodes.isNotEmpty && nodes.first is Map<String, dynamic>) {
          return ShopifyProductMapper.mapToHomeHero(
            nodes.first as Map<String, dynamic>,
          );
        }
      }
    } catch (_) {
      // Fallthrough
    }

    return _fallbackRepo.getHero();
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getCollections,
        variables: {'first': 10},
      );

      final categories = <Category>[];
      if (data['collections'] != null && data['collections']['edges'] != null) {
        final edges = data['collections']['edges'] as List<dynamic>;
        for (final edge in edges) {
          final node = edge['node'] as Map<String, dynamic>?;
          if (node != null) {
            categories.add(ShopifyProductMapper.mapToCategory(node));
          }
        }
      }

      if (categories.isNotEmpty) return categories;
    } catch (_) {
      // Fallthrough
    }

    return _fallbackRepo.getCategories();
  }

  @override
  Future<List<AgeFilter>> getAgeFilters() async {
    return _fallbackRepo.getAgeFilters();
  }

  @override
  Future<List<Product>> getBestSellers() async {
    final products = <Product>[];

    try {
      // 1. Try fetching from most-selling-items collection
      final data = await client.query(
        query: ShopifyQueries.getCollectionByHandle,
        variables: {'handle': 'most-selling-items', 'firstProducts': 10},
      );

      final collection = data['collection'];
      if (collection != null &&
          collection['products'] != null &&
          collection['products']['edges'] != null) {
        final edges = collection['products']['edges'] as List<dynamic>;
        for (final edge in edges) {
          final node = edge['node'] as Map<String, dynamic>?;
          if (node != null) {
            products.add(ShopifyProductMapper.mapToProduct(node));
          }
        }
      }
    } catch (_) {
      // Fallthrough
    }

    // 2. Fallback: fetch all products if collection empty
    if (products.isEmpty) {
      try {
        final data = await client.query(
          query: ShopifyQueries.getProducts,
          variables: {'first': 10},
        );

        if (data['products'] != null && data['products']['edges'] != null) {
          final edges = data['products']['edges'] as List<dynamic>;
          for (final edge in edges) {
            final node = edge['node'] as Map<String, dynamic>?;
            if (node != null) {
              products.add(ShopifyProductMapper.mapToProduct(node));
            }
          }
        }
      } catch (_) {
        // Fallthrough
      }
    }

    return products.isNotEmpty ? products : _fallbackRepo.getBestSellers();
  }
}
