import '../../cart/domain/cart_item.dart';
import '../domain/delivery_method.dart';
import '../domain/order_confirmation.dart';
import '../domain/shipping_address.dart';

abstract class CheckoutRepository {
  Future<OrderConfirmation> submitOrder({
    required ShippingAddress address,
    required DeliveryMethod deliveryMethod,
    required List<CartItem> cartItems,
    required double totalAmount,
    String? customOrderId,
  });
}

class MockCheckoutRepository implements CheckoutRepository {
  @override
  Future<OrderConfirmation> submitOrder({
    required ShippingAddress address,
    required DeliveryMethod deliveryMethod,
    required List<CartItem> cartItems,
    required double totalAmount,
    String? customOrderId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final orderId = customOrderId ?? 'NK-849201';

    return OrderConfirmation(
      orderId: orderId,
      items: List.unmodifiable(cartItems),
      totalAmount: totalAmount,
      shippingAddress: address,
      date: DateTime.now(),
    );
  }
}
