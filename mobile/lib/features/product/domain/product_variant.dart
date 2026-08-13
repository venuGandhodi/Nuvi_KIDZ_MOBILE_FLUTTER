class ProductVariant {
  final String id;
  final String title;
  final double priceAmount;
  final String currencyCode;
  final double? compareAtPriceAmount;
  final Map<String, String> selectedOptions;
  final bool availableForSale;
  final String? size;
  final String? color;

  const ProductVariant({
    required this.id,
    required this.title,
    required this.priceAmount,
    this.currencyCode = 'INR',
    this.compareAtPriceAmount,
    this.selectedOptions = const {},
    this.availableForSale = true,
    this.size,
    this.color,
  });

  String get formattedPrice {
    final formatted = priceAmount.toStringAsFixed(
      priceAmount.truncateToDouble() == priceAmount ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  String? get formattedCompareAtPrice {
    if (compareAtPriceAmount == null) return null;
    final formatted = compareAtPriceAmount!.toStringAsFixed(
      compareAtPriceAmount!.truncateToDouble() == compareAtPriceAmount ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }
}
