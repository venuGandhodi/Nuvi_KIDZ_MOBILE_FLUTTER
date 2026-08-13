import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/domain/cart_item.dart';

import 'package:nuvi_kidz/features/checkout/data/checkout_repository.dart';
import 'package:nuvi_kidz/features/checkout/domain/delivery_method.dart';

import 'package:nuvi_kidz/features/checkout/domain/shipping_address.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';

void main() {
  late MockCheckoutRepository repository;

  final sampleAddress = const ShippingAddress(
    firstName: 'Jane',
    lastName: 'Doe',
    address: '123 Playful Lane',
    city: 'Smileville',
    state: 'CA',
    zipCode: '90210',
  );

  final sampleCartItem = CartItem(
    id: 'c1',
    product: const Product(id: 'p1', title: 'Romper', price: '\$34.00'),
    quantity: 1,
    unitPrice: 34.0,
  );

  setUp(() {
    repository = MockCheckoutRepository();
  });

  group('MockCheckoutRepository Tests', () {
    test('submitOrder generates deterministic order confirmation', () async {
      final confirmation = await repository.submitOrder(
        address: sampleAddress,
        deliveryMethod: DeliveryMethod.standard,
        cartItems: [sampleCartItem],
        totalAmount: 41.72,
        customOrderId: 'NK-TEST-0001',
      );

      expect(confirmation.orderId, equals('NK-TEST-0001'));
      expect(confirmation.totalAmount, equals(41.72));
      expect(confirmation.items.length, equals(1));
      expect(confirmation.shippingAddress.firstName, equals('Jane'));
    });
  });
}
