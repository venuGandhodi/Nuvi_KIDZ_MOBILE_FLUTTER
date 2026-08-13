import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/checkout/domain/delivery_method.dart';
import 'package:nuvi_kidz/features/checkout/domain/payment_method_type.dart';
import 'package:nuvi_kidz/features/checkout/domain/shipping_address.dart';
import 'package:nuvi_kidz/features/checkout/presentation/checkout_controller.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';

void main() {
  late ProviderContainer container;

  final validAddress = const ShippingAddress(
    firstName: 'Jane',
    lastName: 'Doe',
    address: '123 Playful Lane',
    city: 'Smileville',
    state: 'CA',
    zipCode: '90210',
  );

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('CheckoutController Tests', () {
    test('initial state has default shipping and payment methods', () {
      final state = container.read(checkoutControllerProvider);
      expect(state.selectedDeliveryMethod.id, equals('standard'));
      expect(state.selectedPaymentMethod, equals(PaymentMethodType.creditCard));
    });

    test('updateAddress and setDeliveryMethod update state', () {
      final controller = container.read(checkoutControllerProvider.notifier);
      controller.updateAddress(validAddress);
      controller.setDeliveryMethod(DeliveryMethod.express);

      final state = container.read(checkoutControllerProvider);
      expect(state.shippingAddress.firstName, equals('Jane'));
      expect(state.selectedDeliveryMethod.id, equals('express'));
    });

    test('submitOrder validates address and credit card fields', () async {
      final controller = container.read(checkoutControllerProvider.notifier);
      var success = await controller.submitOrder();

      expect(success, isFalse);
      expect(
        container.read(checkoutControllerProvider).errorMessage,
        contains('shipping details'),
      );
    });

    test(
      'submitOrder succeeds, clears cart, and creates confirmation',
      () async {
        final cartController = container.read(cartControllerProvider.notifier);
        await cartController.addItem(
          product: const Product(id: 'p1', title: 'Romper', price: '\$34.00'),
          quantity: 1,
        );

        final checkoutNotifier = container.read(
          checkoutControllerProvider.notifier,
        );
        checkoutNotifier.updateAddress(validAddress);
        checkoutNotifier.updateCardNumber('4111111111111111');
        checkoutNotifier.updateExpiryDate('12/28');
        checkoutNotifier.updateCvc('123');

        final success = await checkoutNotifier.submitOrder(
          customOrderId: 'NK-TEST-9999',
        );

        expect(success, isTrue);

        final checkoutState = container.read(checkoutControllerProvider);
        final cartState = container.read(cartControllerProvider);

        expect(
          checkoutState.orderConfirmation?.orderId,
          equals('NK-TEST-9999'),
        );
        expect(cartState.items, isEmpty); // Cart cleared!
      },
    );
  });
}
