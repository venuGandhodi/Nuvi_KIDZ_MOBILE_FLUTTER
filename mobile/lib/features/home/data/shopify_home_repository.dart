import '../../../core/utils/nuvi_logger.dart';
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

  // Age categories are Shopify Metaobject-driven (type "age_category") and
  // intentionally do NOT fall back to mock/hardcoded data on failure or an
  // empty response — the "Shop by age" section is simply hidden by the UI
  // instead, so Shopify Admin stays the single source of truth.
  @override
  Future<List<AgeFilter>> getAgeFilters() async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getAgeCategories,
        variables: {'first': 20},
      );

      final metaobjects = data['metaobjects'];
      if (metaobjects != null && metaobjects['nodes'] != null) {
        final nodes = metaobjects['nodes'] as List<dynamic>;
        final ageFilters = <AgeFilter>[];

        for (final node in nodes) {
          if (node is Map<String, dynamic>) {
            final filter = ShopifyProductMapper.mapToAgeFilter(node);
            if (filter != null && filter.active) {
              ageFilters.add(filter);
            }
          }
        }

        ageFilters.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return ageFilters;
      }
    } catch (e) {
      nuviLog('NUVI-AGE-CATEGORY', 'Failed to load age categories: $e');
    }

    return [];
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
