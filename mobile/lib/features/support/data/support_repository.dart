import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shopify/data/shopify_storefront_client.dart';
import '../domain/store_policy.dart';

/// Reads store policies (Settings → Policies in Shopify admin) and the
/// optional `size-guide` page from the Storefront API.
class SupportRepository {
  /// Shopify page (Online Store → Pages) shown as the size guide.
  static const sizeGuideHandle = 'size-guide';

  /// Contact address shown on Help & Support.
  static const supportEmail = 'support@nuvikidz.com';

  final ShopifyStorefrontClient client;

  SupportRepository({ShopifyStorefrontClient? client})
    : client = client ?? ShopifyStorefrontClient();

  Future<SupportContent> getSupportContent() async {
    final data = await client.query(query: _policiesQuery);
    final shop = data['shop'];
    StorePolicy? policy(String key) =>
        shop is Map ? _toPolicy(shop[key]) : null;
    return SupportContent(
      sizeGuide: await _sizeGuide(),
      refundPolicy: policy('refundPolicy'),
      shippingPolicy: policy('shippingPolicy'),
      privacyPolicy: policy('privacyPolicy'),
      termsOfService: policy('termsOfService'),
    );
  }

  /// Pages need their own scope; a missing page or scope just hides it.
  Future<StorePolicy?> _sizeGuide() async {
    try {
      final data = await client.query(
        query: _pageQuery,
        variables: {'handle': sizeGuideHandle},
      );
      return _toPolicy(data['page']);
    } catch (_) {
      return null;
    }
  }

  static StorePolicy? _toPolicy(Object? raw) {
    if (raw is! Map) return null;
    final title = (raw['title'] as String?)?.trim() ?? '';
    final html = raw['body'] as String? ?? '';
    final body = StorePolicy.plainText(html);
    if (title.isEmpty || body.isEmpty) return null;
    return StorePolicy(title: title, body: body, html: html);
  }

  static const String _policiesQuery = '''
    query GetShopPolicies {
      shop {
        refundPolicy { title body }
        shippingPolicy { title body }
        privacyPolicy { title body }
        termsOfService { title body }
      }
    }
  ''';

  static const String _pageQuery = r'''
    query GetPage($handle: String!) {
      page(handle: $handle) { title body }
    }
  ''';
}

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepository(),
);

final supportContentProvider = FutureProvider<SupportContent>(
  (ref) => ref.read(supportRepositoryProvider).getSupportContent(),
);
