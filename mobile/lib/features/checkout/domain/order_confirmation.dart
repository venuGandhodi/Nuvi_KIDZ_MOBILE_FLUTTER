import '../../cart/domain/cart_item.dart';
import 'shipping_address.dart';

class OrderConfirmation {
  final String orderId;
  final List<CartItem> items;
  final double totalAmount;
  final ShippingAddress shippingAddress;
  final DateTime date;

  const OrderConfirmation({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.date,
  });
}
