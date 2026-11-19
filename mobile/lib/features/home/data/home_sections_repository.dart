import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../category/domain/menu_category.dart';
import '../../shopify/data/shopify_product_mapper.dart';
import '../../shopify/data/shopify_queries.dart';
import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/home_hero.dart';
import '../domain/promo_content.dart';
import '../domain/wardrobe.dart';

/// Optional Home sections read from Shopify. Each returns empty/null when the
/// store hasn't set the content up, so the section simply stays hidden (no
/// mock fallback).
class HomeSectionsRepository {
  /// Shopify menu (Content → Menus) whose items are the occasion tiles.
  static const occasionMenuHandle = 'shop-by-occasion';

  /// Metaobject type for the "Styled by NUVI" banner.
  static const styledBannerType = 'styled_banner';

  /// Shopify menu whose items are the Festive Picks category circles.
  static const festiveMenuHandle = 'festive-picks';

  /// Metaobject type for the "Festive Picks" banner.
  static const festiveBannerType = 'festive_banner';

  /// Metaobject type for the "Deal Zone" banner.
  static const dealBannerType = 'deal_banner';

  /// Metaobject type for the Deal Zone offer tiles (one entry per tile).
  static const dealTileType = 'deal_tile';

  /// Metaobject types for image tiles uploaded separately from collections
  /// (one entry per tile). When a type has no entries the section falls back
  /// to its Shopify menu and the collection images.
  static const categoryCardType = 'category_card';
  static const occasionTileType = 'occasion_tile';
  static const festiveCategoryType = 'festive_category';

  /// Category grid under Deal Zone: metaobject `shop_category` (fields as
  /// above plus `badge_text`), else the Shopify menu `shop-by-category`.
  static const shopCategoryType = 'shop_category';
  static const shopCategoryMenuHandle = 'shop-by-category';

  /// Wardrobe blocks (Girl's / Boy's Wardrobe): metaobject `wardrobe_section`
  /// with list fields `categories` and `top_picks` pointing at
  /// `wardrobe_tile` entries.
  static const wardrobeSectionType = 'wardrobe_section';

  final ShopifyStorefrontClient client;

  HomeSectionsRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  /// Girls / Boys / New Born cards. Empty means use the main menu.
  Future<List<MenuCategory>> getCategoryCards() => _tiles(categoryCardType);

  Future<List<MenuCategory>> getOccasions() =>
      _tilesOrMenu(occasionTileType, occasionMenuHandle);

  Future<List<MenuCategory>> getFestiveCategories() =>
      _tilesOrMenu(festiveCategoryType, festiveMenuHandle);

  /// Active wardrobe blocks in `position` order; blocks with no tiles are
  /// skipped.
  Future<List<WardrobeSection>> getWardrobeSections() async {
    try {
      final data = await client.query(
        query: _wardrobeQuery,
        variables: {'type': wardrobeSectionType, 'first': 10},
      );
      final nodes = data['metaobjects']?['nodes'];
      if (nodes is! List) return const [];
      final sections = <(int, int, WardrobeSection)>[];
      for (final (i, node) in nodes.indexed) {
        if (node is! Map) continue;
        final fields = _fieldMap(node['fields']);
        if (!_isActive(fields)) continue;
        final title = fields['title']?.value?.trim() ?? '';
        final categories = _wardrobeTiles(node['fields'], 'categories');
        final picks = _wardrobeTiles(node['fields'], 'top_picks');
        if (title.isEmpty || (categories.isEmpty && picks.isEmpty)) continue;
        sections.add((
          _position(fields),
          i,
          WardrobeSection(
            title: title,
            picksTitle: _nonEmpty(fields['picks_title']?.value) ?? 'Top Picks',
            picksHighlight: _nonEmpty(fields['picks_highlight']?.value) ?? '',
            categories: categories,
            topPicks: picks,
          ),
        ));
      }
      sections.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
      return [for (final s in sections) s.$3];
    } catch (_) {
      return const [];
    }
  }

  /// Key → value/image for a metaobject's `fields` list.
  static Map<String, _Field> _fieldMap(Object? raw) => {
    if (raw is List)
      for (final f in raw)
        if (f is Map && f['key'] is String)
          f['key'] as String: _Field(
            f['value'] as String?,
            _imageUrlOf(f['reference']),
          ),
  };

  static String? _imageUrlOf(Object? reference) {
    if (reference is! Map) return null;
    final image = reference['image'];
    return image is Map ? image['url'] as String? : null;
  }

  /// Tiles linked from the list field [key], in the order picked in Shopify.
  static List<WardrobeTile> _wardrobeTiles(Object? rawFields, String key) {
    if (rawFields is! List) return const [];
    Object? refs;
    for (final f in rawFields) {
      if (f is Map && f['key'] == key && f['references'] is Map) {
        refs = (f['references'] as Map)['nodes'];
        break;
      }
    }
    if (refs is! List) return const [];
    return [
      for (final r in refs)
        if (r is Map) ?_wardrobeTile(_fieldMap(r['fields'])),
    ];
  }

  static WardrobeTile? _wardrobeTile(Map<String, _Field> f) {
    final title = f['title']?.value?.trim() ?? '';
    final handle = f['collection_handle']?.value?.trim() ?? '';
    if (!_isActive(f) || title.isEmpty || handle.isEmpty) return null;
    return WardrobeTile(
      title: title,
      collectionHandle: handle,
      imageUrl: f['image']?.imageUrl,
      badgeText: _nonEmpty(f['badge_text']?.value),
      offerText: _nonEmpty(f['offer_text']?.value),
    );
  }

  Future<List<MenuCategory>> getShopCategories() =>
      _tilesOrMenu(shopCategoryType, shopCategoryMenuHandle);

  Future<List<MenuCategory>> _tilesOrMenu(String type, String menu) async {
    final tiles = await _tiles(type);
    return tiles.isNotEmpty ? tiles : _menu(menu);
  }

  /// Active image tiles of [type] (fields: title, image, collection_handle,
  /// position, is_active), sorted by position then Shopify entry order.
  Future<List<MenuCategory>> _tiles(String type) async {
    final entries = <(int, int, MenuCategory)>[];
    final list = await _metaobjects(type, first: 20);
    for (final (i, f) in list.indexed) {
      final title = f['title']?.value ?? '';
      final handle = f['collection_handle']?.value ?? '';
      if (!_isActive(f) || title.isEmpty || handle.isEmpty) continue;
      entries.add((
        _position(f),
        i,
        MenuCategory(
          id: '$type-$i-$handle',
          title: title,
          imageUrl: f['image']?.imageUrl,
          collectionHandle: handle,
          badgeText: _nonEmpty(f['badge_text']?.value),
        ),
      ));
    }
    entries.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [for (final e in entries) e.$3];
  }

  static String? _nonEmpty(String? v) =>
      v == null || v.trim().isEmpty ? null : v.trim();

  /// Entries without a valid `position` sort after numbered ones.
  static int _position(Map<String, _Field> f) =>
      int.tryParse(f['position']?.value?.trim() ?? '') ?? 1 << 30;

  Future<PromoBanner?> getFestiveBanner() => _banner(festiveBannerType);

  Future<PromoBanner?> getDealBanner() => _banner(dealBannerType);

  Future<List<DealTile>> getDealTiles() async {
    final tiles = <(int, int, DealTile)>[];
    for (final (i, f) in (await _metaobjects(dealTileType, first: 6)).indexed) {
      final title = f['title']?.value ?? '';
      final offer = f['offer_text']?.value ?? '';
      final handle = f['collection_handle']?.value ?? '';
      if (!_isActive(f) || title.isEmpty || handle.isEmpty) continue;
      tiles.add((
        _position(f),
        i,
        DealTile(
          title: title,
          offerText: offer,
          imageUrl: f['image']?.imageUrl,
          collectionHandle: handle,
        ),
      ));
    }
    tiles.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [for (final t in tiles) t.$3];
  }

  Future<PromoBanner?> _banner(String type) async {
    final list = await _metaobjects(type, first: 1);
    if (list.isEmpty) return null;
    final f = list.first;
    final title = f['title']?.value ?? '';
    final handle = f['collection_handle']?.value ?? '';
    if (!_isActive(f) || title.isEmpty || handle.isEmpty) return null;
    final badge = f['badge_text']?.value;
    return PromoBanner(
      title: title,
      subtitle: f['subtitle']?.value ?? '',
      imageUrl: f['image']?.imageUrl,
      buttonText: f['button_text']?.value ?? 'Shop Now',
      collectionHandle: handle,
      badgeText: badge == null || badge.isEmpty ? null : badge,
    );
  }

  /// Missing `is_active` counts as active; "false"/"0" hides the entry.
  static bool _isActive(Map<String, _Field> f) {
    final v = f['is_active']?.value;
    return v == null || !(v == 'false' || v == '0');
  }

  /// Field maps (key → value/image) of up to [first] metaobjects of [type].
  Future<List<Map<String, _Field>>> _metaobjects(
    String type, {
    required int first,
  }) async {
    try {
      final data = await client.query(
        query: _metaobjectsQuery,
        variables: {'type': type, 'first': first},
      );
      final nodes = data['metaobjects']?['nodes'];
      if (nodes is! List) return const [];
      return [
        for (final node in nodes)
          if (node is Map<String, dynamic> && node['fields'] is List)
            {
              for (final field in node['fields'] as List)
                if (field is Map<String, dynamic> && field['key'] is String)
                  field['key'] as String: _Field(
                    field['value'] as String?,
                    field['reference']?['image']?['url'] as String?,
                  ),
            },
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<List<MenuCategory>> _menu(String handle) async {
    try {
      final data = await client.query(
        query: ShopifyQueries.getMenu,
        variables: {'handle': handle},
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

  static const String _metaobjectsQuery = r'''
    query GetMetaobjects($type: String!, $first: Int!) {
      metaobjects(type: $type, first: $first) {
        nodes {
          fields {
            key
            value
            reference {
              ... on MediaImage {
                image {
                  url
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String _wardrobeQuery = r'''
    query GetWardrobeSections($type: String!, $first: Int!) {
      metaobjects(type: $type, first: $first) {
        nodes {
          fields {
            key
            value
            references(first: 12) {
              nodes {
                ... on Metaobject {
                  fields {
                    key
                    value
                    reference {
                      ... on MediaImage {
                        image {
                          url
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

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

class _Field {
  final String? value;
  final String? _imageUrl;

  const _Field(this.value, this._imageUrl);

  /// Image from a file reference, or a plain URL value.
  String? get imageUrl =>
      _imageUrl ?? (value != null && value!.startsWith('http') ? value : null);
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

final festiveBannerProvider = FutureProvider<PromoBanner?>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getFestiveBanner(),
);

final festiveCategoriesProvider = FutureProvider<List<MenuCategory>>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getFestiveCategories(),
);

final dealBannerProvider = FutureProvider<PromoBanner?>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getDealBanner(),
);

final dealTilesProvider = FutureProvider<List<DealTile>>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getDealTiles(),
);

final categoryCardsProvider = FutureProvider<List<MenuCategory>>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getCategoryCards(),
);

final shopCategoriesProvider = FutureProvider<List<MenuCategory>>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getShopCategories(),
);

final wardrobeSectionsProvider = FutureProvider<List<WardrobeSection>>(
  (ref) => ref.read(homeSectionsRepositoryProvider).getWardrobeSections(),
);
