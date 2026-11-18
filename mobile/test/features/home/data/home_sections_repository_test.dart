import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/data/home_sections_repository.dart';
import 'package:nuvi_kidz/features/home/domain/promo_content.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';

/// Returns canned metaobject nodes per type; throws for unknown types.
class _FakeClient extends ShopifyStorefrontClient {
  final Map<String, List<Map<String, dynamic>>> byType;
  final Map<String, Map<String, dynamic>> menus;

  _FakeClient(this.byType, {this.menus = const {}})
    : super(domain: 'test.myshopify.com', storefrontAccessToken: 'test');

  @override
  Future<Map<String, dynamic>> query({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    final menu = menus[variables?['handle']];
    if (menu != null) return {'menu': menu};
    final nodes = byType[variables?['type']];
    if (nodes == null) throw Exception('no data');
    return {
      'metaobjects': {'nodes': nodes},
    };
  }
}

Map<String, dynamic> _node(Map<String, String> values, {String? image}) => {
  'fields': [
    for (final e in values.entries) {'key': e.key, 'value': e.value},
    if (image != null)
      {
        'key': 'image',
        'value': 'gid://shopify/MediaImage/1',
        'reference': {
          'image': {'url': image},
        },
      },
  ],
};

void main() {
  group('HomeSectionsRepository promo content', () {
    test('parses the festive banner from its metaobject', () async {
      final repo = HomeSectionsRepository(
        client: _FakeClient({
          'festive_banner': [
            _node({
              'title': 'Festive Picks',
              'subtitle': 'Traditional charm',
              'button_text': 'Shop Festive Collection',
              'collection_handle': 'festive',
            }, image: 'https://cdn.test/festive.jpg'),
          ],
        }),
      );
      final banner = await repo.getFestiveBanner();
      expect(banner?.title, 'Festive Picks');
      expect(banner?.subtitle, 'Traditional charm');
      expect(banner?.buttonText, 'Shop Festive Collection');
      expect(banner?.collectionHandle, 'festive');
      expect(banner?.imageUrl, 'https://cdn.test/festive.jpg');
      expect(banner?.badgeText, isNull);
    });

    test('hides an inactive banner or one without a collection', () async {
      final repo = HomeSectionsRepository(
        client: _FakeClient({
          'festive_banner': [
            _node({
              'title': 'Festive Picks',
              'collection_handle': 'festive',
              'is_active': 'false',
            }),
          ],
          'deal_banner': [
            _node({'title': 'Deal Zone'}),
          ],
        }),
      );
      expect(await repo.getFestiveBanner(), isNull);
      expect(await repo.getDealBanner(), isNull);
    });

    test('reads the deal banner badge text', () async {
      final repo = HomeSectionsRepository(
        client: _FakeClient({
          'deal_banner': [
            _node({
              'title': 'Deal Zone',
              'collection_handle': 'deals',
              'badge_text': 'Up to 40% OFF',
            }),
          ],
        }),
      );
      final banner = await repo.getDealBanner();
      expect(banner?.badgeText, 'Up to 40% OFF');
      expect(banner?.buttonText, 'Shop Now');
    });

    test('returns active deal tiles and skips incomplete ones', () async {
      final repo = HomeSectionsRepository(
        client: _FakeClient({
          'deal_tile': [
            _node({
              'title': 'Tops & Shirts',
              'offer_text': 'Flat 20% OFF',
              'collection_handle': 'tops',
            }, image: 'https://cdn.test/tops.jpg'),
            _node({'title': 'No handle', 'offer_text': '10% OFF'}),
            _node({
              'title': 'Hidden',
              'offer_text': '50% OFF',
              'collection_handle': 'hidden',
              'is_active': 'false',
            }),
          ],
        }),
      );
      final tiles = await repo.getDealTiles();
      expect(tiles, hasLength(1));
      expect(tiles.first.title, 'Tops & Shirts');
      expect(tiles.first.imageUrl, 'https://cdn.test/tops.jpg');
    });

    test('returns nothing when Shopify fails', () async {
      final repo = HomeSectionsRepository(client: _FakeClient({}));
      expect(await repo.getFestiveBanner(), isNull);
      expect(await repo.getDealTiles(), isEmpty);
    });
  });

  group('HomeSectionsRepository image tiles', () {
    final occasionMenu = {
      'id': 'm',
      'title': 'Shop by Occasion',
      'items': [
        {
          'id': 'i1',
          'title': 'Menu Winter',
          'resource': {
            'handle': 'winter',
            'image': {'url': 'https://cdn.test/collection.jpg'},
          },
          'items': [],
        },
      ],
    };

    test('uses uploaded occasion tiles sorted by position', () async {
      final repo = HomeSectionsRepository(
        client: _FakeClient(
          {
            'occasion_tile': [
              _node({
                'title': 'Birthday',
                'collection_handle': 'birthday',
                'position': '2',
              }, image: 'https://cdn.test/birthday.png'),
              _node({
                'title': 'Winter',
                'collection_handle': 'winter',
                'position': '1',
              }, image: 'https://cdn.test/winter.png'),
              _node({'title': 'No position', 'collection_handle': 'casual'}),
              _node({
                'title': 'Off',
                'collection_handle': 'off',
                'is_active': 'false',
              }),
            ],
          },
          menus: {'shop-by-occasion': occasionMenu},
        ),
      );
      final tiles = await repo.getOccasions();
      expect(tiles.map((t) => t.title), ['Winter', 'Birthday', 'No position']);
      expect(tiles.first.imageUrl, 'https://cdn.test/winter.png');
      expect(tiles.first.collectionHandle, 'winter');
    });

    test('falls back to the menu and collection image', () async {
      final repo = HomeSectionsRepository(
        client: _FakeClient({}, menus: {'shop-by-occasion': occasionMenu}),
      );
      final tiles = await repo.getOccasions();
      expect(tiles.single.title, 'Menu Winter');
      expect(tiles.single.imageUrl, 'https://cdn.test/collection.jpg');
    });

    test('category cards are empty when none are uploaded', () async {
      final repo = HomeSectionsRepository(client: _FakeClient({}));
      expect(await repo.getCategoryCards(), isEmpty);
    });
  });

  group('DealTile.offerLines', () {
    DealTile tile(String offer) =>
        DealTile(title: 't', offerText: offer, collectionHandle: 'h');

    test('splits the lead words from the percentage', () {
      expect(tile('Up to 30% OFF').offerLines, ('Up to', '30% OFF'));
      expect(tile('Flat 20% OFF').offerLines, ('Flat', '20% OFF'));
    });

    test('keeps text without a lead or percentage on one line', () {
      expect(tile('40% OFF').offerLines, (null, '40% OFF'));
      expect(tile('Buy 1 Get 1').offerLines, (null, 'Buy 1 Get 1'));
    });
  });
}
