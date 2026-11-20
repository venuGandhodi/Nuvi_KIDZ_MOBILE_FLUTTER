/// A store policy or help page from Shopify (returns, shipping, size
/// guide…), with its HTML body reduced to plain paragraphs.
class StorePolicy {
  final String title;
  final String body;

  /// Original HTML from Shopify (kept for tables, e.g. the size chart).
  final String html;

  const StorePolicy({required this.title, required this.body, this.html = ''});

  /// Rows of the first `<table>` in [html] (header row first), or empty.
  List<List<String>> get firstTable {
    final table = RegExp(
      r'<table[^>]*>(.*?)</table>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (table == null) return const [];
    final rows = <List<String>>[];
    for (final row in RegExp(
      r'<tr[^>]*>(.*?)</tr>',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(table.group(1)!)) {
      final cells = [
        for (final cell in RegExp(
          r'<t[hd][^>]*>(.*?)</t[hd]>',
          caseSensitive: false,
          dotAll: true,
        ).allMatches(row.group(1)!))
          plainText(cell.group(1)!).replaceAll('\n\n', ' '),
      ];
      if (cells.isNotEmpty) rows.add(cells);
    }
    return rows;
  }

  /// [body] without the table's text (to show around a rendered table).
  String get bodyWithoutTable => plainText(
    html.replaceAll(
      RegExp(r'<table[^>]*>.*?</table>', caseSensitive: false, dotAll: true),
      '',
    ),
  );

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
