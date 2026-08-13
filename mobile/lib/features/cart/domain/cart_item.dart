import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';

class CartItem {
  final String id;
  final Product product;
  final ProductColor? selectedColor;
  final String? selectedSize;
  final int quantity;
  final double unitPrice;

  const CartItem({
    required this.id,
    required this.product,
    this.selectedColor,
    this.selectedSize,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * quantity;

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
    ProductColor? selectedColor,
    String? selectedSize,
    int? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
