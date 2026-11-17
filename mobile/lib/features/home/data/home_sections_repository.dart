import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../category/domain/menu_category.dart';
import '../../shopify/data/shopify_product_mapper.dart';
import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/home_hero.dart';

/// Optional Home sections read from Shopify. Each returns empty/null when the
/// store hasn't set the content up, so the section simply stays hidden (no
/// mock fallback).
class HomeSectionsRepository {
  /// Shopify menu (Content → Menus) whose items are the occasion tiles.
  static const occasionMenuHandle = 'shop-by-occasion';

  /// Metaobject type for the "Styled by NUVI" banner.
  static const styledBannerType = 'styled_banner';

  final ShopifyStorefrontClient client;

  HomeSectionsRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  Future<List<MenuCategory>> getOccasions() async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getMenu,
        variables: {'handle': occasionMenuHandle},
      );
      final menu = data['menu'];
      if (menu is Map<String, dynamic>) {
        return ShopifyProductMapper.mapToMenuCategories(menu);
      }
    } catch (_) {}
    return const [];
  }

  Future<HomeHero?> getStyledBanner() async {
    try {
      final data = await client.query(query: _styledBannerQuery);
      final nodes = data['metaobjects']?['nodes'];
      if (nodes is List && nodes.isNotEmpty) {
        final banner = ShopifyProductMapper.mapToHomeHero(
          nodes.first as Map<String, dynamic>,
        );
        return banner.isActive ? banner : null;
      }
    } catch (_) {}
    return null;
  }

  static const String _styledBannerQuery =
      '''
    query GetStyledBanner {
      metaobjects(type: "$styledBannerType", first: 1) {
        nodes {
          id
          handle
          fields {
            key
            value
            reference {
              ... on MediaImage {
                image {
                  url
                  altText
                }
              }
            }
          }
        }
      }
    }
  ''';
}

final homeSectionsRepositoryProvider = Provider<HomeSectionsRepository>(
  (ref) => HomeSectionsRepository(),
);

final occasionMenuProvider = FutureProvider<List<MenuCategory>>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getOccasions(),
);

final styledBannerProvider = FutureProvider<HomeHero?>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getStyledBanner(),
);
