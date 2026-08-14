import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../home/domain/product.dart';
import '../../product/data/product_repository.dart';
import '../../product/data/shopify_product_repository.dart';

abstract class WishlistRepository {
  Future<List<String>> getWishlistProductIds();
  Future<void> addToWishlist(String productId, {String? variantId});
  Future<void> removeFromWishlist(String productId);
  Future<List<Product>> hydrateProducts(List<String> productIds);
}

class SupabaseWishlistRepository implements WishlistRepository {
  final supabase.SupabaseClient? _supabase;
  final ProductRepository _productRepository;
  final Set<String> _localFallbackIds = {};

  SupabaseWishlistRepository({
    supabase.SupabaseClient? supabaseClient,
    ProductRepository? productRepository,
  }) : _supabase = supabaseClient,
       _productRepository = productRepository ?? ShopifyProductRepository();

  supabase.SupabaseClient? get _client {
    if (_supabase != null) return _supabase;
    try {
      return supabase.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get _isAuthenticated => _client?.auth.currentUser != null;
  String? get _userId => _client?.auth.currentUser?.id;

  @override
  Future<List<String>> getWishlistProductIds() async {
    if (_isAuthenticated && _userId != null) {
      try {
        final response = await _client!
            .from('wishlist')
            .select('shopify_product_id')
            .eq('user_id', _userId!);

        final ids = (response as List<dynamic>)
            .map((item) => item['shopify_product_id'] as String)
            .toList();

        // Sync local cache with remote records
        _localFallbackIds
          ..clear()
          ..addAll(ids);

        return ids;
      } catch (_) {
        // Fallback to local cache if network/database query fails
        return _localFallbackIds.toList();
      }
    }

    return _localFallbackIds.toList();
  }

  @override
  Future<void> addToWishlist(String productId, {String? variantId}) async {
    _localFallbackIds.add(productId);

    if (_isAuthenticated && _userId != null) {
      try {
        final payload = <String, dynamic>{
          'user_id': _userId!,
          'shopify_product_id': productId,
        };
        if (variantId != null) {
          payload['shopify_variant_id'] = variantId;
        }
        await _client!.from('wishlist').upsert(payload);
      } catch (_) {
        // Optimistic update retained in local set
      }
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    _localFallbackIds.remove(productId);

    if (_isAuthenticated && _userId != null) {
      try {
        await _client!
            .from('wishlist')
            .delete()
            .eq('user_id', _userId!)
            .eq('shopify_product_id', productId);
      } catch (_) {
        // Optimistic removal retained in local set
      }
    }
  }

  @override
  Future<List<Product>> hydrateProducts(List<String> productIds) async {
    final hydrated = <Product>[];
    for (final id in productIds) {
      try {
        final product = await _productRepository.getProductById(id);
        if (product != null) {
          hydrated.add(product.copyWith(isFavorite: true));
        }
      } catch (_) {
        // Ignore single product fetch errors and continue
      }
    }
    return hydrated;
  }
}
