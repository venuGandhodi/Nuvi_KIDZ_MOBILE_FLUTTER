import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';

class CartItem {
  final String id;
  final Product product;
  final String? shopifyVariantId;
  final ProductColor? selectedColor;
  final String? selectedSize;
  final int quantity;
  final double unitPrice;
  final String currencyCode;

  const CartItem({
    required this.id,
    required this.product,
    this.shopifyVariantId,
    this.selectedColor,
    this.selectedSize,
    required this.quantity,
    required this.unitPrice,
    this.currencyCode = 'INR',
  });

  double get lineTotal => unitPrice * quantity;

  String get formattedUnitPrice {
    final formatted = unitPrice.toStringAsFixed(
      unitPrice.truncateToDouble() == unitPrice ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  String get formattedLineTotal {
    final formatted = lineTotal.toStringAsFixed(
      lineTotal.truncateToDouble() == lineTotal ? 0 : 2,
    );
    return currencyCode == 'INR' ? '₹$formatted' : '$currencyCode $formatted';
  }

  String get displayVariantInfo {
    final parts = <String>[];
    if (selectedColor != null) {
      parts.add(selectedColor!.name);
    }
    if (selectedSize != null && selectedSize!.isNotEmpty) {
      parts.add(selectedSize!);
    }
    return parts.join(' • ');
  }

  CartItem copyWith({
    String? id,
    Product? product,
    String? shopifyVariantId,
    ProductColor? selectedColor,
    String? selectedSize,
    int? quantity,
    double? unitPrice,
    String? currencyCode,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      shopifyVariantId: shopifyVariantId ?? this.shopifyVariantId,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
