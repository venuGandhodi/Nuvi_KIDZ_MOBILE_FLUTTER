/// Promotional banner content (Festive Picks, Deal Zone) read from a Shopify
/// metaobject.
class PromoBanner {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String buttonText;
  final String collectionHandle;

  /// Optional tag text shown on the image, e.g. "Up to 40% OFF".
  final String? badgeText;

  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.collectionHandle,
    this.imageUrl,
    this.badgeText,
  });
}

/// One Deal Zone offer tile, e.g. "Flat 20% OFF" on Tops & Shirts.
class DealTile {
  final String title;
  final String offerText;
  final String? imageUrl;
  final String collectionHandle;

  const DealTile({
    required this.title,
    required this.offerText,
    required this.collectionHandle,
    this.imageUrl,
  });

  /// Splits the offer for the two-line badge: "Up to 30% OFF" becomes
  /// ("Up to", "30% OFF"); text without a percentage stays on one line.
  (String?, String) get offerLines {
    final match = RegExp(r'^(.*?)\s*(\d+\s*%.*)$').firstMatch(offerText.trim());
    if (match == null) return (null, offerText.trim());
    final lead = match.group(1)!.trim();
    return (lead.isEmpty ? null : lead, match.group(2)!.trim());
  }
}
