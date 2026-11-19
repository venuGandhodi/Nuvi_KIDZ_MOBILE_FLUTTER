import 'dart:convert';

import '../../home/domain/product.dart';

/// The filter groups shown on the collection page. Each maps to a Shopify
/// Search & Discovery filter by its label (price uses Shopify's price range).
enum CollectionFilterKind {
  age('Age'),
  price('Price'),
  color('Color'),
  gender('Gender'),
  occasion('Occasion'),
  category('Category'),
  delivery('Delivery Time');

  final String label;
  const CollectionFilterKind(this.label);

  /// Which group a Shopify filter belongs to, from its label and type.
  static CollectionFilterKind? of(String label, String type) {
    if (type == 'PRICE_RANGE') return price;
    final l = label.toLowerCase();
    if (l.contains('age') || l.contains('size')) return age;
    if (l.contains('colo')) return color;
    if (l.contains('gender')) return gender;
    if (l.contains('occasion')) return occasion;
    if (l.contains('delivery')) return delivery;
    if (l.contains('categor') || l.contains('type')) return category;
    return null;
  }
}

/// One selectable value of a filter, e.g. "0 – 2Y" under Age.
class CollectionFilterValue {
  final String id;
  final String label;
  final int count;

  /// Shopify `ProductFilter` input for this value, as a JSON string.
  final String input;

  const CollectionFilterValue({
    required this.id,
    required this.label,
    required this.input,
    this.count = 0,
  });

  /// Fixed price bands (Shopify returns one open price range, not values).
  static final List<CollectionFilterValue> priceBands = [
    _band('Under ₹500', 0, 499),
    _band('₹500 – ₹999', 500, 999),
    _band('₹1,000 – ₹1,999', 1000, 1999),
    _band('₹2,000 & above', 2000, null),
  ];

  static CollectionFilterValue _band(String label, int min, int? max) =>
      CollectionFilterValue(
        id: 'price:$min-${max ?? ''}',
        label: label,
        input: jsonEncode({
          'price': {'min': min, 'max': ?max},
        }),
      );
}

/// A filter Shopify offers for the current collection.
class CollectionFilter {
  final String id;
  final String label;
  final String type;
  final List<CollectionFilterValue> values;

  const CollectionFilter({
    required this.id,
    required this.label,
    required this.type,
    required this.values,
  });

  CollectionFilterKind? get kind => CollectionFilterKind.of(label, type);
}

/// A value the shopper picked, kept with its group for chips and removal.
class SelectedFilterValue {
  final CollectionFilterKind kind;
  final CollectionFilterValue value;

  const SelectedFilterValue(this.kind, this.value);

  String get chipLabel => '${kind.label}: ${value.label}';

  @override
  bool operator ==(Object other) =>
      other is SelectedFilterValue &&
      other.kind == kind &&
      other.value.id == value.id;

  @override
  int get hashCode => Object.hash(kind, value.id);
}

/// One page of a collection: its products and the filters it supports.
class CollectionPage {
  final List<Product> products;
  final List<CollectionFilter> filters;

  const CollectionPage({required this.products, this.filters = const []});
}

/// True when the collection already targets one gender (e.g. "Boys"), so
/// the Gender filter is redundant there.
bool isGenderSpecificCollection(String? title, String? handle) {
  final text = '${title ?? ''} ${handle ?? ''}'.toLowerCase();
  return RegExp(
    r'\b(boy|boys|girl|girls)\b',
  ).hasMatch(text.replaceAll(RegExp(r'[-_]'), ' '));
}
