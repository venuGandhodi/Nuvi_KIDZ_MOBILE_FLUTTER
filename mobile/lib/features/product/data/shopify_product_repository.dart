import '../../home/domain/product.dart';
import '../../shopify/data/shopify_product_mapper.dart';
import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import 'product_repository.dart';

class ShopifyProductRepository implements ProductRepository {
  final ShopifyStorefrontClient client;
  final MockProductRepository _fallbackRepo = MockProductRepository();

  ShopifyProductRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  @override
  Future<Product?> getProductById(String productId) async {
    try {
      // 1. Try fetching by Shopify handle (e.g. boys-dino-tshirt, boys-check-shirt, etc.)
      final dataByHandle = await client.query(
        query: ShopifyQueries.getProductByHandle,
        variables: {'handle': productId},
      );

      if (dataByHandle['product'] != null) {
        return ShopifyProductMapper.mapToProduct(dataByHandle['product']);
      }
    } catch (_) {
      // Fallthrough to ID lookup if handle lookup fails
    }

    try {
      // 2. Try fetching by GraphQL GID (e.g. gid://shopify/Product/12345)
      final dataById = await client.query(
        query: ShopifyQueries.getProductById,
        variables: {'id': productId},
      );

      if (dataById['node'] != null) {
        return ShopifyProductMapper.mapToProduct(dataById['node']);
      }
    } catch (_) {
      // Fallthrough to fallback lookup
    }

    // 3. Fallback: fetch list of products and match by ID or handle
    try {
      final allProductsData = await client.query(
        query: ShopifyQueries.getProducts,
        variables: {'first': 20},
      );

      if (allProductsData['products'] != null &&
          allProductsData['products']['edges'] != null) {
        final edges = allProductsData['products']['edges'] as List<dynamic>;
        for (final edge in edges) {
          final node = edge['node'] as Map<String, dynamic>?;
          if (node != null) {
            final mapped = ShopifyProductMapper.mapToProduct(node);
            if (mapped.id == productId || mapped.handle == productId) {
              return mapped;
            }
          }
        }
      }
    } catch (_) {
      // Final fallback
    }

    return _fallbackRepo.getProductById(productId);
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId) async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getProducts,
        variables: {'first': 10},
      );

      final list = <Product>[];
      if (data['products'] != null && data['products']['edges'] != null) {
        final edges = data['products']['edges'] as List<dynamic>;
        for (final edge in edges) {
          final node = edge['node'] as Map<String, dynamic>?;
          if (node != null) {
            final mapped = ShopifyProductMapper.mapToProduct(node);
            if (mapped.id != productId && mapped.handle != productId) {
              list.add(mapped);
            }
          }
        }
      }
      if (list.isNotEmpty) return list;
    } catch (e) {
      // Fallthrough
    }
    return _fallbackRepo.getRelatedProducts(productId);
  }
}
