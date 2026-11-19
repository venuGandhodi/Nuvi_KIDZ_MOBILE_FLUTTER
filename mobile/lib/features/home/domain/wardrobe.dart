/// One picture in a wardrobe block: a product cut-out (left side) or a
/// photo card with an offer (Top Picks, right side).
class WardrobeTile {
  final String title;
  final String? imageUrl;

  /// Collection opened on tap; null when not set in Shopify (not tappable).
  final String? collectionHandle;
  final String? badgeText;
  final String? offerText;

  const WardrobeTile({
    required this.title,
    this.collectionHandle,
    this.imageUrl,
    this.badgeText,
    this.offerText,
  });
}

/// A "Girl's Wardrobe" style block: categories on the left, Top Picks on
/// the right, read from the Shopify metaobject `wardrobe_section`.
class WardrobeSection {
  final String title;
  final String picksTitle;
  final String picksHighlight;
  final List<WardrobeTile> categories;
  final List<WardrobeTile> topPicks;

  const WardrobeSection({
    required this.title,
    this.picksTitle = 'Top Picks',
    this.picksHighlight = '',
    this.categories = const [],
    this.topPicks = const [],
  });
}
