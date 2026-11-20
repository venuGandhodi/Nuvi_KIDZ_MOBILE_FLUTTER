/// A store policy or help page from Shopify (returns, shipping, size
/// guide…), with its HTML body reduced to plain paragraphs.
class StorePolicy {
  final String title;
  final String body;

  const StorePolicy({required this.title, required this.body});

  /// Plain text from Shopify's HTML: block tags become line breaks, other
  /// tags are dropped and common entities decoded.
  static String plainText(String html) {
    var t = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</(p|div|h[1-6]|li|tr)>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'<[^>]+>'), '');
    const entities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&rsquo;': '’',
      '&lsquo;': '‘',
      '&ndash;': '–',
      '&mdash;': '—',
      '&rdquo;': '”',
      '&ldquo;': '“',
    };
    entities.forEach((k, v) => t = t.replaceAll(k, v));
    return t
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .join('\n\n');
  }
}

/// Everything the Help & Support screen shows, all from Shopify.
class SupportContent {
  /// Size guide from the Shopify page with handle `size-guide`, if any.
  final StorePolicy? sizeGuide;
  final StorePolicy? refundPolicy;
  final StorePolicy? shippingPolicy;
  final StorePolicy? privacyPolicy;
  final StorePolicy? termsOfService;

  const SupportContent({
    this.sizeGuide,
    this.refundPolicy,
    this.shippingPolicy,
    this.privacyPolicy,
    this.termsOfService,
  });

  List<StorePolicy> get all => [
    ?sizeGuide,
    ?refundPolicy,
    ?shippingPolicy,
    ?privacyPolicy,
    ?termsOfService,
  ];
}
