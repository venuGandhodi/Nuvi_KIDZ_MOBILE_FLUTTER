import '../../home/domain/product.dart';
import '../../shopify/data/shopify_product_mapper.dart';
import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/category_detail.dart';
import '../domain/category_filter.dart';
import '../domain/menu_category.dart';
import 'category_repository.dart';

class ShopifyCategoryRepository implements CategoryRepository {
  final ShopifyStorefrontClient client;
  final MockCategoryRepository _fallbackRepo = MockCategoryRepository();

  ShopifyCategoryRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  @override
  Future<CategoryDetail> getCategoryDetail(String categoryId) async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getCollectionByHandle,
        variables: {'handle': categoryId, 'firstProducts': 20},
      );

      final collection = data['collection'];
      if (collection != null) {
        int count = 0;
        if (collection['products'] != null &&
            collection['products']['edges'] != null) {
          count = (collection['products']['edges'] as List<dynamic>).length;
        }
        return ShopifyProductMapper.mapToCategoryDetail(collection, count);
      }
    } catch (_) {
      // Fallthrough
    }

    return _fallbackRepo.getCategoryDetail(categoryId);
  }

  @override
  Future<List<Product>> getCategoryProducts(
    String categoryId, {
    FilterState? filter,
    SortOption? sort,
  }) async {
    List<Product> products = [];
    bool collectionFound = false;

    try {
      // 1. Fetch by collection handle
      final data = await client.query(
        query: ShopifyQueries.getCollectionByHandle,
        variables: {'handle': categoryId, 'firstProducts': 20},
      );

      final collection = data['collection'];
      if (collection != null) {
        collectionFound = true;
        if (collection['products'] != null &&
            collection['products']['edges'] != null) {
          final edges = collection['products']['edges'] as List<dynamic>;
          for (final edge in edges) {
            final node = edge['node'] as Map<String, dynamic>?;
            if (node != null) {
              products.add(ShopifyProductMapper.mapToProduct(node));
            }
          }
        }
      }
    } catch (_) {
      // Fallthrough
    }

    // 2. Fallback: only fetch the generic product feed when the collection
    // itself couldn't be resolved (invalid/stale handle). A collection that
    // *was* found but is genuinely empty must stay empty here — substituting
    // unrelated products would mislabel them under the wrong category name.
    if (!collectionFound && products.isEmpty) {
      try {
        final data = await client.query(
          query: ShopifyQueries.getProducts,
          variables: {'first': 20},
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

    if (!collectionFound && products.isEmpty) {
      return _fallbackRepo.getCategoryProducts(
        categoryId,
        filter: filter,
        sort: sort,
      );
    }

    // Apply sorting logic locally
    if (sort != null) {
      switch (sort) {
        case SortOption.priceLowToHigh:
          products.sort((a, b) => _parsePrice(a).compareTo(_parsePrice(b)));
          break;
        case SortOption.priceHighToLow:
          products.sort((a, b) => _parsePrice(b).compareTo(_parsePrice(a)));
          break;
        case SortOption.rating:
          products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case SortOption.newest:
          products.sort(
            (a, b) => (b.badgeText == 'NEW' ? 1 : 0).compareTo(
              a.badgeText == 'NEW' ? 1 : 0,
            ),
          );
          break;
        case SortOption.featured:
          break;
      }
    }

    return products;
  }

  double _parsePrice(Product p) {
    final str = p.salePrice ?? p.price;
    final cleanStr = str
        .replaceAll('₹', '')
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(cleanStr) ?? 0.0;
  }

  @override
  Future<List<MenuCategory>> getCategoryMenu({
    String handle = 'main-menu',
  }) async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getMenu,
        variables: {'handle': handle},
      );

      final menu = data['menu'];
      if (menu != null) {
        final categories = ShopifyProductMapper.mapToMenuCategories(
          menu as Map<String, dynamic>,
        );
        if (categories.isNotEmpty) {
          return categories;
        }
      }
    } catch (_) {
      // Fallthrough
    }

    return _fallbackRepo.getCategoryMenu(handle: handle);
  }
}
