import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/shopify/data/shopify_storefront_client.dart';
import 'package:nuvi_kidz/features/support/data/support_repository.dart';
import 'package:nuvi_kidz/features/support/domain/store_policy.dart';

class _FakeClient extends ShopifyStorefrontClient {
  final bool pageFails;

  _FakeClient({this.pageFails = false})
    : super(domain: 'test.myshopify.com', storefrontAccessToken: 'test');

  @override
  Future<Map<String, dynamic>> query({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    if (query.contains('page(')) {
      if (pageFails) throw Exception('scope');
      return {
        'page': {'title': 'Size Guide', 'body': '<p>0-6M: 62cm</p>'},
      };
    }
    return {
      'shop': {
        'refundPolicy': {
          'title': 'Refund policy',
          'body': '<p>Returns within 7&nbsp;days.</p><ul><li>Unworn</li></ul>',
        },
        'shippingPolicy': null,
        'privacyPolicy': {'title': 'Privacy policy', 'body': '<p>We care.</p>'},
        'termsOfService': {'title': 'Terms', 'body': ''},
      },
    };
  }
}

void main() {
  test('reads policies and the size guide from Shopify', () async {
    final c = await SupportRepository(
      client: _FakeClient(),
    ).getSupportContent();
    expect(c.all.map((p) => p.title), [
      'Size Guide',
      'Refund policy',
      'Privacy policy',
    ]);
    expect(c.refundPolicy?.body, 'Returns within 7 days.\n\n• Unworn');
    expect(c.shippingPolicy, isNull);
    expect(c.termsOfService, isNull);
  });

  test('a missing size guide page does not break the policies', () async {
    final c = await SupportRepository(
      client: _FakeClient(pageFails: true),
    ).getSupportContent();
    expect(c.sizeGuide, isNull);
    expect(c.privacyPolicy?.title, 'Privacy policy');
  });

  test('plainText strips tags and decodes entities', () {
    expect(
      StorePolicy.plainText('<h2>Hi &amp; welcome</h2><p>Line<br>two</p>'),
      'Hi & welcome\n\nLine\n\ntwo',
    );
  });
}
